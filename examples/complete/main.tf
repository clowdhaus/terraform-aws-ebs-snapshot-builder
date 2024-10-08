provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "us-east-2"
  name   = "ex-ebs-snapshot-builder"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder"
  }
}

################################################################################
# Ebs Snapshot Builder Module
################################################################################

module "ebs_snapshot_builder" {
  source = "../.."

  name = local.name

  # Images to cache
  public_images = [
    "nvcr.io/nvidia/k8s-device-plugin:v0.16.2", # 120 MB compressed / 351 MB decompressed
    "nvcr.io/nvidia/pytorch:24.08-py3",         # 9.5 GB compressed / 20.4 GB decompressed
  ]

  # AZs to enable fast snapshot restore
  fsr_availability_zone_names = local.azs

  vpc_id    = module.vpc.vpc_id
  subnet_id = element(module.vpc.private_subnets, 0)

  tags = local.tags
}

module "ebs_snapshot_builder_disabled" {
  source = "../.."

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}
