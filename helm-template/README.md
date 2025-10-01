# Helm Template - Application Chart

Chart chuẩn hóa để deploy ứng dụng lên EKS với đầy đủ tính năng production-ready.

## Tính năng chính
- **Deployment** với HPA, PDB, ServiceAccount (IRSA support)
- **Service** với ports tùy biến theo môi trường
- **Ingress** duy nhất hỗ trợ ALB Controller + ExternalDNS + cert-manager
- **NetworkPolicy** (tùy chọn) để bảo mật network
- **ConfigMap** và **Secret** support

## Cấu trúc thư mục
```
helm-template/
├── Chart.yaml                    # Metadata chart
├── values-example.yaml           # File values mẫu
├── values-*.yaml                 # Values theo môi trường
├── templates/
│   ├── deployment.yaml           # Deployment chính
│   ├── service.yaml              # Service
│   ├── ingress.yaml              # Ingress (ALB)
│   ├── hpa.yaml                  # Horizontal Pod Autoscaler
│   ├── pdb.yaml                  # Pod Disruption Budget
│   ├── serviceaccount.yaml       # ServiceAccount (IRSA)
│   ├── networkpolicy.yaml        # NetworkPolicy (tùy chọn)
│   └── configmap.yaml            # ConfigMap (tùy chọn)
└── README.md                     # Tài liệu này
```

## Yêu cầu tiên quyết
- EKS cluster với các addons:
  - AWS Load Balancer Controller
  - ExternalDNS
  - cert-manager
  - Metrics Server
- Image có sẵn trên ECR/registry
- `imagePullSecrets` đã tạo trong namespace

## Cách sử dụng

### 1. Tạo namespace
```bash
kubectl create namespace <namespace> || true
```

### 2. Deploy ứng dụng
```bash
# Sử dụng values mẫu
helm upgrade --install <release-name> ./helm-template \
  -n <namespace> -f ./helm-template/values-example.yaml

# Sử dụng values riêng cho môi trường
helm upgrade --install <release-name> ./helm-template \
  -n <namespace> -f ./helm-template/values-prod.yaml
```

### 3. Kiểm tra deployment
```bash
kubectl get pods,svc,ingress -n <namespace>
kubectl describe ingress <release-name> -n <namespace>
```

## Cấu hình quan trọng

### Basic Settings
```yaml
nameOverride: "my-app"        # Tên cơ sở cho resources
env: "prod"                   # Môi trường (suffix cho resources)
image:
  repository: "my-app"
  tag: "v1.0.0"
  pullPolicy: "IfNotPresent"
imagePullSecrets:
  - name: "ecr-secret"
```

### Service Ports (Tùy biến)
```yaml
service:
  type: ClusterIP
  ports:                      # Cấu hình ports tùy biến
    - name: http
      port: 80
      targetPort: 80
    - name: https
      port: 443
      targetPort: 80
```

### Ingress (ALB)
```yaml
ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /
    alb.ingress.kubernetes.io/success-codes: "200-399"
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:..."
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: "my-app.example.com"
      paths:
        - path: "/"
          pathType: "Prefix"
  tls:
    - hosts: ["my-app.example.com"]
      secretName: "my-app-tls"
```

### Autoscaling
```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

### Pod Disruption Budget
```yaml
pdb:
  enabled: true
  minAvailable: 1
```

### NetworkPolicy
```yaml
networkPolicy:
  enabled: false              # Bật để tạo default-deny policy
```

### ServiceAccount (IRSA)
```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/ROLE-NAME"
```

### Scheduling (NodeSelector, Tolerations, Affinity)
```yaml
nodeSelector: {}              # Chọn nodes cụ thể

tolerations:
  enabled: false              # Bật để thêm tolerations

affinity: {}                  # Node/Pod affinity rules
  # nodeAffinity:             # Chọn nodes theo labels
  # podAntiAffinity:          # Phân tán pods để HA
```


## Ví dụ deployment theo môi trường

### Production
```bash
helm upgrade --install poker-server ./helm-template \
  -n poker-prod -f ./helm-template/values-prod.yaml
```

### Staging
```bash
helm upgrade --install poker-server ./helm-template \
  -n poker-stag -f ./helm-template/values-stag.yaml
```

### Development
```bash
helm upgrade --install poker-server ./helm-template \
  -n poker-dev -f ./helm-template/values-dev.yaml
```

## Bảo mật

### IRSA (IAM Roles for Service Accounts)
- Tạo IAM role với trust policy cho EKS OIDC provider
- Annotate ServiceAccount với role ARN
- Pod sẽ có quyền AWS thông qua IRSA

### NetworkPolicy
- Bật `networkPolicy.enabled: true` để tạo default-deny policy
- Chỉ cho phép traffic cần thiết

### Secrets
- Không commit secrets vào values files
- Sử dụng Kubernetes Secrets hoặc External Secrets Operator
- Git credentials cho CronJobs nên dùng token có quyền hạn chế

## Troubleshooting

### Ingress không hoạt động
```bash
# Kiểm tra ALB Controller
kubectl get pods -n kube-system | grep aws-load-balancer-controller

# Kiểm tra Ingress events
kubectl describe ingress <release-name> -n <namespace>

# Kiểm tra ExternalDNS
kubectl logs -n kube-system deployment/external-dns
```

### Image pull errors
```bash
# Kiểm tra imagePullSecrets
kubectl get secrets -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
```

### HPA không scale
```bash
# Kiểm tra Metrics Server
kubectl top nodes
kubectl top pods -n <namespace>

# Kiểm tra HPA status
kubectl describe hpa <release-name>-<env> -n <namespace>
```


## Lưu ý quan trọng

1. **Namespace**: Chart sử dụng `{{ .Release.Namespace }}` thay vì hardcode namespace
2. **Service Ports**: Ưu tiên `service.ports` list, fallback về ports cũ nếu không có
3. **Ingress**: Chỉ có 1 template duy nhất, đơn giản hóa quản lý
4. **IRSA**: ServiceAccount được tạo tự động nếu `serviceAccount.create: true`
