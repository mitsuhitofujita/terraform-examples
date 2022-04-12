variable "family" {}

variable "container_definitions" {
  type = list(object({
    name      = string
    image     = string
    command   = list(string)
    essential = bool
    cpu       = number
    memory    = number
    logConfiguration = object({
      logDriver = string
      options = object({
        awslogs-group         = string
        awslogs-region        = string
        awslogs-stream-prefix = string
      })
    })
    portMappings = list(object({
      containerPort = number
      hostPort      = number
    }))
    environment = list(object({
      name  = string
      value = string
    }))
  }))
  default = [{
    name  = "alpine"
    image = "alpine:latest"
    command = [
      "env"
    ]
    essential        = true
    cpu              = 256
    memory           = 512
    logConfiguration = null
    environment      = []
    portMappings     = []
  }]
}

variable "task_execution_role_arn" {}

variable "task_role_arn" {}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}
