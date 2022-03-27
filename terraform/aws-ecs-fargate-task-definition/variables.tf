variable "aws_region" {
  default = "ap-northeast-1"
}

variable "project" {
  default = "te" // terraform examples
}

variable "environment" {
  default = "dev"
}

variable "feature" {
  default = "ctd" // command task definition
}

variable "command_container_image_tag" {
  default = "latest"
}
