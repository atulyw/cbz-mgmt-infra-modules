resource "aws_lb" "application" {
  count                      = var.load_balancer_type == "application" ? 1 : 0
  name                       = format("%s-%s-alb", var.appname, var.env)
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = ["sg-03592006baf496b0d"]
  subnets                    = ["subnet-0299bb1c768e0b8b2", "subnet-0d6105e1ea61e0b66"]
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
  subnets                    = ["subnet-0299bb1c768e0b8b2", "subnet-0d6105e1ea61e0b66"]
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.log_bucket.id
    prefix  = var.appname
    enabled = true
  }
  tags = merge(var.tags, { "Name" = format("%s-%s-nlb", var.appname, var.env) })
}

resource "aws_lb_listener" "this" {
  count = var.load_balancer_type == "application" ? 1 : 0
  load_balancer_arn = aws_lb.application[count.index].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.load_balancer_type == "application" ? var.listener_rule : null
  listener_arn = aws_lb_listener.this[0].arn
  priority     = each.value.priority

  action {
    type             = each.value.type
    target_group_arn = each.value.target_group_arn
  }

  condition {
    path_pattern {
      values = each.value.path_pattern
    }
  }
}

resource "aws_lb_target_group" "test" {
  name     = "test-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0e6a1a6f9b745c32a"
}


# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end.arn
#   }
# }

