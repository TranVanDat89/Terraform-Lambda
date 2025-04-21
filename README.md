# Terraform-Lambda
## DynamoDB không nằm trong VPC nào cả.Khi ứng dụng (EC2, Lambda, RDS, ...) muốn truy cập DynamoDB thì mặc định nó phải đi qua Internet để đến endpoint của DynamoDB (dynamodb.ap-southeast-2.amazonaws.com). => VPC Endpoint hoặc qua Internet.
## RDS khác nếu cùng VPC thì có thể kết nối trực tiếp. RDS bắt buộc chọn VPC.