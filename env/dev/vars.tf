variable "env" {
  type = string
}
variable "appname" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_cidr_block" {
  type = list(any)
}

variable "private_cidr_block" {
  type = list(any)
}

variable "availability_zones" {
  type = list(any)
}

variable "tags" {
  type = map(any)
}

variable "internal" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "ingress" {
  type = any
}