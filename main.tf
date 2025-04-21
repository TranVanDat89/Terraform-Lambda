provider "aws" {
  region = var.region
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets in default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Default Security Group Modified"
  }
}

# Get main route table of VPC
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# VPC Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_route_table.default.id]
}

module "dynamodb" {
  source = "./modules/dynamodb"
  table_name = "FileMetadata"
}

module "bucket" {
  source             = "./modules/bucket"
  bucket_name        = "s3-to-dynamodb-20042025"
}

module "lambda" {
  source = "./modules/lambda"
  lambda_filename = "./sources/lambda_function_payload.zip"
  lambda_function_name = "S3ToDynamoDB"
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn = module.dynamodb.table_arn
  bucket_arn = module.bucket.bucket_arn
  lambda_security_group_ids = [aws_default_security_group.default.id]
  subnet_ids               = data.aws_subnets.default.ids
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.bucket.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

