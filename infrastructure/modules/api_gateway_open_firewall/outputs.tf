output "api_path_arn" {
  value = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.api_open_firewall_get.http_method}${aws_api_gateway_resource.api_open_firewall.path}"
}
