variable "lambda_function_name" {
  type = string
  nullable = false
}

variable "lambda_filename" {
  type = string
  nullable = false
}

variable "dynamodb_table_name" {
  type = string
  nullable = false
}

variable "dynamodb_table_arn" {
  type = string
  nullable = false
}

variable "bucket_arn" {
  type = string
  nullable = false
}

# variable "lambda_security_group_ids" {
#   type = list(string)
#   nullable = false
# }

# variable "subnet_ids" {
#   type = list(string)
#   nullable = false
# }