provider "aws" {
  region  = "us-east-1"
  profile = "terraform-session"
}


module "vpc" {
  source             = "../../modules/vpc"
  env                = var.env
  appname            = var.appname
  vpc_cidr_block     = var.vpc_cidr_block
  public_cidr_block  = var.public_cidr_block
  private_cidr_block = var.private_cidr_block
  availability_zones = var.availability_zones
  tags               = var.tags
}

module "alb" {
  source             = "../../modules/loadbalancer"
  env                = var.env
  appname            = var.appname
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  tags               = var.tags
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = var.internal == "true" ? module.vpc.private_subnets : module.vpc.public_subnets
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = var.ingress
    content {
      description = lookup(ingress.value, "description", null)
      from_port   = lookup(ingress.value, "port", null)
      to_port     = lookup(ingress.value, "port", null)
      protocol    = lookup(ingress.value, "protocol", "tcp")
      cidr_blocks = lookup(ingress.value, "cidr_blocks", [var.vpc_cidr_block])
    }

  }
  tags = var.tags
}