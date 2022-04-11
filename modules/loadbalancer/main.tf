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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application[0].arn
  port              = lookup(var.http_listener, "port", "80")
  protocol          = lookup(var.http_listener, "protocol", "HTTP")
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

module "tg" {
  source            = "./target_group"
  for_each          = var.target_groups
  listener_arn      = aws_lb_listener.http.arn
  target_groups     = each.value
  target_group_name = each.key
  vpc_id            = var.vpc_id
}


# resource "aws_lb_listener_rule" "this" {
#   count = length(var.target_groups)
#   listener_arn = aws_lb_listener.http.arn
#   priority     = lookup(var.target_groups, "priority", null)

#   action {
#     type             = "forward"
#     target_group_arn = element([for tg in aws_lb_target_group.this : tg.arn], count.index)
#   }
#   condition {
#     path_pattern {
#       values = [element([for pv in var.target_groups : pv.path_pattern], count.index)]
#       #values = ["/test/*"]
#     }
#   }
# }

# resource "aws_lb_target_group" "this" {
#   for_each    = var.target_groups
#   name        = each.key
#   port        = lookup(each.value, "port", null)
#   protocol    = lookup(each.value, "protocol", "HTTP")
#   vpc_id      = var.vpc_id
#   target_type = lookup(each.value, "target_type", null)
#   health_check {
#     enabled             = lookup(each.value, "enabled", true)
#     healthy_threshold   = lookup(each.value, "healthy_threshold", null)
#     interval            = lookup(each.value, "interval", null)
#     matcher             = lookup(each.value, "matcher", null)
#     path                = lookup(each.value, "path", null)
#     port                = lookup(each.value, "port", null)
#     protocol            = lookup(each.value, "protocol", null)
#     timeout             = lookup(each.value, "timeout", null)
#     unhealthy_threshold = lookup(each.value, "unhealthy_threshold", null)
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

