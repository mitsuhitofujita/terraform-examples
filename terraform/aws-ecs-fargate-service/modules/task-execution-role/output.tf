output "arn" {
  value = aws_iam_role.task_execution.arn
}

output "id" {
  value = aws_iam_role.task_execution.id
}

output "assume_role_policy_json" {
  value = data.aws_iam_policy_document.assume_role_policy.json
}
