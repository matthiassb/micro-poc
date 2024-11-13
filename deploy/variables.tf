variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "microservices-api-gateway"
}

variable "customers_function_filename" {
  description = "The filename of the customers Lambda function"
  type        = string
  default     = "../services/customers/index.js"
}

variable "customers_function_name" {
  description = "The name of the customers Lambda function"
  type        = string
  default     = "customers-function"
}

variable "orders_function_filename" {
  description = "The filename of the orders Lambda function"
  type        = string
  default     = "../services/orders/app.py"
}

variable "orders_function_name" {
  description = "The name of the orders Lambda function"
  type        = string
  default     = "orders-function"
}
