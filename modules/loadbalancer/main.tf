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

  # access_logs {
  #   bucket  = var.log_bucket
  #   prefix  = var.appname
  #   enabled = true
  # }
  tags = merge(var.tags, { "Name" = format("%s-%s-nlb", var.appname, var.env) })
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = format("%s-%s-log-%s", var.appname, var.env, random_string.this.result)
  tags   = merge(var.tags, { "Name" = format("%s-%s-nlb", var.appname, var.env) })
}


resource "random_string" "this" {
  length  = 3
  special = false
  number  = false
  upper   = false
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.log_bucket.id}/${var.appname}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.log_bucket.id}/${var.appname}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.log_bucket.id}"]
    actions   = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}