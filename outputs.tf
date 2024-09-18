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
