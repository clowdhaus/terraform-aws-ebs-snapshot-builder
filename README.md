# AWS EBS Snapshot Builder Terraform module

Terraform module to provision an EBS snapshot builder state machine on AWS.

## Usage

See [`examples`](https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder/tree/main/examples) directory for working examples to reference:

```hcl
module "ebs_snapshot_builder" {
  source = "clowdhaus/ebs-snapshot-builder/aws"

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/clowdhaus/terraform-aws-ebs-snapshot-builder/blob/main/LICENSE).
