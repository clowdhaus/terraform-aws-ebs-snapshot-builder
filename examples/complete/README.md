# Complete AWS EBS Snapshot Builder Example

Configuration in this directory creates an AWS Step Function state machine that can generate EBS snapshots with container images pre-pulled (aka - cached) onto the snapshot volume. 

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

To build the EBS snapshot volume, you can start a state machine execution through the AWS console or through the `awscli`. A Terraform output `start_execution_command` has been provided to provide an example that can be modified and used to start the state machine execution:

```sh
aws stepfunctions start-execution \
  --region us-west-2 \
  --state-machine-arn arn:aws:states:us-east-2:111111111111:stateMachine:ex-ebs-snapshot-builder \
  --input "{\"SnapshotDescription\":\"ML container image cache\",\"SnapshotName\":\"ml-container-cache\"}"
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

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
| <a name="module_ebs_snapshot_builder"></a> [ebs\_snapshot\_builder](#module\_ebs\_snapshot\_builder) | ../.. | n/a |
| <a name="module_ebs_snapshot_builder_disabled"></a> [ebs\_snapshot\_builder\_disabled](#module\_ebs\_snapshot\_builder\_disabled) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssm_parameter_arn"></a> [ssm\_parameter\_arn](#output\_ssm\_parameter\_arn) | The ARN of the SSM parameter storing the snapshot name |
| <a name="output_ssm_parameter_name"></a> [ssm\_parameter\_name](#output\_ssm\_parameter\_name) | The name of the SSM parameter storing the snapshot name |
| <a name="output_start_execution_command"></a> [start\_execution\_command](#output\_start\_execution\_command) | Example awscli command to start the state machine execution |
<!-- END_TF_DOCS -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder/blob/main/LICENSE).
