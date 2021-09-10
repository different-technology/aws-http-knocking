variable "region" {
  description = "The region of the lambda"
}

variable "account_id" {
  description = "The ID of the AWS account"
}

variable "domain_zone_id" {
  description = "The zone id of the domains"
}

variable "api_domain_name" {
  description = "The domain name of the api"
}

variable "base_path" {
  description = "The base path of the API (domain.com/base-path/...)"
}

variable "open_firewall_lambda_invoke_arn" {
  description = "The invoke_arn of the lambda to open the firewall"
}
