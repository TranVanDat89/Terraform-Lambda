resource "aws_dynamodb_table" "this" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "file_name"
  attribute {
    name = "file_name"
    type = "S"
  }
}