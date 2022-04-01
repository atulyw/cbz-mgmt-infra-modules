resource "aws_lb" "application" {
  count                      = var.load_balancer_type == "application" ? 1 : 0
  name                       = format("%s-%s-alb", var.appname, var.env)
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.security_groups
  subnets                    = var.subnets
  enable_deletion_protection = false
  drop_invalid_header_fields = false
  idle_timeout               = 60


  access_logs {
    bucket  = aws_s3_bucket.log_bucket.id
    prefix  = var.appname
    enabled = true
  }
  tags = merge(var.tags, { "Name" = format("%s-%s-alb", var.appname, var.env) })
}


resource "aws_lb" "network" {
  count                      = var.load_balancer_type == "network" ? 1 : 0
  name                       = format("%s-%s-nlb", var.appname, var.env)
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  subnets                    = var.subnets
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.log_bucket.id
    prefix  = var.appname
    enabled = true
  }
  tags = merge(var.tags, { "Name" = format("%s-%s-nlb", var.appname, var.env) })
}

# resource "aws_lb_listener" "this" {
#   count             = var.load_balancer_type == "application" ? 1 : 0
#   load_balancer_arn = aws_lb.application[count.index].arn
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:041744643314:targetgroup/tg1/35dc4086725ebda3"
#   }

# }


# resource "aws_lb_listener_rule" "this" {
#   for_each     = var.load_balancer_type == "application" ? var.listener_rule : null
#   listener_arn = aws_lb_listener.this[0].arn
#   priority     = each.value.priority

#   # default_action {
#   #   type = "redirect"

#   #   redirect {
#   #     port        = "443"
#   #     protocol    = "HTTPS"
#   #     status_code = "HTTP_301"
#   #   }
#   # }
#   action {
#     type             = each.value.type
#     target_group_arn = each.value.target_group_arn
#   }

#   condition {
#     path_pattern {
#       values = each.value.path_pattern
#     }
#   }
# }

# resource "aws_lb_listener" "https" {
#   for_each          = var.load_balancer_type == "application" ? var.listener_rule : null
#   load_balancer_arn = aws_lb.application[count.index].arn
#   port              = var.https_port
#   protocol          = var.listener_protocol
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.certificate_arn
#   priority          = each.value.priority

#   action {
#     type             = each.value.type
#     target_group_arn = each.value.target_group_arn
#   }

#   condition {
#     path_pattern {
#       values = each.value.path_pattern
#     }
#   }
# }


# resource "aws_lb_target_group" "this" {
#   count    = var.load_balancer_type == "application" ? length(var.target_groups) : null
#   name     = lookup(var.target_groups[count.index], "name", null)
#   port     = lookup(var.target_groups[count.index], "port", null)
#   protocol = lookup(var.target_groups[count.index], "protocol", "HTTP")
#   vpc_id   = "vpc-0e6a1a6f9b745c32a"
#   dynamic "health_check" {
#     for_each = [lookup(var.target_groups[count.index], "health_check", {})]
#     content {
#       enabled             = lookup(health_check.value, "enabled", null)
#       healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
#       interval            = lookup(health_check.value, "interval", null)
#       matcher             = lookup(health_check.value, "matcher", null)
#       path                = lookup(health_check.value, "path", null)
#       port                = lookup(health_check.value, "port", null)
#       protocol            = lookup(health_check.value, "protocol", null)
#       timeout             = lookup(health_check.value, "timeout", null)
#       unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
#     }
#   }
# }

