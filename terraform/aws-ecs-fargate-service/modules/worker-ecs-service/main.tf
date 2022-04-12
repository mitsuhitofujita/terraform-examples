resource "aws_security_group" "worker_service" {
  name   = "${var.name_prefix}-http-service-security-group"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_ecs_service" "worker_fargate" {
  name            = "${var.name_prefix}-worker-fargate-service"
  cluster         = var.cluster_name
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = var.worker_task_definition_arn
  network_configuration {
    subnets          = var.vpc_private_subnet_ids
    security_groups  = [aws_security_group.worker_service.id]
    assign_public_ip = false
  }
}
