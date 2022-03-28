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