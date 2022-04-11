variable "appname" {
  type = string
}

variable "env" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "security_group" {
  type    = string
  default = ""
}

variable "instance_permission" {
  type    = any
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "lc_sg" {
  type    = any
  default = {}
}

variable "root_block_device" {
  type    = map(any)
  default = {}
}

variable "autoscaling" {
  type    = map(any)
  default = {}
}

variable "subnets" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}