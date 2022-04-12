variable "name_prefix" {}
variable "vpc_id" {}
variable "cluster_name" {}
variable "vpc_private_subnet_ids" {
  type = list(string)
}
variable "worker_task_definition_arn" {}
