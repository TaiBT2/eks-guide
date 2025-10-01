# Backend Setup Variables

variable "bucket_name" {
  description = "Name of the S3 bucket for EKS production Terraform state"
  type        = string
  default     = "eks-prod-terraform-state-bucket"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, start and end with alphanumeric character, and contain only hyphens."
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for EKS production state locking"
  type        = string
  default     = "eks-prod-terraform-state-lock"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.dynamodb_table_name))
    error_message = "DynamoDB table name must contain only alphanumeric characters, dots, hyphens, and underscores."
  }
}

variable "aws_region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "ap-northeast-1"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

variable "tags" {
  description = "Tags to apply to all backend resources"
  type        = map(string)
  default = {
    Environment = "prod"
    Owner       = "devops-team"
    CostCenter  = "engineering"
    System      = "eks-production"
    Purpose     = "terraform-backend"
    ManagedBy   = "terraform"
    Description = "Backend for EKS production environment"
  }
}
