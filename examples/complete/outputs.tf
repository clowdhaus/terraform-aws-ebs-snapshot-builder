output "start_execution_command" {
  description = "Example awscli command to start the state machine execution"
  value       = module.ebs_snapshot_builder.start_execution_command
}

################################################################################
# Snapshot SSM Parameter
################################################################################

output "ssm_parameter_arn" {
  description = "The ARN of the SSM parameter storing the snapshot name"
  value       = module.ebs_snapshot_builder.ssm_parameter_arn
}

output "ssm_parameter_name" {
  description = "The name of the SSM parameter storing the snapshot name"
  value       = module.ebs_snapshot_builder.ssm_parameter_name
}
