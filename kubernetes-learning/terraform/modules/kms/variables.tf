# KMS Module Variables

variable "name" {
  description = "Name of the KMS key"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name))
    error_message = "Name must start with letter and contain only alphanumeric and hyphens."
  }
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "KMS key for EKS secrets encryption"
}

variable "alias" {
  description = "Alias for the KMS key"
  type        = string
  default     = null
  validation {
    condition     = var.alias == null || can(regex("^alias/[a-zA-Z0-9/_-]+$", var.alias))
    error_message = "Alias must start with 'alias/' and contain only alphanumeric, hyphens, underscores, and forward slashes."
  }
}

variable "deletion_window_in_days" {
  description = "Deletion window in days for the KMS key"
  type        = number
  default     = 7
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Enable multi-region key"
  type        = bool
  default     = false
}

variable "policy" {
  description = "Custom KMS key policy (if null, default policy will be used)"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
