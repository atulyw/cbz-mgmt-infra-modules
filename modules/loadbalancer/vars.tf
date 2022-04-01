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
  type = list
}

variable "subnets" {
  type = list
}
# variable "listener_rule" {
#   type    = any
#   default = {}
# }

# variable "https_port" {
#   type    = string
#   default = "443"
# }

# variable "listener_protocol" {
#   type    = string
#   default = "HTTPS"
# }

# variable "target_groups" {
#   type    = any
#   default = {}
# }