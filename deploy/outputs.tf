output "api_gateway_endpoint" {
  description = "The endpoint of the API Gateway"
  value       = aws_api_gateway_deployment.api_gateway_deployment.invoke_url
}

output "customers_function_arn" {
  description = "The ARN of the customers Lambda function"
  value       = aws_lambda_function.customers_function.arn
}

output "orders_function_arn" {
  description = "The ARN of the orders Lambda function"
  value       = aws_lambda_function.orders_function.arn
}
