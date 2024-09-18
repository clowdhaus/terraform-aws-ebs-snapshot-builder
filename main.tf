data "aws_region" "current" {
  count = var.create ? 1 : 0
}

data "aws_partition" "current" {
  count = var.create ? 1 : 0
}

locals {
  region     = try(data.aws_region.current[0].name, "")
  partition  = try(data.aws_partition.current[0].partition, "")
  dns_suffix = try(data.aws_partition.current[0].dns_suffix, "")

  ami_cpu_architecture = var.cpu_architecture == "arm64" ? "arm64" : "x86_64"
}

# Using the EKS AMI allows us to use ctr to pull images
data "aws_ssm_parameter" "eks_ami" {
  count = var.create ? 1 : 0

  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2023/${local.ami_cpu_architecture}/standard/recommended/image_id"
}

################################################################################
# State Machine
################################################################################

module "state_machine" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "~> 4.2"

  create = var.create

  name = var.name
  definition = nonsensitive(templatefile("${path.module}/state_machine.json", {
    ami_id = try(data.aws_ssm_parameter.eks_ami[0].value, "")
    base64_encoded_user_data = base64encode(templatefile("${path.module}/user_data.sh", {
      cpu_architecture = var.cpu_architecture
      ecr_images       = var.ecr_images
      public_images    = var.public_images
      region           = local.region
    }))
    availability_zones       = join("\",\"", var.fsr_availability_zone_names)
    default_values           = var.default_values
    ebs_volume_settings      = var.ebs_volume_settings
    iam_instance_profile_arn = try(aws_iam_instance_profile.ec2[0].arn, "")
    instance_type            = var.instance_type
    security_group_id        = module.security_group.security_group_id
    subnet_id                = var.subnet_id
    ssm_parameter_name       = try(aws_ssm_parameter.snapshot_id[0].name, "")
  }))

  attach_policy_json = true
  policy_json        = try(data.aws_iam_policy_document.state_machine[0].json, "")

  tags = merge(var.tags, var.state_machine_tags)
}

data "aws_iam_policy_document" "state_machine" {
  count = var.create ? 1 : 0

  # EKS AMI SSM parameter
  statement {
    sid       = "SSMGetParameter"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:${local.partition}:ssm:${local.region}::parameter/aws/service/eks/optimized-ami/*"]
  }

  # State machine pass IAM role to EC2
  statement {
    sid       = "PassRole"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ec2[0].arn]
  }

  # State machine EC2 API calls to create/terminate instances and snapshots
  statement {
    sid = "Instance"
    actions = [
      "ec2:CreateTags",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:CreateSnapshot",
      "ec2:EnableFastSnapshotRestores",
    ]
    resources = [
      "arn:aws:ec2:*::image/*",
      "arn:aws:ec2:*::snapshot/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:network-interface/*",
    ]
  }

  # State machine EC2 API calls to check instance/snapshot state
  statement {
    sid = "DescribeInstance"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
    ]
    resources = ["*"]
  }

  # State machine SSM API calls to check cloud-init status
  statement {
    sid = "SendSSMCaommand"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
    ]
    resources = ["*"]
  }

  # State machine SSM API call to update the snapshot ID parameter
  statement {
    sid       = "SSMPutParameter"
    actions   = ["ssm:PutParameter"]
    resources = [aws_ssm_parameter.snapshot_id[0].arn]
  }
}

################################################################################
# Snapshot SSM Parameter
################################################################################

resource "aws_ssm_parameter" "snapshot_id" {
  count = var.create ? 1 : 0

  name  = try(coalesce(var.ssm_parameter_name, "/${var.name}/snapshot-id"), "")
  type  = "String"
  value = "xxx"

  lifecycle {
    # The state machine will be responsible for the value after creation
    ignore_changes = [
      value
    ]
  }

  tags = var.tags
}

################################################################################
# Instance IAM Role & Profile
################################################################################

data "aws_iam_policy_document" "ec2_assume_role" {
  count = var.create ? 1 : 0

  statement {
    sid = "EC2NodeAssumeRole"
    actions = [
      "sts:TagSession",
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.${local.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  count = var.create ? 1 : 0

  name_prefix           = "${var.name}-instance-"
  assume_role_policy    = data.aws_iam_policy_document.ec2_assume_role[0].json
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_role" {
  for_each = { for k, v in {
    AmazonEC2ContainerRegistryReadOnly = "arn:${local.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonSSMManagedInstanceCore       = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
  } : k => v if var.create }

  policy_arn = each.value
  role       = aws_iam_role.ec2[0].name
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.create ? 1 : 0

  name_prefix = "${var.name}-instance-"
  role        = aws_iam_role.ec2[0].name

  tags = var.tags
}

################################################################################
# Instance Security Group
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  create = var.create

  name                    = var.name
  vpc_id                  = var.vpc_id
  egress_with_cidr_blocks = var.security_group_egress_rules

  tags = var.tags
}
