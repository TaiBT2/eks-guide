# Terraform Backend Configuration
# S3 backend với DynamoDB state locking

terraform {
  backend "s3" {
    # S3 bucket để lưu trữ state file cho EKS production
    bucket = "eks-prod-terraform-state-bucket-190749975524"
    
    # Key path cho state file
    key = "eks/prod/terraform.tfstate"
    
    # AWS region
    region = "ap-northeast-1"
    
    # DynamoDB table cho state locking
    dynamodb_table = "eks-prod-terraform-state-lock"
    
    # Enable encryption
    encrypt = true
  }
}

# Data source để lấy thông tin AWS account
data "aws_caller_identity" "current" {}

# Data source để lấy thông tin AWS region
data "aws_region" "current" {}

# Outputs cho backend configuration
output "backend_bucket" {
  description = "S3 bucket name for Terraform state"
  value       = "your-terraform-state-bucket"
}

output "backend_region" {
  description = "AWS region for Terraform backend"
  value       = data.aws_region.current.name
}

output "backend_dynamodb_table" {
  description = "DynamoDB table name for state locking"
  value       = "terraform-state-lock"
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}