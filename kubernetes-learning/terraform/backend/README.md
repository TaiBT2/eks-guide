# Terraform Backend Setup

Hướng dẫn setup backend infrastructure cho Terraform sử dụng S3 và DynamoDB.

## 📁 Files

```
backend/
├── main.tf              # Main backend infrastructure
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values
└── README.md            # Documentation này
```

## 🚀 Quick Start

### **1. Cập nhật terraform.tfvars**

```hcl
# Cập nhật bucket name (phải unique globally)
bucket_name = "your-unique-terraform-state-bucket"
dynamodb_table_name = "terraform-state-lock"
aws_region = "ap-northeast-1"
```

### **2. Initialize và Deploy**

```bash
# Navigate to backend directory
cd eks/terraform/backend

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy backend infrastructure
terraform apply
```

### **3. Cập nhật backend.tf trong prod**

Sau khi deploy xong, cập nhật `backend.tf` trong thư mục `prod`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket"
    key            = "eks/prod/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

## 🔧 Backend Features

### **S3 Bucket:**
- ✅ **Versioning:** Tự động version state files
- ✅ **Encryption:** AES256 server-side encryption
- ✅ **Public Access Block:** Block tất cả public access
- ✅ **Lifecycle:** Tự động xóa old versions sau 30 ngày
- ✅ **Secure Transport:** Chỉ cho phép HTTPS connections
- ✅ **Access Control:** Restrict access chỉ cho AWS account

### **DynamoDB Table:**
- ✅ **Pay-per-request:** Chỉ trả tiền khi sử dụng
- ✅ **State Locking:** Ngăn concurrent modifications
- ✅ **High Availability:** Multi-AZ deployment
- ✅ **Encryption:** At-rest encryption

## 📋 Prerequisites

### **Required:**
- [ ] AWS CLI installed và configured
- [ ] Terraform >= 1.0
- [ ] Appropriate IAM permissions
- [ ] Unique S3 bucket name

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
                "s3:PutBucketPolicy",
                "s3:GetBucketPolicy",
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
                "dynamodb:DeleteItem",
                "dynamodb:UpdateTable"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetUser",
                "iam:GetRole"
            ],
            "Resource": "*"
        }
    ]
}
```

## 🔒 Security Features

### **S3 Security:**
- **Encryption:** AES256 server-side encryption
- **Access Control:** IAM-based access control
- **Public Access Block:** Block tất cả public access
- **Secure Transport:** Chỉ cho phép HTTPS
- **Bucket Policy:** Restrict access chỉ cho AWS account

### **DynamoDB Security:**
- **Encryption:** At-rest encryption
- **Access Control:** IAM-based access control
- **VPC Endpoints:** Có thể sử dụng VPC endpoints

## 💰 Cost Optimization

### **S3 Costs:**
- **Storage:** ~$0.023/GB/month
- **Requests:** ~$0.0004/1000 requests
- **Lifecycle:** Tự động xóa old versions

### **DynamoDB Costs:**
- **Pay-per-request:** Chỉ trả tiền khi sử dụng
- **Storage:** ~$0.25/GB/month
- **Read/Write:** ~$1.25/1M requests

## 🚨 Troubleshooting

### **Common Issues:**

#### **1. Bucket name already exists**
```
Error: BucketAlreadyExists
```
**Solution:** Thay đổi bucket name trong `terraform.tfvars`

#### **2. Access denied**
```
Error: AccessDenied
```
**Solution:** Check IAM permissions và AWS credentials

#### **3. Region mismatch**
```
Error: InvalidRegion
```
**Solution:** Đảm bảo region trong `terraform.tfvars` đúng

### **Debug Commands:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check S3 bucket
aws s3 ls s3://your-bucket-name

# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-state-lock

# Check Terraform state
terraform state list
```

## 🔄 Migration từ Local State

### **1. Backup local state**
```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup
```

### **2. Initialize backend**
```bash
# Initialize với backend
terraform init

# Migrate state
terraform init -migrate-state
```

### **3. Verify migration**
```bash
# Check state
terraform state list
terraform show
```

## 📊 Monitoring

### **CloudWatch Metrics:**
- S3 bucket metrics
- DynamoDB table metrics
- API call metrics

### **Cost Monitoring:**
- AWS Cost Explorer
- S3 storage costs
- DynamoDB usage costs

## 🧹 Cleanup

### **Destroy Backend:**
```bash
# WARNING: This will delete all state files!
terraform destroy

# Confirm destruction
yes
```

### **Manual Cleanup:**
```bash
# Delete S3 bucket
aws s3 rb s3://your-bucket-name --force

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-state-lock
```

## 📞 Support

Nếu gặp vấn đề:
1. Check AWS CloudTrail logs
2. Review IAM permissions
3. Check resource limits
4. Contact DevOps team

---

**Last Updated:** September 9, 2025  
**Terraform Version:** >= 1.0  
**AWS Provider:** >= 5.0
