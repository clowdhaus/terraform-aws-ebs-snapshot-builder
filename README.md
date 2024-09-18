# AWS EBS Snapshot Builder Terraform module

Terraform module to provision an EBS snapshot builder state machine on AWS.

## Usage

See [`examples`](https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder/tree/main/examples) directory for working examples to reference:

```hcl
module "ebs_snapshot_builder" {
  source = "clowdhaus/ebs-snapshot-builder/aws"

  name = "example"
  
  # Images to cache
  public_images = [
    "nvcr.io/nvidia/k8s-device-plugin:v0.16.2", # 120 MB compressed / 351 MB decompressed
    "nvcr.io/nvidia/pytorch:24.08-py3",         # 9.5 GB compressed / 20.4 GB decompressed
  ]

  # AZs where EBS fast snapshot restore will be enabled
  fsr_availability_zone_names = ["us-east-1a", "us-east-1b", "us-east-1c"]

  vpc_id    = "vpc-1234556abcdef"
  subnet_id = "subnet-abcde012"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Examples

Examples codified under the [`examples`](https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder/tree/main/examples) are intended to give users references for how to use the module(s) as well as testing/validating changes to the source code of the module. If contributing to the project, please be sure to make any appropriate updates to the relevant examples to allow maintainers to test your changes and to keep the examples up to date for users. Thank you!

- [Complete](https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.68 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.68 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_state_machine"></a> [state\_machine](#module\_state\_machine) | terraform-aws-modules/step-functions/aws | ~> 4.2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ssm_parameter.snapshot_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_iam_policy_document.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.eks_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | The CPU architecture of the instance. Either `amd64` or `arm64` | `string` | `"amd64"` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_default_values"></a> [default\_values](#input\_default\_values) | A map of default values to use for the state machine | <pre>object({<br/>    enable_fast_snapshot_restore = optional(bool, true)<br/>    snapshot_name                = optional(string, "ml-container-cache")<br/>    snapshot_description         = optional(string, "ML container image cache")<br/>  })</pre> | `{}` | no |
| <a name="input_ebs_volume_settings"></a> [ebs\_volume\_settings](#input\_ebs\_volume\_settings) | A map of EBS volume settings that will be used on the volumes (root + additional) attached to the instance created | <pre>object({<br/>    iops        = optional(number, 6000),<br/>    throughput  = optional(number, 500),<br/>    volume_size = optional(number, 64),<br/>  })</pre> | `{}` | no |
| <a name="input_ecr_images"></a> [ecr\_images](#input\_ecr\_images) | A list of ECR images to pull | `list(string)` | `[]` | no |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | The EKS version for the respective EKS AMI that will be used to create the EC2 instance | `string` | `"1.31"` | no |
| <a name="input_fsr_availability_zone_names"></a> [fsr\_availability\_zone\_names](#input\_fsr\_availability\_zone\_names) | A list of availability zone names where EBS Fast Snapshot Restore will be enabled | `list(string)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to launch | `string` | `"c6in.16xlarge"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the state machine | `string` | `""` | no |
| <a name="input_public_images"></a> [public\_images](#input\_public\_images) | A list of images to pull from public registries | `list(string)` | `[]` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | A list of egress rules to add to the security group | `any` | <pre>[<br/>  {<br/>    "cidr_blocks": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_ssm_parameter_name"></a> [ssm\_parameter\_name](#input\_ssm\_parameter\_name) | The name of the SSM parameter to create for storing the created snapshot ID | `string` | `null` | no |
| <a name="input_state_machine_tags"></a> [state\_machine\_tags](#input\_state\_machine\_tags) | A map of addititional tags to add to the state machine | `map(string)` | `{}` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID where the EC2 instance will be launched | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID where the intance and security group will be created | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_start_execution_command"></a> [start\_execution\_command](#output\_start\_execution\_command) | Example awscli command to start the state machine execution |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder/blob/main/LICENSE).
