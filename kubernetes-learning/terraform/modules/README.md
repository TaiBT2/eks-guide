# EKS Terraform Modules - Tự dựng

Bộ modules Terraform tự dựng cho EKS cluster, thay thế terraform-aws-modules để có control hoàn toàn và hiểu rõ từng component.

## 📁 Cấu trúc Modules

```
modules/
├── vpc/                 # VPC với subnets, NAT Gateway, VPC endpoints
├── eks/                 # EKS cluster với node groups và addons
├── kms/                 # KMS key cho EKS secrets encryption
├── irsa/                # IAM Roles for Service Accounts
├── waf/                 # WAFv2 Web ACL
└── security-groups/     # Security groups cho EKS và nodes
```

## 🚀 Sử dụng

### **1. VPC Module**
```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "my-eks"
  vpc_cidr          = "10.0.0.0/16"
  azs               = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets   = ["10.0.10.0/24", "10.0.20.0/24"]
  enable_nat_gateway = true
  enable_s3_endpoint = true
  enable_ecr_endpoints = true

  tags = {
    Environment = "prod"
    Owner       = "devops-team"
  }
}
```

### **2. EKS Module**
```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name                = "my-eks"
  cluster_version            = "1.29"
  subnet_ids                 = module.vpc.private_subnet_ids
  kms_key_arn               = module.kms.key_arn
  endpoint_private_access    = true
  endpoint_public_access     = true
  enabled_cluster_log_types  = ["api", "audit", "authenticator"]

  node_groups = {
    on_demand = {
      subnet_ids      = module.vpc.private_subnet_ids
      capacity_type   = "ON_DEMAND"
      instance_types  = ["m6i.large", "m5.large"]
      desired_size    = 2
      max_size        = 6
      min_size        = 2
    }
    spot = {
      subnet_ids      = module.vpc.private_subnet_ids
      capacity_type   = "SPOT"
      instance_types  = ["m6i.large", "m5.large", "m5a.large"]
      desired_size    = 0
      max_size        = 6
      min_size        = 0
    }
  }

  addons = {
    aws-ebs-csi-driver = {
      version            = "latest"
      resolve_conflicts = "OVERWRITE"
    }
  }

  enable_irsa = true
}
```

### **3. KMS Module**
```hcl
module "kms" {
  source = "../../modules/kms"

  name        = "my-eks-secrets"
  description = "KMS CMK for EKS secrets encryption"
  alias       = "alias/my-eks-secrets"
  aws_region  = "ap-northeast-1"

  tags = {
    Environment = "prod"
    Owner       = "devops-team"
  }
}
```

### **4. IRSA Module**
```hcl
module "alb_controller_irsa" {
  source = "../../modules/irsa"

  role_name           = "my-eks-alb-controller"
  policy_name         = "my-eks-alb-controller"
  policy_description  = "IRSA policy for AWS Load Balancer Controller"
  policy_document     = data.aws_iam_policy_document.alb_controller_policy.json
  oidc_provider_arn   = module.eks.oidc_provider_arn
  namespace           = "kube-system"
  service_account_name = "aws-load-balancer-controller"
}
```

### **5. WAF Module**
```hcl
module "waf" {
  source = "../../modules/waf"

  name        = "my-eks-wafv2"
  description = "WAFv2 Web ACL for ALB"
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
    },
    {
      name     = "AWS-AWSManagedRulesCommonRuleSet"
      priority = 1
      action   = "count"
      type     = "managed_rule_group"
      rule_group_name = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
      override_action = "none"
    }
  ]
}
```

### **6. Security Groups Module**
```hcl
module "security_groups" {
  source = "../../modules/security-groups"

  name       = "my-eks"
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = "10.0.0.0/16"
  aws_region = "ap-northeast-1"
}
```

## 🔧 Features

### **VPC Module Features:**
- ✅ VPC với DNS support
- ✅ Public/Private subnets
- ✅ Internet Gateway
- ✅ NAT Gateway (single hoặc multi-AZ)
- ✅ VPC Endpoints (S3, ECR)
- ✅ Route tables và associations
- ✅ Security groups cho VPC endpoints

### **EKS Module Features:**
- ✅ EKS cluster với encryption
- ✅ Managed node groups (On-Demand, Spot)
- ✅ EKS addons (EBS CSI, CoreDNS, etc.)
- ✅ IRSA support
- ✅ CloudWatch logging
- ✅ Security group integration
- ✅ Launch template support

### **KMS Module Features:**
- ✅ Customer-managed KMS key
- ✅ Key rotation
- ✅ Multi-region support
- ✅ Custom policies
- ✅ Alias support

### **IRSA Module Features:**
- ✅ OIDC trust policy
- ✅ Custom IAM policies
- ✅ Additional managed policies
- ✅ Service account integration

### **WAF Module Features:**
- ✅ Rate limiting rules
- ✅ AWS Managed Rule Groups
- ✅ IP set rules
- ✅ Geo match rules
- ✅ Regex pattern sets
- ✅ CloudWatch metrics

### **Security Groups Module Features:**
- ✅ EKS cluster security group
- ✅ EKS node security group
- ✅ ALB security group
- ✅ Node remote access security group
- ✅ Proper ingress/egress rules

## 📋 Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- AWS CLI configured
- Appropriate IAM permissions

## 🏷️ Tags

Tất cả modules đều support tags và sẽ merge với tags từ parent module.

## 🔒 Security

- Tất cả modules đều follow AWS security best practices
- IRSA được implement đúng cách với least privilege
- Security groups được configure với minimal required access
- KMS encryption được enable cho sensitive data

## 📊 Monitoring

- CloudWatch logging được enable
- WAF metrics được configure
- Security group rules được log

## 💰 Cost Optimization

- Spot instances support
- Single NAT Gateway option
- VPC endpoints để giảm NAT Gateway costs
- Proper resource sizing

## 🚀 Migration từ terraform-aws-modules

1. **Backup state hiện tại:**
   ```bash
   terraform state pull > backup.tfstate
   ```

2. **Update main.tf:**
   - Thay thế module calls
   - Update variable names
   - Update output references

3. **Plan và apply:**
   ```bash
   terraform plan
   terraform apply
   ```

## 📚 Documentation

Mỗi module có đầy đủ:
- Variables với validation
- Outputs với descriptions
- Examples trong README
- Comments trong code

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

MIT License - xem LICENSE file để biết thêm chi tiết.
