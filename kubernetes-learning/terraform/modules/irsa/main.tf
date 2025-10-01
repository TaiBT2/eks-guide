# IRSA Module - Tự dựng
# Tạo IAM roles và policies cho EKS service accounts

# Data sources
data "aws_caller_identity" "current" {}

# OIDC Provider (if not already created)
data "aws_iam_openid_connect_provider" "eks" {
  arn = var.oidc_provider_arn
}

# Trust policy for IRSA
data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "/^.*oidc-provider/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "/^.*oidc-provider/", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }
}

# IAM Role
resource "aws_iam_role" "main" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.trust_policy.json
  max_session_duration = var.max_session_duration

  tags = merge(
    var.tags,
    {
      Name = var.role_name
      Type = "IRSA Role"
    }
  )
}

# IAM Policy
resource "aws_iam_policy" "main" {
  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy_document

  tags = merge(
    var.tags,
    {
      Name = var.policy_name
      Type = "IRSA Policy"
    }
  )
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

# Attach additional managed policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.main.name
  policy_arn = each.value
}
