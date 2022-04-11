resource "aws_iam_role" "this" {
  name                = format("%s-%s-lc-role", var.appname, var.env)
  assume_role_policy  = data.aws_iam_policy_document.assume.json
  managed_policy_arns = [aws_iam_policy.policy.arn, "arn:aws:iam::aws:policy/AdministratorAccess"]
  tags                = var.tags
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name   = format("%s-%s-lc-policy", var.appname, var.env)
  path   = "/"
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["s3:*"]
  }
}