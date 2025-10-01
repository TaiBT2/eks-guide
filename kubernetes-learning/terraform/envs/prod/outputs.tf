# EKS Production Environment Outputs - Sử dụng modules tự dựng

# EKS Cluster Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks.cluster_status
}

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = module.vpc.private_subnet_cidrs
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = module.vpc.public_subnet_cidrs
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

# Node Group Outputs
output "node_groups" {
  description = "Map of EKS node groups"
  value       = module.eks.node_groups
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN for EKS node groups"
  value       = module.eks.node_group_iam_role_arn
}

output "node_group_iam_role_name" {
  description = "IAM role name for EKS node groups"
  value       = module.eks.node_group_iam_role_name
}

# IRSA Role ARNs
output "irsa_role_arns" {
  description = "Map of IRSA role ARNs for addons"
  value = {
    alb_controller     = module.alb_controller_irsa.role_arn
    external_dns       = module.external_dns_irsa.role_arn
    cluster_autoscaler = module.cluster_autoscaler_irsa.role_arn
    fluent_bit         = module.fluent_bit_irsa.role_arn
    velero             = module.velero_irsa.role_arn
  }
}

# KMS Outputs
output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.kms.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.kms.key_arn
}

output "kms_alias_name" {
  description = "Name of the KMS alias"
  value       = module.kms.alias_name
}

# WAF Outputs
output "wafv2_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = module.waf.web_acl_arn
}

output "wafv2_web_acl_id" {
  description = "ID of the WAFv2 Web ACL"
  value       = module.waf.web_acl_id
}

# OIDC Provider Outputs
output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = module.eks.oidc_provider_url
}

# CloudWatch Logs Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for cluster logs"
  value       = module.eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for cluster logs"
  value       = module.eks.cloudwatch_log_group_arn
}

# Addons Outputs
output "addons" {
  description = "Map of EKS addons"
  value       = module.eks.addons
}

# VPC Endpoints Outputs
output "vpc_endpoint_s3_id" {
  description = "ID of the S3 VPC endpoint"
  value       = module.vpc.vpc_endpoint_s3_id
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "ID of the ECR DKR VPC endpoint"
  value       = module.vpc.vpc_endpoint_ecr_dkr_id
}

output "vpc_endpoint_ecr_api_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = module.vpc.vpc_endpoint_ecr_api_id
}

# Security Group Outputs
output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.availability_zones
}
