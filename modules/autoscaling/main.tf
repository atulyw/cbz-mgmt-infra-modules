data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


resource "aws_launch_configuration" "this" {
  name                        = format("%s-%s-lc", var.appname, var.env)
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  iam_instance_profile        = ""
  key_name                    = aws_key_pair.this.id
  security_groups             = [aws_security_group.this.id, var.security_group]
  associate_public_ip_address = false
  user_data                   = local.user_data

  root_block_device {
    volume_type           = lookup(var.root_block_device, "volume_type", "gp2")
    volume_size           = lookup(var.root_block_device, "volume_size", "20")
    delete_on_termination = lookup(var.root_block_device, "delete_on_termination", null)
    iops                  = lookup(var.root_block_device, "iops", null)
    encrypted             = lookup(var.root_block_device, "encrypted", "true")
  }

  # lifecycle {
  #   create_before_destroy = true
  # }

}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = format("%s-%s-key", var.appname, var.env)
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_security_group" "this" {
  name   = format("%s-%s-as-security", var.appname, var.env)
  vpc_id = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  dynamic "ingress" {
    for_each = var.lc_sg
    content {
      description = lookup(ingress.value, "description", null)
      from_port   = lookup(ingress.value, "port", null)
      to_port     = lookup(ingress.value, "port", null)
      protocol    = lookup(ingress.value, "protocol", "tcp")
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
    }
  }
  tags = var.tags
}


########autoscaling##############################
resource "aws_autoscaling_group" "this" {
  name                      = format("%s-%s-as", var.appname, var.env)
  max_size                  = lookup(var.autoscaling, "max_size", "1")
  min_size                  = lookup(var.autoscaling, "min_size", "1")
  desired_capacity          = lookup(var.autoscaling, "desired_capacity", "1")
  health_check_grace_period = lookup(var.autoscaling, "health_check_grace_period", "300")
  health_check_type         = lookup(var.autoscaling, "health_check_type", "ELB")
  force_delete              = true
  placement_group           = lookup(var.autoscaling, "placement_group", null)
  launch_configuration      = aws_launch_configuration.this.name
  vpc_zone_identifier       = var.subnets
  target_group_arns         = var.target_group_arns
}