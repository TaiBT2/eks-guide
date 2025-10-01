# EKS Production Environment - Sử dụng modules tự dựng
# Thay thế terraform-aws-modules bằng modules tự dựng

# Provider configuration
provider "aws" {
  region = var.aws_region
}

# KMS Module
module "kms" {
  source = "../../modules/kms"

  name        = "${var.name}-eks-secrets"
  description = "KMS CMK for EKS secrets encryption (${var.name})"
  alias       = "alias/${var.name}-eks-secrets"
  aws_region  = var.aws_region

  tags = var.tags
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name               = var.name
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  aws_region        = var.aws_region
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  enable_s3_endpoint = var.enable_s3_endpoint
  enable_ecr_endpoints = var.enable_ecr_endpoints

  tags = var.tags
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  name       = var.name
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = var.vpc_cidr
  aws_region = var.aws_region

  tags = var.tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name                = var.name
  cluster_version            = var.cluster_version
  subnet_ids                 = module.vpc.private_subnet_ids
  kms_key_arn               = module.kms.key_arn
  endpoint_private_access    = var.endpoint_private_access
  endpoint_public_access     = var.endpoint_public_access
  public_access_cidrs        = var.public_access_cidrs
  cluster_security_group_ids = [module.security_groups.cluster_security_group_id]
  enabled_cluster_log_types  = var.enabled_cluster_log_types
  log_retention_in_days      = var.log_retention_in_days

  node_groups = {
    on_demand = {
      subnet_ids                    = module.vpc.private_subnet_ids
      capacity_type                 = "ON_DEMAND"
      instance_types               = var.node_instance_types
      ami_type                     = "AL2_x86_64"
      disk_size                    = var.node_disk_size
      desired_size                 = var.node_desired_size
      max_size                     = var.node_max_size
      min_size                     = var.node_min_size
      max_unavailable_percentage   = 25
      remote_access = var.node_remote_access != null ? {
        ec2_ssh_key               = var.node_remote_access.ec2_ssh_key
        source_security_group_ids = [module.security_groups.node_remote_access_security_group_id]
      } : null
      tags = merge(var.tags, {
        NodeGroup = "on-demand"
      })
    }
    spot = {
      subnet_ids                    = module.vpc.private_subnet_ids
      capacity_type                 = "SPOT"
      instance_types               = var.spot_instance_types
      ami_type                     = "AL2_x86_64"
      disk_size                    = var.node_disk_size
      desired_size                 = var.spot_desired_size
      max_size                     = var.spot_max_size
      min_size                     = var.spot_min_size
      max_unavailable_percentage   = 25
      tags = merge(var.tags, {
        NodeGroup = "spot"
      })
    }
  }

  addons = {
    aws-ebs-csi-driver = {
      version            = "v1.28.0-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
    coredns = {
      version            = "v1.11.1-eksbuild.4"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      version            = "v1.29.0-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      version            = "v1.15.4-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
  }

  enable_irsa = true

  tags = var.tags
}

# IRSA Modules for Addons
module "alb_controller_irsa" {
  source = "../../modules/irsa"

  role_name           = "${var.name}-alb-controller"
  policy_name         = "${var.name}-alb-controller"
  policy_description  = "IRSA policy for AWS Load Balancer Controller"
  policy_document     = data.aws_iam_policy_document.alb_controller_policy.json
  oidc_provider_arn   = module.eks.oidc_provider_arn
  namespace           = "kube-system"
  service_account_name = "aws-load-balancer-controller"

  tags = var.tags
}

module "external_dns_irsa" {
  source = "../../modules/irsa"

  role_name           = "${var.name}-external-dns"
  policy_name         = "${var.name}-external-dns"
  policy_description  = "IRSA policy for External DNS"
  policy_document     = data.aws_iam_policy_document.external_dns_policy.json
  oidc_provider_arn   = module.eks.oidc_provider_arn
  namespace           = "kube-system"
  service_account_name = "external-dns"

  tags = var.tags
}

module "cluster_autoscaler_irsa" {
  source = "../../modules/irsa"

  role_name           = "${var.name}-cluster-autoscaler"
  policy_name         = "${var.name}-cluster-autoscaler"
  policy_description  = "IRSA policy for Cluster Autoscaler"
  policy_document     = data.aws_iam_policy_document.cluster_autoscaler_policy.json
  oidc_provider_arn   = module.eks.oidc_provider_arn
  namespace           = "kube-system"
  service_account_name = "cluster-autoscaler"

  tags = var.tags
}

module "fluent_bit_irsa" {
  source = "../../modules/irsa"

  role_name           = "${var.name}-fluent-bit"
  policy_name         = "${var.name}-fluent-bit"
  policy_description  = "IRSA policy for Fluent Bit"
  policy_document     = data.aws_iam_policy_document.fluent_bit_policy.json
  oidc_provider_arn   = module.eks.oidc_provider_arn
  namespace           = "kube-system"
  service_account_name = "fluent-bit"

  tags = var.tags
}

module "velero_irsa" {
  source = "../../modules/irsa"

  role_name           = "${var.name}-velero"
  policy_name         = "${var.name}-velero"
  policy_description  = "IRSA policy for Velero"
  policy_document     = data.aws_iam_policy_document.velero_policy.json
  oidc_provider_arn   = module.eks.oidc_provider_arn
  namespace           = "velero"
  service_account_name = "velero"

  tags = var.tags
}

# WAF Module
module "waf" {
  source = "../../modules/waf"

  name        = "${var.name}-wafv2"
  description = "WAFv2 Web ACL for ALB via AWS Load Balancer Controller"
  scope       = "REGIONAL"
  default_action = "allow"

  rules = [
    {
      name     = "rate-limit-ip"
      priority = 0
      action   = "block"
      type     = "rate_based"
      limit    = 2000
      aggregate_key_type = "IP"
      cloudwatch_metrics_enabled = true
      metric_name = "rate-limit-ip"
      sampled_requests_enabled = true
    },
    {
      name     = "AWS-AWSManagedRulesCommonRuleSet"
      priority = 1
      action   = "count"
      type     = "managed_rule_group"
      rule_group_name = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
      override_action = "none"
      cloudwatch_metrics_enabled = true
      metric_name = "common"
      sampled_requests_enabled = true
    },
    {
      name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      priority = 2
      action   = "count"
      type     = "managed_rule_group"
      rule_group_name = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
      override_action = "none"
      cloudwatch_metrics_enabled = true
      metric_name = "bad-inputs"
      sampled_requests_enabled = true
    },
    {
      name     = "AWS-AWSManagedRulesSQLiRuleSet"
      priority = 3
      action   = "count"
      type     = "managed_rule_group"
      rule_group_name = "AWSManagedRulesSQLiRuleSet"
      vendor_name = "AWS"
      override_action = "none"
      cloudwatch_metrics_enabled = true
      metric_name = "sqli"
      sampled_requests_enabled = true
    }
  ]

  cloudwatch_metrics_enabled = true
  metric_name = "${var.name}-wafv2"
  sampled_requests_enabled = true

  tags = var.tags
}

# Data sources for IRSA policies
data "aws_iam_policy_document" "alb_controller_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:GetCoipPoolUsage",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "elasticloadbalancing:*",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:GetWebACL",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "tag:GetResources",
      "tag:TagResources",
      "tag:UntagResources"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    actions   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "fluent_bit_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "velero_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:RestoreObject"
    ]
    resources = ["arn:aws:s3:::*/*"]
  }
}
