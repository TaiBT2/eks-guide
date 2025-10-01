# EKS Module Variables

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.cluster_name))
    error_message = "Cluster name must start with letter and contain only alphanumeric and hyphens."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
  validation {
    condition     = can(regex("^1\\.(2[0-9]|3[0-9])$", var.cluster_version))
    error_message = "Cluster version must be a valid Kubernetes version (1.20-1.39)."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs must be specified."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for EKS cluster encryption"
  type        = string
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

variable "cluster_security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

variable "encryption_resources" {
  description = "List of resources to encrypt"
  type        = list(string)
  default     = ["secrets"]
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

variable "node_groups" {
  description = "Map of EKS node groups"
  type = map(object({
    subnet_ids                    = list(string)
    capacity_type                 = string
    instance_types               = list(string)
    ami_type                     = string
    disk_size                    = number
    desired_size                 = number
    max_size                     = number
    min_size                     = number
    max_unavailable_percentage   = number
    remote_access = optional(object({
      ec2_ssh_key               = string
      source_security_group_ids = list(string)
    }))
    launch_template = optional(object({
      id      = string
      version = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "addons" {
  description = "Map of EKS addons"
  type = map(object({
    version                   = string
    resolve_conflicts        = string
    service_account_role_arn = optional(string)
  }))
  default = {}
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
