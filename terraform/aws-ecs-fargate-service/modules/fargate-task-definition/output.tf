output "family" {
  value = aws_ecs_task_definition.fargate.family
}

output "arn" {
  value = aws_ecs_task_definition.fargate.arn
}
