output "start_execution_command" {
  description = "Example awscli command to start the state machine execution"
  value = <<-EOT
    aws stepfunctions start-execution \
      --region ${local.region} \
      --state-machine-arn ${module.state_machine.state_machine_arn} \
      --input ${jsonencode(jsonencode(
  {
    SnapshotName        = "ml-container-cache"
    SnapshotDescription = "ML container image cache"
  }
))}
  EOT
}

################################################################################
# Snapshot SSM Parameter
################################################################################

output "ssm_parameter_arn" {
  description = "The ARN of the SSM parameter storing the snapshot name"
  value       = try(aws_ssm_parameter.snapshot_id[0].arn, null)
}

output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the snapshot name"
  value       = try(aws_ssm_parameter.snapshot_id[0].name, null)
}
