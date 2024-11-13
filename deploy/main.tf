provider "aws" {
  region = var.aws_region
}

data "external" "microservices" {
  program = ["bash", "-c", <<EOT
    find ../services -maxdepth 1 -mindepth 1 -type d -exec basename {} \\;
  EOT]
}

resource "aws_ecr_repository" "microservices" {
  count = length(data.external.microservices.result)
  name  = element(data.external.microservices.result, count.index)
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  for_each = toset(data.external.microservices.result)

  function_name = "${each.key}-function"
  image_uri     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${each.key}:latest"
  package_type  = "Image"
  role          = var.lambda_execution_role
  create_package = false
  environment_variables = {
    AWS_REGION = var.aws_region
  }
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 1.0"

  name        = var.api_gateway_name
  description = "API Gateway for microservices"
  protocol_type = "HTTP"

  routes = [
    for service in data.external.microservices.result : {
      path = "/${service}"
      target = "integrations/${service}"
    }
  ]

  integrations = [
    for service in data.external.microservices.result : {
      integration_type = "AWS_PROXY"
      integration_uri  = module.lambda[service].invoke_arn
    }
  ]
}
