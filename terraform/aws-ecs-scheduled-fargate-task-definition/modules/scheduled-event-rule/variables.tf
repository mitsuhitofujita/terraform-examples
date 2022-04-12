variable "name_prefix" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "cloudwatch_event_target_role_arn" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "vpc_security_groups" {
  type = list(string)
  default = null
}

variable "vpc_subnets" {
  type = list(string)
}

variable "assign_public_ip" {
  type    = bool
  default = false
}
