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
  security_groups    = ["sg-0fb16889347b6b0c4"]
  subnets            = var.internal == "true" ? module.vpc.private_subnets : module.vpc.public_subnets
}
