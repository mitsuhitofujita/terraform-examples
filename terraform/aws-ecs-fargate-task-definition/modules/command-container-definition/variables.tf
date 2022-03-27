variable "name_prefix" {}

variable "image" {}

variable "awslogs_group" {}
variable "awslogs_region" {}
variable "awslogs_stream_prefix" {}

variable "command" {
  type    = list(string)
  default = null
}
variable "cpu" {
  type    = number
  default = 256
}
variable "memory" {
  type    = number
  default = 512
}
variable "essential" {
  type    = bool
  default = true
}
