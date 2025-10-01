# External DNS Configuration

## Mục đích (Purpose)

External DNS được triển khai để tự động quản lý DNS records trong Route53 dựa trên Kubernetes resources (Ingress, Service). Nó đồng bộ hóa DNS records với các services và ingress trong cluster, giúp tự động hóa việc quản lý DNS.

## Các bước triển khai (Deployment Steps)

### 1. Tạo IAM Role cho IRSA
```bash
# Tạo trust policy
cat > external-dns-trust-policy.json << EOF
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
          "oidc.eks.ap-northeast-1.amazonaws.com/id/D96083A9D752126FC4E0B9A0B4C9A774:sub": "system:serviceaccount:kube-system:external-dns",
          "oidc.eks.ap-northeast-1.amazonaws.com/id/D96083A9D752126FC4E0B9A0B4C9A774:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Tạo IAM policy
cat > external-dns-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:ChangeResourceRecordSets",
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListResourceRecordSets",
        "route53:ListHostedZones"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Tạo role và policy
aws iam create-role --role-name prod-eks-external-dns --assume-role-policy-document file://external-dns-trust-policy.json
aws iam create-policy --policy-name prod-eks-external-dns --policy-document file://external-dns-policy.json
aws iam attach-role-policy --role-name prod-eks-external-dns --policy-arn arn:aws:iam::190749975524:policy/prod-eks-external-dns
```

### 2. Tạo ServiceAccount với IRSA
```bash
kubectl create serviceaccount external-dns -n kube-system
kubectl annotate serviceaccount external-dns -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::190749975524:role/prod-eks-external-dns
```

### 3. Deploy External DNS với Helm
```bash
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update
helm upgrade --install external-dns external-dns/external-dns \
  --namespace kube-system \
  --values ./eks/helm/addons/external-dns/values.yaml
```

## Cấu hình (Configuration)

### Values.yaml
File `values.yaml` chứa cấu hình:

```yaml
# Policy và Registry
policy: sync
registry: txt
txtOwnerId: prod-eks
interval: 1m
provider: aws

# Sources để monitor
sources:
  - ingress
  - service
  - crd

# Service Account với IRSA
serviceAccount:
  create: false
  name: external-dns
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::190749975524:role/prod-eks-external-dns"

# AWS specific configuration
aws:
  region: "ap-northeast-1"
  zoneType: "public"
  preferCNAME: false
  evaluateTargetHealth: true

# Resources và Security
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi

# Logging
logLevel: info
logFormat: json
```

## Kiểm tra trạng thái (Status Check)

```bash
# Kiểm tra pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=external-dns

# Kiểm tra deployment
kubectl get deployment external-dns -n kube-system

# Kiểm tra logs
kubectl logs -n kube-system deployment/external-dns

# Kiểm tra ServiceAccount
kubectl get sa external-dns -n kube-system -o yaml
```

## Sử dụng (Usage)

### 1. Tạo Ingress với External DNS annotation
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    external-dns.alpha.kubernetes.io/hostname: example.infaxia.io
    external-dns.alpha.kubernetes.io/ttl: "300"
spec:
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

### 2. Tạo Service với External DNS annotation
```yaml
apiVersion: v1
kind: Service
metadata:
  name: example-service
  annotations:
    external-dns.alpha.kubernetes.io/hostname: api.infaxia.io
    external-dns.alpha.kubernetes.io/ttl: "300"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: example
```

### 3. Sử dụng với cert-manager
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ssl-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    external-dns.alpha.kubernetes.io/hostname: secure.infaxia.io
    cert-manager.io/cluster-issuer: "aws-cert-manager"
spec:
  tls:
  - hosts:
    - secure.infaxia.io
    secretName: secure-tls-secret
  rules:
  - host: secure.infaxia.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: secure-service
            port:
              number: 80
