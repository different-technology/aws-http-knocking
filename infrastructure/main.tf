


####################################
### This file is just an example ###
####################################



locals {
  aws_account_id          = "12345"
  region                  = "eu-central-1"
  security_group          = "sg-12345"
}

provider "aws" {
  region     = local.region
}

module "api_gateway_open_firewall" {
  source                          = "./modules/api_gateway_open_firewall"
  account_id                      = local.aws_account_id
  region                          = local.region
  api_domain_name                 = "api.domain.com"
  base_path                       = "my-firewall"
  domain_zone_id                  = "12345"
  open_firewall_lambda_invoke_arn = module.firewall_open.lambda_invoke_arn
}

module "firewall_open" {
  source            = "./modules/firewall_open"
  account_id        = local.aws_account_id
  region            = local.region
  name              = "OpenFirewall"
  api_path_arn      = module.api_gateway_open_firewall.api_path_arn
  security_group    = local.security_group
  open_port         = "22"
}

module "firewall_cleanup" {
  source            = "./modules/firewall_cleanup"
  account_id        = local.aws_account_id
  name              = "CleanupFirewall"
  region            = local.region
  security_group    = local.security_group
}
