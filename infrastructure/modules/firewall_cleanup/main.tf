# CloudWatch

resource "aws_cloudwatch_event_rule" "cleanup_firewall" {
  name = var.name
  description = "Remove the exceptions from the firewall regularly"

  schedule_expression = "rate(2 days)"
}

resource "aws_cloudwatch_event_target" "cleanup_firewall_target" {
  rule = aws_cloudwatch_event_rule.cleanup_firewall.name
  target_id = "cleanup_firewall"
  arn = aws_lambda_function.cleanup_firewall_lambda.arn
}


# Lambda

resource "aws_lambda_permission" "cleanup_firewall_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_firewall_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.cleanup_firewall.arn
}

data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_role_policy_document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${var.name}:*",
    ]
  }

  statement {
    actions = [
      "ec2:DescribeSecurityGroups"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account_id}:security-group/${var.security_group}",
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.name}Lambda"
  path               = "/service-role/aws-http-knocking/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.name}LambdaPolicy"
  role = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_role_policy_document.json
}

resource "aws_lambda_function" "cleanup_firewall_lambda" {
  function_name     = var.name
  description       = "Remove exceptions from the firewall"
  role              = aws_iam_role.lambda_role.arn
  handler           = "src/Handler/CleanupFirewallHandler.handler"
  runtime           = "nodejs14.x"
  timeout           = "15"
  environment {
    variables = {
      securityGroupId = var.security_group
    }
  }
  filename          = var.lambda_path
  source_code_hash  = filebase64sha256(var.lambda_path)
}
