# EKS Production Environment - Terraform Backend Setup

Hướng dẫn setup và sử dụng Terraform backend cho EKS production environment.

## 📁 Cấu trúc Files

```
prod/
├── backend.tf              # Terraform backend configuration
├── main.tf                 # Main EKS infrastructure (sử dụng modules tự dựng)
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── setup-backend.tf        # Backend infrastructure setup
├── setup-backend.sh        # Bash script để setup backend
├── setup-backend.ps1       # PowerShell script để setup backend
├── terraform.tfvars        # Variable values (tạo tự động)
└── README.md               # Documentation này
```

## 🚀 Quick Start

### **1. Setup Backend Infrastructure**

#### **Option A: Sử dụng Script (Recommended)**

**Windows (PowerShell):**
```powershell
# Chạy script PowerShell
.\setup-backend.ps1

# Hoặc với custom parameters
.\setup-backend.ps1 -BucketName "my-terraform-state-bucket" -Region "ap-northeast-1"
```

**Linux/Mac (Bash):**
```bash
# Make script executable
chmod +x setup-backend.sh

# Chạy script
./setup-backend.sh

# Hoặc với custom parameters
BUCKET_NAME="my-terraform-state-bucket" REGION="ap-northeast-1" ./setup-backend.sh
```

#### **Option B: Manual Setup**

```bash
# 1. Tạo S3 bucket
aws s3api create-bucket --bucket your-terraform-state-bucket --region ap-northeast-1

# 2. Enable versioning
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled

# 3. Enable encryption
aws s3api put-bucket-encryption --bucket your-terraform-state-bucket --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
}'

# 4. Block public access
aws s3api put-public-access-block --bucket your-terraform-state-bucket --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 5. Tạo DynamoDB table
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region ap-northeast-1
```

### **2. Initialize Terraform**

```bash
# Initialize Terraform với backend
terraform init

# Nếu có lỗi, force reinitialize
terraform init -reconfigure
```

### **3. Plan và Apply**

```bash
# Review planned changes
terraform plan

# Apply changes
terraform apply

# Auto-approve (không recommend cho production)
terraform apply -auto-approve
```

## 🔧 Backend Configuration

### **S3 Backend Features:**
- ✅ **State Storage:** Lưu trữ state file an toàn
- ✅ **Versioning:** Tự động version state files
- ✅ **Encryption:** Mã hóa state file với AES256
- ✅ **Access Control:** Block public access
- ✅ **Lifecycle:** Tự động xóa old versions

### **DynamoDB Features:**
- ✅ **State Locking:** Ngăn concurrent modifications
- ✅ **Pay-per-request:** Chỉ trả tiền khi sử dụng
- ✅ **High Availability:** Multi-AZ deployment
- ✅ **Encryption:** At-rest encryption

## 📋 Prerequisites

### **Required:**
- [ ] AWS CLI installed và configured
- [ ] Terraform >= 1.0
- [ ] Appropriate IAM permissions
- [ ] AWS Account ID và Region

### **IAM Permissions Required:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:GetBucketVersioning",
                "s3:PutBucketVersioning",
                "s3:GetBucketEncryption",
                "s3:PutBucketEncryption",
                "s3:GetBucketPublicAccessBlock",
                "s3:PutBucketPublicAccessBlock",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:DeleteTable",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
        }
    ]
}
```

## 🏗️ Infrastructure Components

### **Modules Used:**
- **VPC Module:** VPC, subnets, NAT Gateway, VPC endpoints
- **EKS Module:** EKS cluster, node groups, addons
- **KMS Module:** Encryption keys
- **IRSA Module:** IAM roles for service accounts
- **WAF Module:** Web Application Firewall
- **Security Groups Module:** Security groups

### **Resources Created:**
- EKS Cluster với encryption
- Managed Node Groups (On-Demand + Spot)
- VPC với public/private subnets
- NAT Gateway
- VPC Endpoints (S3, ECR)
- Security Groups
- IAM Roles và Policies
- WAFv2 Web ACL
- CloudWatch Log Groups

## 🔒 Security Features

### **Encryption:**
- EKS secrets encrypted với KMS
- S3 state files encrypted
- EBS volumes encrypted
- RDS encryption (nếu có)

### **Access Control:**
- IRSA cho service accounts
- Least privilege IAM policies
- Security groups với minimal access
- WAF protection

### **Monitoring:**
- CloudWatch logging
- EKS audit logs
- WAF metrics
- Security group monitoring

## 💰 Cost Optimization

### **Compute:**
- Spot instances cho non-critical workloads
- Right-sizing node groups
- Auto-scaling

### **Storage:**
- GP3 volumes
- S3 lifecycle policies
- EBS optimization

### **Networking:**
- Single NAT Gateway option
- VPC endpoints
- Efficient routing

## 🚨 Troubleshooting

### **Common Issues:**

#### **1. Backend initialization failed**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check S3 bucket exists
aws s3 ls s3://your-terraform-state-bucket

# Force reinitialize
terraform init -reconfigure
```

#### **2. State locking issues**
```bash
# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-state-lock

# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

#### **3. Permission denied**
```bash
# Check IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name <USERNAME>

# Check S3 bucket policy
aws s3api get-bucket-policy --bucket your-terraform-state-bucket
```

## 📊 Monitoring và Maintenance

### **Regular Tasks:**
- [ ] Review CloudWatch logs
- [ ] Check WAF metrics
- [ ] Monitor costs
- [ ] Update Terraform versions
- [ ] Review security groups
- [ ] Backup state files

### **State Management:**
```bash
# List state resources
terraform state list

# Show specific resource
terraform state show aws_eks_cluster.main

# Import existing resource
terraform import aws_eks_cluster.main cluster-name

# Remove resource from state
terraform state rm aws_eks_cluster.main
```

## 🔄 Updates và Upgrades

### **Terraform Version:**
```bash
# Check current version
terraform version

# Update Terraform
# Download latest version from https://terraform.io/downloads
```

### **AWS Provider:**
```bash
# Update provider version in main.tf
# Run terraform init -upgrade
terraform init -upgrade
```

### **EKS Cluster:**
```bash
# Update cluster version
# Change cluster_version in variables.tf
terraform plan
terraform apply
```

## 📞 Support

Nếu gặp vấn đề:
1. Check logs: `terraform plan -detailed-exitcode`
2. Check AWS CloudTrail
3. Review IAM permissions
4. Check resource limits
5. Contact DevOps team

---

**Last Updated:** September 9, 2025  
**Terraform Version:** >= 1.0  
**AWS Provider:** >= 5.0
