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
  vpc_id             = module.vpc.vpc_id
  tags               = var.tags
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = var.internal == "true" ? module.vpc.private_subnets : module.vpc.public_subnets
  target_groups = {
    laptop = {
      port         = "8080"
      path         = "/laptop/index.html"
      path_pattern = "/laptop/*"
      port         = "8080"
      priority     = 100
    }
    mobile = {
      port         = "8081"
      path         = "/mobile/index.html"
      path_pattern = "/mobile/*"
      port         = "8081"
      priority     = 200
    }
    cloth = {
      port         = "8082"
      path         = "/cloth/index.html"
      port         = "8082"
      path_pattern = "/cloth/*"
      priority     = 300
    }
    runner = {
      port         = "8083"
      path         = "/runner/index.html"
      port         = "8083"
      path_pattern = "/runner/*"
      priority     = 400
    }
    athe = {
      port         = "8084"
      path         = "/athe/index.html"
      port         = "8084"
      path_pattern = "/athe/*"
      priority     = 500
    }
  }
}


module "as" {
  source            = "../../modules/autoscaling"
  env               = var.env
  appname           = var.appname
  vpc_id            = module.vpc.vpc_id
  instance_type     = "t2.micro"
  security_group    = aws_security_group.allow_tls.id
  subnets           = module.vpc.private_subnets
  target_group_arns = module.alb.target_group_arns
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



