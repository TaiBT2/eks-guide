# Security Groups Module Outputs

output "cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.cluster.id
}

output "cluster_security_group_arn" {
  description = "ARN of the EKS cluster security group"
  value       = aws_security_group.cluster.arn
}

output "node_security_group_id" {
  description = "ID of the EKS node security group"
  value       = aws_security_group.node.id
}

output "node_security_group_arn" {
  description = "ARN of the EKS node security group"
  value       = aws_security_group.node.arn
}

output "node_remote_access_security_group_id" {
  description = "ID of the node remote access security group"
  value       = aws_security_group.node_remote_access.id
}

output "node_remote_access_security_group_arn" {
  description = "ARN of the node remote access security group"
  value       = aws_security_group.node_remote_access.arn
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.alb.arn
}