```

## Annotations quan trọng (Important Annotations)

### External DNS Annotations
- `external-dns.alpha.kubernetes.io/hostname: example.com` - DNS hostname
- `external-dns.alpha.kubernetes.io/ttl: "300"` - TTL cho DNS record
- `external-dns.alpha.kubernetes.io/alias: "true"` - Sử dụng ALIAS record
- `external-dns.alpha.kubernetes.io/aws-weight: "100"` - Weight cho weighted routing
- `external-dns.alpha.kubernetes.io/aws-set-identifier: "primary"` - Set identifier

### Domain Filters
- `external-dns.alpha.kubernetes.io/domain-filter: "example.com"` - Chỉ quản lý domain này
- `external-dns.alpha.kubernetes.io/exclude-domains: "internal.example.com"` - Loại trừ domain

## Troubleshooting

### Kiểm tra IRSA
```bash
# Kiểm tra ServiceAccount annotation
kubectl get sa external-dns -n kube-system -o yaml

# Kiểm tra IAM role trust policy
aws iam get-role --role-name prod-eks-external-dns

# Kiểm tra IAM policy
aws iam get-policy --policy-arn arn:aws:iam::190749975524:policy/prod-eks-external-dns
```

### Kiểm tra DNS Records
```bash
# Kiểm tra Route53 records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>

# Kiểm tra hosted zones
aws route53 list-hosted-zones --region ap-northeast-1
```

### Logs
```bash
kubectl logs -n kube-system deployment/external-dns
kubectl logs -n kube-system deployment/external-dns --previous
```

### Events
```bash
kubectl get events -n kube-system --sort-by='.lastTimestamp'
kubectl describe ingress <ingress-name>
kubectl describe service <service-name>
```

## Configuration Options

### Domain Filters
```yaml
# Chỉ quản lý domains cụ thể
domainFilters:
  - infaxia.io
  - zwallet.work
  - esports-bet.io

# Loại trừ domains
excludeDomains:
  - internal.infaxia.io
  - dev.infaxia.io
```

### TXT Records
```yaml
# TXT record configuration
txtOwnerId: prod-eks
txtPrefix: "external-dns-"
txtSuffix: "-prod"
```

### Sources
```yaml
# Các sources để monitor
sources:
  - ingress
  - service
  - crd
  - istio-gateway
  - istio-virtualservice
```

## Security Notes

- External DNS chạy với non-root user (65534)
- Read-only root filesystem
- Minimal capabilities
- IRSA thay vì AWS credentials
- Resource limits được áp dụng
- Chỉ có quyền cần thiết cho Route53

## Dependencies

- EKS cluster với OIDC provider
- Route53 hosted zones
- IAM permissions cho Route53
- AWS Load Balancer Controller (optional, cho ALB)
- cert-manager (optional, cho SSL certificates)

## Monitoring

### CloudWatch Metrics
- Route53 metrics: Queries, HealthCheckStatus
- External DNS logs trong CloudWatch

### Prometheus Metrics
```yaml
# Enable metrics trong values.yaml
metrics:
  enabled: true
  service:
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "7979"
      prometheus.io/path: "/metrics"
```

## Best Practices

1. **Sử dụng domain filters** để giới hạn domains được quản lý
2. **Cấu hình TTL phù hợp** cho DNS records
3. **Sử dụng TXT records** để tracking ownership
4. **Monitor logs** để phát hiện issues
5. **Sử dụng dry-run mode** khi test
6. **Cấu hình proper IAM permissions**
7. **Sử dụng annotations** để control behavior
8. **Backup Route53 zones** định kỳ

## Common Issues

### DNS Records không được tạo
- Kiểm tra IAM permissions
- Kiểm tra hosted zone ID
- Kiểm tra logs của external-dns

### DNS Records bị xóa
- Kiểm tra TXT ownership records
- Kiểm tra policy configuration
- Kiểm tra domain filters

### Performance Issues
- Tăng interval giữa các sync
- Giảm số lượng domains được monitor
- Tối ưu hóa resource limits
