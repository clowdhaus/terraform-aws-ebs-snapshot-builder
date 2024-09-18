variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# State Machine
################################################################################

variable "name" {
  description = "The name of the state machine"
  type        = string
  default     = ""
}

variable "state_machine_tags" {
  description = "A map of addititional tags to add to the state machine"
  type        = map(string)
  default     = {}
}

variable "eks_version" {
  description = "The EKS version for the respective EKS AMI that will be used to create the EC2 instance"
  type        = string
  default     = "1.31"
}

variable "ecr_images" {
  description = "A list of ECR images to pull"
  type        = list(string)
  default     = []
}

variable "public_images" {
  description = "A list of images to pull from public registries"
  type        = list(string)
  default     = []
}

variable "fsr_availability_zone_names" {
  description = "A list of availability zone names where EBS Fast Snapshot Restore will be enabled"
  type        = list(string)
  default     = []
}


variable "cpu_architecture" {
  description = "The CPU architecture of the instance. Either `amd64` or `arm64`"
  type        = string
  default     = "amd64"
}

variable "instance_type" {
  description = "The instance type to launch"
  type        = string
  default     = "c6in.16xlarge"
}

variable "ebs_volume_settings" {
  description = "A map of EBS volume settings that will be used on the volumes (root + additional) attached to the instance created"
  type = object({
    iops        = optional(number, 6000),
    throughput  = optional(number, 500),
    volume_size = optional(number, 64),
  })
  default = {}
}

variable "default_values" {
  description = "A map of default values to use for the state machine"
  type = object({
    enable_fast_snapshot_restore = optional(bool, true)
    snapshot_name                = optional(string, "ml-container-cache")
    snapshot_description         = optional(string, "ML container image cache")
  })
  default = {}
}

################################################################################
# Snapshot SSM Parameter
################################################################################

variable "ssm_parameter_name" {
  description = "The name of the SSM parameter to create for storing the created snapshot ID"
  type        = string
  default     = null
}

################################################################################
# Instance Security Group
################################################################################

variable "vpc_id" {
  description = "The VPC ID where the intance and security group will be created"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The subnet ID where the EC2 instance will be launched"
  type        = string
  default     = ""
}

variable "security_group_egress_rules" {
  description = "A list of egress rules to add to the security group"
  type        = any
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
