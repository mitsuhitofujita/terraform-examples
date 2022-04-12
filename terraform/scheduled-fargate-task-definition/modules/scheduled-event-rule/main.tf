resource "aws_cloudwatch_event_rule" "scheduled" {
  name                = "${var.name_prefix}-scheduled-event-rule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "scheduled" {
  target_id = "${var.name_prefix}-event-target"
  arn       = var.ecs_cluster_arn
  rule      = aws_cloudwatch_event_rule.scheduled.name
  role_arn  = var.cloudwatch_event_target_role_arn

  ecs_target {
    task_count          = 1
    task_definition_arn = var.task_definition_arn
    launch_type         = "FARGATE"
    # platform_version    = var.platform_version

    network_configuration {
      assign_public_ip = var.assign_public_ip
      security_groups  = var.vpc_security_groups
      subnets          = var.vpc_subnets
    }
  }
}
