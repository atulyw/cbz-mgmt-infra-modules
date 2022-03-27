variable "vpc_cidr_block" {
  type = string
}

variable "public_cidr_block" {
  type = list(string) #required
}

variable "availability_zones" {
  type = list(string) #required
}

variable "private_cidr_block" {
  type = list(string) #requred
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "env" {
  type = string
}

variable "appname" {
  type    = string
  default = ""
}
