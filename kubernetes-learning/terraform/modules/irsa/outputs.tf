# IRSA Module Outputs

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.main.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.main.name
}

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = aws_iam_policy.main.arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = aws_iam_policy.main.name
}

output "service_account_name" {
  description = "Name of the Kubernetes service account"
  value       = var.service_account_name
}

output "namespace" {
  description = "Kubernetes namespace of the service account"
  value       = var.namespace
}
