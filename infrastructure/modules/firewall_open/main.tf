# Lambda

resource "aws_lambda_permission" "api_open_firewall_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_open_firewall_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = var.api_path_arn
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
      "ec2:AuthorizeSecurityGroupIngress"
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

resource "aws_lambda_function" "api_open_firewall_lambda" {
  function_name = var.name
  description   = "Open the firewall"
  role          = aws_iam_role.lambda_role.arn
  handler       = "src/Handler/OpenFirewallHandler.handler"
  runtime       = "nodejs22.x"
  timeout       = "15"
  environment {
    variables = {
      securityGroupId = var.security_group
      openPort = var.open_port
    }
  }
  filename      = var.lambda_path
  source_code_hash = filebase64sha256(var.lambda_path)
}
