# Cert-Manager Configuration

## Mục đích (Purpose)

Cert-Manager được triển khai để quản lý SSL/TLS certificates tự động trong EKS cluster. Nó tích hợp với AWS Certificate Manager (ACM) và Let's Encrypt để cung cấp certificates cho các services và ingress.

## Các bước triển khai (Deployment Steps)

### 1. Cài đặt CRDs
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.crds.yaml
```

### 2. Tạo IAM Role cho IRSA
```bash
# Tạo trust policy
cat > cert-manager-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::190749975524:oidc-provider/oidc.eks.ap-northeast-1.amazonaws.com/id/D96083A9D752126FC4E0B9A0B4C9A774"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.ap-northeast-1.amazonaws.com/id/D96083A9D752126FC4E0B9A0B4C9A774:sub": "system:serviceaccount:cert-manager:cert-manager",
          "oidc.eks.ap-northeast-1.amazonaws.com/id/D96083A9D752126FC4E0B9A0B4C9A774:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Tạo IAM policy
cat > cert-manager-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:RequestCertificate",
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:DeleteCertificate",
        "acm:AddTagsToCertificate",
        "acm:RemoveTagsFromCertificate",
        "acm:ListTagsForCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:GetChange",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Tạo role và policy
aws iam create-role --role-name prod-eks-cert-manager --assume-role-policy-document file://cert-manager-trust-policy.json
aws iam create-policy --policy-name prod-eks-cert-manager --policy-document file://cert-manager-policy.json
aws iam attach-role-policy --role-name prod-eks-cert-manager --policy-arn arn:aws:iam::190749975524:policy/prod-eks-cert-manager
```

### 3. Deploy cert-manager với Helm
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --values ./eks/helm/addons/cert-manager/values.yaml \
  --version v1.15.0
```

### 4. Cấu hình IRSA cho ServiceAccount
```bash
kubectl annotate serviceaccount cert-manager -n cert-manager \
  eks.amazonaws.com/role-arn=arn:aws:iam::190749975524:role/prod-eks-cert-manager

# Restart deployment để pick up IRSA role
kubectl rollout restart deployment/cert-manager -n cert-manager
```

### 5. Tạo ClusterIssuer
```bash
cat > aws-cert-manager-clusterissuer.yaml << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: aws-cert-manager
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@infaxia.io
    privateKeySecretRef:
      name: aws-cert-manager-account-key
    solvers:
    - dns01:
        route53:
          region: ap-northeast-1
      selector:
        dnsNames:
        - "*.infaxia.io"
        - "*.zwallet.work"
        - "*.esports-bet.io"
        - "infaxia.io"
        - "zwallet.work"
        - "esports-bet.io"
EOF

kubectl apply -f aws-cert-manager-clusterissuer.yaml
```

## Cấu hình (Configuration)

### Values.yaml
File `values.yaml` chứa cấu hình:
- **ServiceAccount**: Sử dụng IRSA với role `prod-eks-cert-manager`
- **Resources**: CPU/Memory limits và requests
- **Security**: Pod security context, non-root user
- **Node Selection**: Chạy trên Linux nodes
- **Tolerations**: Hỗ trợ SPOT instances
- **Monitoring**: Prometheus metrics (disabled cho đến khi có Prometheus)

### ClusterIssuer
- **ACME Server**: Let's Encrypt production
- **DNS Challenge**: Route53 DNS-01 validation
- **Domains**: Hỗ trợ wildcard và specific domains
- **Region**: ap-northeast-1 (Tokyo)

## Kiểm tra trạng thái (Status Check)

```bash
# Kiểm tra pods
kubectl get pods -n cert-manager

# Kiểm tra ClusterIssuer
kubectl get clusterissuer aws-cert-manager
kubectl describe clusterissuer aws-cert-manager

# Kiểm tra logs
kubectl logs -n cert-manager deployment/cert-manager
```

## Sử dụng (Usage)

### Tạo Certificate cho Ingress
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-tls
  namespace: default
spec:
  secretName: example-tls-secret
  issuerRef:
    name: aws-cert-manager
    kind: ClusterIssuer
  dnsNames:
  - example.infaxia.io
  - www.example.infaxia.io
```

### Sử dụng với Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    cert-manager.io/cluster-issuer: "aws-cert-manager"
    kubernetes.io/ingress.class: "alb"
spec:
  tls:
  - hosts:
    - example.infaxia.io
    secretName: example-tls-secret
  rules:
  - host: example.infaxia.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
```

## Troubleshooting

### Kiểm tra IRSA
```bash
# Kiểm tra ServiceAccount annotation
kubectl get sa cert-manager -n cert-manager -o yaml

# Kiểm tra IAM role trust policy
aws iam get-role --role-name prod-eks-cert-manager
```

### Kiểm tra Certificate status
```bash
kubectl get certificates
kubectl describe certificate <certificate-name>
kubectl get certificaterequests
kubectl describe certificaterequest <request-name>
```

### Logs
```bash
kubectl logs -n cert-manager deployment/cert-manager
kubectl logs -n cert-manager deployment/cert-manager-cainjector
kubectl logs -n cert-manager deployment/cert-manager-webhook
```

## Security Notes

- Cert-manager chạy với non-root user (1001)
- Read-only root filesystem
- Minimal capabilities
- IRSA thay vì AWS credentials
- Resource limits được áp dụng

## Dependencies

- EKS cluster với OIDC provider
- Route53 hosted zones cho domains
- IAM permissions cho ACM và Route53
- External DNS (optional, cho automatic DNS records)
