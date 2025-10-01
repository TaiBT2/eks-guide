# KMS Module Outputs

output "key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.main.key_id
}

output "key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.main.arn
}

output "key_rotation_enabled" {
  description = "Whether key rotation is enabled"
  value       = aws_kms_key.main.enable_key_rotation
}

output "key_multi_region" {
  description = "Whether the key is multi-region"
  value       = aws_kms_key.main.multi_region
}

output "alias_name" {
  description = "Name of the KMS alias"
  value       = var.alias != null ? aws_kms_alias.main[0].name : null
}

output "alias_arn" {
  description = "ARN of the KMS alias"
  value       = var.alias != null ? aws_kms_alias.main[0].arn : null
}
