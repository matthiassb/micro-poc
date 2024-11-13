output "api_gateway_endpoint" {
  description = "The endpoint of the API Gateway"
  value       = aws_apigatewayv2_stage.api.invoke_url
}

output "customers_function_arn" {
  description = "The ARN of the customers Lambda function"
  value       = module.lambda["customers"].this_lambda_function_arn
}

output "orders_function_arn" {
  description = "The ARN of the orders Lambda function"
  value       = module.lambda["orders"].this_lambda_function_arn
}

output "microservices_function_arns" {
  description = "The ARNs of the microservices Lambda functions"
  value       = { for k, v in module.lambda : k => v.this_lambda_function_arn }
}
