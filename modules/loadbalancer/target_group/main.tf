resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = lookup(var.target_groups, "priority", null)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    path_pattern {
      values = [lookup(var.target_groups, "path_pattern", null)]
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  port        = lookup(var.target_groups, "port", null)
  protocol    = lookup(var.target_groups, "protocol", "HTTP")
  vpc_id      = var.vpc_id
  target_type = lookup(var.target_groups, "target_type", null)
  health_check {
    enabled             = lookup(var.target_groups, "enabled", true)
    healthy_threshold   = lookup(var.target_groups, "healthy_threshold", null)
    interval            = lookup(var.target_groups, "interval", null)
    matcher             = lookup(var.target_groups, "matcher", null)
    path                = lookup(var.target_groups, "path", null)
    port                = lookup(var.target_groups, "port", null)
    protocol            = lookup(var.target_groups, "protocol", null)
    timeout             = lookup(var.target_groups, "timeout", null)
    unhealthy_threshold = lookup(var.target_groups, "unhealthy_threshold", null)
  }
}
