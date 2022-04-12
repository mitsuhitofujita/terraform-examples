resource "aws_ecs_task_definition" "fargate" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(var.container_definitions)
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
}
