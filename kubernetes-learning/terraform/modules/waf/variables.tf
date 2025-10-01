# WAF Module Variables

variable "name" {
  description = "Name of the WAFv2 Web ACL"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Name must contain only alphanumeric and hyphens."
  }
}

variable "description" {
  description = "Description of the WAFv2 Web ACL"
  type        = string
  default     = "WAFv2 Web ACL for ALB"
}

variable "scope" {
  description = "Scope of the WAFv2 Web ACL (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Scope must be either REGIONAL or CLOUDFRONT."
  }
}

variable "default_action" {
  description = "Default action for the WAFv2 Web ACL (allow, block, count)"
  type        = string
  default     = "allow"
  validation {
    condition     = contains(["allow", "block", "count"], var.default_action)
    error_message = "Default action must be allow, block, or count."
  }
}

variable "cloudwatch_metrics_enabled" {
  description = "Enable CloudWatch metrics for the Web ACL"
  type        = bool
  default     = true
}

variable "metric_name" {
  description = "Metric name for CloudWatch"
  type        = string
  default     = null
}

variable "sampled_requests_enabled" {
  description = "Enable sampled requests for the Web ACL"
  type        = bool
  default     = true
}

variable "rules" {
  description = "List of WAFv2 rules"
  type = list(object({
    name     = string
    priority = number
    action   = string
    type     = string

    # Rate-based rule
    limit              = optional(number)
    aggregate_key_type = optional(string)

    # Managed rule group
    rule_group_name  = optional(string)
    vendor_name      = optional(string)
    override_action  = optional(string)

    # IP set rule
    ip_set_arn = optional(string)

    # Geo match rule
    country_codes = optional(list(string))

    # Visibility config
    cloudwatch_metrics_enabled = optional(bool, true)
    metric_name                = optional(string)
    sampled_requests_enabled   = optional(bool, true)
  }))
  default = []
}

variable "ip_sets" {
  description = "Map of IP sets"
  type = map(object({
    ip_address_version = string
    addresses          = list(string)
  }))
  default = {}
}

variable "regex_pattern_sets" {
  description = "Map of regex pattern sets"
  type = map(object({
    patterns = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
