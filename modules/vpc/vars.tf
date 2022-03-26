variable "vpc_cidr_block" {
  type = string
}

variable "public_cidr_block" {
  type = list(string)
}

variable "availability_zone" {
    type = string
}

variable "private_cidr_block" {
    type = list(string)
}

