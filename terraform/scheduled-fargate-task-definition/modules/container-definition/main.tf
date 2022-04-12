locals {
  container_definition = {
    "name" : "${var.name_prefix}-container-definition",
    "image" : var.image,
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : "${var.awslogs_group}",
        "awslogs-region" : "${var.awslogs_region}",
        "awslogs-stream-prefix" : "${var.awslogs_stream_prefix}"
      }
    },
    "command" : var.command,
    "cpu" : var.cpu,
    "memory" : var.memory,
    "essential" : var.essential,
    "environment" : []
  }
}
