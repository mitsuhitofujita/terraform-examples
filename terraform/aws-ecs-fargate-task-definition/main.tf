terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "self" {}

locals {
  region     = var.aws_region
  prefix     = "${var.project}-${var.environment}-${var.feature}"
  account_id = data.aws_caller_identity.self.account_id
}

module "task_execution_role" {
  source      = "./modules/task-execution-role"
  name_prefix = local.prefix
}

#
# standalone command task definition
#

resource "aws_ecs_cluster" "command" {
  name = "${local.prefix}-command-cluster"
}

module "command_task_role" {
  source             = "./modules/task-role"
  name_prefix        = local.prefix
  assume_role_policy = module.task_execution_role.assume_role_policy_json
}

module "command_repository" {
  source          = "./modules/ecr-repository"
  region          = local.region
  account_id      = local.account_id
  name_prefix     = "${local.prefix}-command"
  dockerfile_path = "./docker/alpine/Dockerfile"
  image_tag       = var.command_container_image_tag
}

resource "aws_cloudwatch_log_group" "command" {
  name              = "${local.prefix}-command-log-group"
  retention_in_days = 1
}

module "date_command_container_definition" {
  source                = "./modules/command-container-definition"
  name_prefix           = local.prefix
  image                 = "${module.command_repository.repository_url}:${module.command_repository.image_tag}"
  awslogs_group         = aws_cloudwatch_log_group.command.name
  awslogs_region        = local.region
  awslogs_stream_prefix = "command"
  command               = ["date"]
}

module "command_task_definition" {
  source                  = "./modules/fargate-task-definition"
  family                  = "${local.prefix}-command-task-definition"
  container_definitions   = [module.date_command_container_definition.content]
  task_execution_role_arn = module.task_execution_role.arn
  task_role_arn           = module.command_task_role.arn
}
