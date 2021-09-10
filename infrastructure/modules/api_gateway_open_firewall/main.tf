
# Certificate

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.api_domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_verification_domain" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.domain_zone_id
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_verification_domain : record.fqdn]
}



# API Domain

resource "aws_route53_record" "api_domain" {
  name    = var.api_domain_name
  type    = "A"
  zone_id = var.domain_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_gateway_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gateway_domain.regional_zone_id
  }
}



# API Gateway

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "HTTP Knocking API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "api_gateway_domain" {
  domain_name              = var.api_domain_name
  regional_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api_prod_path" {
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.api_stage_prod.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_domain.domain_name
  base_path   = var.base_path
}

resource "aws_api_gateway_stage" "api_stage_prod" {
  stage_name    = "default"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  cache_cluster_size = "0.5"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.api_open_firewall_integration]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_resource" "api_open_firewall" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "open"
}

resource "aws_api_gateway_method" "api_open_firewall_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_open_firewall.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "api_open_firewall_prod_settings" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.api_stage_prod.stage_name
  method_path = "*/*"

  settings {
    caching_enabled         = false
    metrics_enabled         = false
    data_trace_enabled      = false
    throttling_rate_limit   = 5
    throttling_burst_limit  = 2
  }
}

resource "aws_api_gateway_integration" "api_open_firewall_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.api_open_firewall.id
  http_method             = aws_api_gateway_method.api_open_firewall_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.open_firewall_lambda_invoke_arn
}
