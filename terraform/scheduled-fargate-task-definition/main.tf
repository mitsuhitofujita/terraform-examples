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

#
# vpc
#
module "vpc" {
  source               = "./modules/vpc"
  name_prefix          = local.prefix
  vpc_cidr_block       = "10.0.0.0/16"
  a_availability_zone  = "ap-northeast-1a"
  c_availability_zone  = "ap-northeast-1c"
  public_a_cidr_block  = "10.0.1.0/24"
  public_c_cidr_block  = "10.0.2.0/24"
  private_a_cidr_block = "10.0.11.0/24"
  private_c_cidr_block = "10.0.12.0/24"
}

#
# cluster
#
resource "aws_ecs_cluster" "scheduler" {
  name = "${local.prefix}-scheduler-cluster"
}

#
# repository
#
module "command_repository" {
  source          = "./modules/ecr-repository"
  region          = local.region
  name_prefix     = local.prefix
  account_id = local.account_id
  dockerfile_path = "./docker/alpine/Dockerfile"
  image_tag       = var.command_container_image_tag
}

#
# role
#
module "task_execution_role" {
  source      = "./modules/task-execution-role"
  name_prefix = local.prefix
}

module "task_role" {
  source             = "./modules/task-role"
  name_prefix        = local.prefix
  assume_role_policy = module.task_execution_role.assume_role_policy_json
}

#
# log
#
resource "aws_cloudwatch_log_group" "scheduler" {
  name              = "${local.prefix}-scheduler-log-group"
  retention_in_days = 1
}

#
# task
#
module "date_command_container_definition" {
  source                = "./modules/container-definition"
  name_prefix           = local.prefix
  image                 = "${module.command_repository.repository_url}:${var.command_container_image_tag}"
  command               = ["date"]
  awslogs_group         = aws_cloudwatch_log_group.scheduler.name
  awslogs_region        = local.region
  awslogs_stream_prefix = "date"
}

module "date_command_task_definition" {
  source                  = "./modules/fargate-task-definition"
  family                  = "${local.prefix}-date-command"
  container_definitions   = [module.date_command_container_definition.content]
  task_execution_role_arn = module.task_execution_role.arn
  task_role_arn           = module.task_role.arn
}

#
# event
#
module "scheduled_event_role" {
  source                  = "./modules/event-role"
  name_prefix             = local.prefix
  region                  = local.region
  cluster_arn             = aws_ecs_cluster.scheduler.arn
  task_definition_family  = module.date_command_task_definition.family
  task_execution_role_arn = module.task_execution_role.arn
  task_role_arn           = module.task_role.arn
}

module "date_command_scheduled_event_rule" {
  source                           = "./modules/scheduled-event-rule"
  name_prefix                      = "${local.prefix}-date-command"
  schedule_expression              = "cron(*/5 * * * ? *)"
  ecs_cluster_arn                  = aws_ecs_cluster.scheduler.arn
  cloudwatch_event_target_role_arn = module.scheduled_event_role.arn
  task_definition_arn              = module.date_command_task_definition.arn
  # vpc_security_groups              = module.vpc.security_group_ids
  vpc_subnets                      = module.vpc.private_subnet_ids
}
