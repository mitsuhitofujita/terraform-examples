variable "aws_region" {
  default = "ap-northeast-1"
}

variable "project" {
  default = "te" // terraform example
}

variable "environment" {
  default = "dev"
}

variable "feature" {
  default = "efs" // ecs fargate service
}

variable "worker_container_image_tag" {
  default = "3.15.0"
}
