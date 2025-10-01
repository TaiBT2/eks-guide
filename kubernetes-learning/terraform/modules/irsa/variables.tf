# IRSA Module Variables

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.role_name))
    error_message = "Role name must start with letter and contain only alphanumeric and hyphens."
  }
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.policy_name))
    error_message = "Policy name must start with letter and contain only alphanumeric and hyphens."
  }
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "IRSA policy for EKS service account"
}

variable "policy_document" {
  description = "IAM policy document (JSON string)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account"
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 and 43200 seconds."
  }
}

variable "additional_policy_arns" {
  description = "List of additional managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
