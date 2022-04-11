variable "env" {
  type = string
}

variable "appname" {
  type = string
}

variable "internal" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "security_groups" {
  type = list(any)
}

variable "subnets" {
  type = list(any)
}

variable "target_groups" {
  type    = any
  default = {}
}

variable "http_listener" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}