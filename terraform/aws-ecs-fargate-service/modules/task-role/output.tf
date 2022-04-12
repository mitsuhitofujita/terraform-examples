output "arn" {
  value = aws_iam_role.task.arn
}

output "id" {
  value = aws_iam_role.task.id
}

output "policy_json" {
  value = data.aws_iam_policy_document.role_policy.json
}
