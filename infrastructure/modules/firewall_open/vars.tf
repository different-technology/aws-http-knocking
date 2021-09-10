variable "region" {
  description = "The region of the lambda"
}

variable "account_id" {
  description = "The ID of the AWS account"
}

variable "name" {
  description = "The name of the lambda and resources"
  default     = "OpenFirewall"
}

variable "lambda_path" {
  description = "Path of the lambda resources (zip file)"
  default     = "../lambda/Firewall/build/build.zip"
}

variable "api_path_arn" {
  description = "The ARN of the API gateway path"
}

variable "security_group" {
  description = "GroupID of the EC2 security group"
}

variable "open_port" {
  description = "The port to open"
}
