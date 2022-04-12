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
# queue
#

module "worker-queue" {
  source      = "./modules/sqs"
  name_prefix = "${local.prefix}-worker"
}

#
# task
#

module "task_execution_role" {
  source      = "./modules/task-execution-role"
  name_prefix = local.prefix
}

#
# worker
#

resource "aws_ecs_cluster" "worker" {
  name = "${local.prefix}-worker-cluster"
}

module "worker_task_role" {
  source             = "./modules/task-role"
  name_prefix        = local.prefix
  assume_role_policy = module.task_execution_role.assume_role_policy_json
}

module "worker_repository" {
  source          = "./modules/ecr-repository"
  region          = local.region
  account_id      = local.account_id
  name_prefix     = "${local.prefix}-worker"
  dockerfile_path = "./docker/alpine/Dockerfile"
  image_tag       = var.worker_container_image_tag
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "${local.prefix}-worker-log-group"
  retention_in_days = 1
}

module "worker_container_definition" {
  source                = "./modules/worker-container-definition"
  name_prefix           = local.prefix
  image                 = "${module.worker_repository.repository_url}:${module.worker_repository.image_tag}"
  awslogs_group         = aws_cloudwatch_log_group.worker.name
  awslogs_region        = local.region
  awslogs_stream_prefix = "worker"
  command               = ["date"]
}

module "worker_task_definition" {
  source                  = "./modules/fargate-task-definition"
  family                  = "${local.prefix}-worker-task-definition"
  container_definitions   = [module.worker_container_definition.content]
  task_execution_role_arn = module.task_execution_role.arn
  task_role_arn           = module.worker_task_role.arn
}

module "worker_service" {
  source                     = "./modules/worker-ecs-service"
  name_prefix                = local.prefix
  vpc_id                     = module.vpc.vpc_id
  vpc_private_subnet_ids     = module.vpc.private_subnet_ids
  cluster_name               = aws_ecs_cluster.worker.name
  worker_task_definition_arn = module.worker_task_definition.arn
}
