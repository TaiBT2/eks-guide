# EKS Production Environment Variables - Sử dụng modules tự dựng

# Basic Configuration
variable "name" {
  description = "Name prefix for all resources"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name))
    error_message = "Name must start with letter and contain only alphanumeric and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least 2 availability zones must be specified."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "At least 2 public subnets must be specified."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "At least 2 private subnets must be specified."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
  default     = false
}

variable "enable_s3_endpoint" {
  description = "Enable S3 VPC endpoint"
  type        = bool
  default     = true
}

variable "enable_ecr_endpoints" {
  description = "Enable ECR VPC endpoints"
  type        = bool
  default     = true
}

# EKS Configuration
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
  validation {
    condition     = can(regex("^1\\.(2[0-9]|3[0-9])$", var.cluster_version))
    error_message = "Cluster version must be a valid Kubernetes version (1.20-1.39)."
  }
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS API server"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS API server"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks that can access the EKS API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types : contains([
        "api", "audit", "authenticator", "controllerManager", "scheduler"
      ], log_type)
    ])
    error_message = "Invalid cluster log type. Must be one of: api, audit, authenticator, controllerManager, scheduler."
  }
}

variable "log_retention_in_days" {
  description = "Number of days to retain cluster logs"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_in_days >= 1 && var.log_retention_in_days <= 3653
    error_message = "Log retention must be between 1 and 3653 days."
  }
}

# Node Group Configuration
variable "node_instance_types" {
  description = "Instance types for EKS nodes"
  type        = list(string)
  default     = ["m6i.large", "m5.large"]
  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "At least one instance type must be specified."
  }
}

variable "spot_instance_types" {
  description = "Instance types for EKS spot nodes"
  type        = list(string)
  default     = ["m6i.large", "m5.large", "m5a.large"]
  validation {
    condition     = length(var.spot_instance_types) > 0
    error_message = "At least one spot instance type must be specified."
  }
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.node_desired_size >= 0
    error_message = "Desired size must be non-negative."
  }
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 6
  validation {
    condition     = var.node_max_size >= 1
    error_message = "Max size must be at least 1."
  }
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.node_min_size >= 0
    error_message = "Min size must be non-negative."
  }
}

variable "spot_desired_size" {
  description = "Desired number of spot nodes"
  type        = number
  default     = 0
  validation {
    condition     = var.spot_desired_size >= 0
    error_message = "Spot desired size must be non-negative."
  }
}

variable "spot_max_size" {
  description = "Maximum number of spot nodes"
  type        = number
  default     = 6
  validation {
    condition     = var.spot_max_size >= 0
    error_message = "Spot max size must be non-negative."
  }
}

variable "spot_min_size" {
  description = "Minimum number of spot nodes"
  type        = number
  default     = 0
  validation {
    condition     = var.spot_min_size >= 0
    error_message = "Spot min size must be non-negative."
  }
}

variable "node_disk_size" {
  description = "Disk size for EKS nodes"
  type        = number
  default     = 50
  validation {
    condition     = var.node_disk_size >= 20 && var.node_disk_size <= 1000
    error_message = "Disk size must be between 20 and 1000 GB."
  }
}

variable "node_remote_access" {
  description = "Remote access configuration for nodes"
  type = object({
    ec2_ssh_key               = string
    source_security_group_ids = list(string)
  })
  default = null
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "prod"
    Owner       = "devops-team"
    CostCenter  = "engineering"
    System      = "eks-cluster"
    ManagedBy   = "terraform"
  }
}
