output "start_execution_command" {
  description = "Example awscli command to start the state machine execution"
  value       = module.ebs_snapshot_builder.start_execution_command
}
