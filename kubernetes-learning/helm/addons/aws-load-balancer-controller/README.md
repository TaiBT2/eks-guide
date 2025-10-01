# AWS Load Balancer Controller Configuration

## Mục đích (Purpose)

AWS Load Balancer Controller được triển khai để quản lý Application Load Balancer (ALB) và Network Load Balancer (NLB) trong EKS cluster. Nó cho phép tạo và quản lý load balancers thông qua Kubernetes Ingress và Service resources.

## Các bước triển khai (Deployment Steps)

### 1. Tạo IAM Role cho IRSA
```bash
# Tạo trust policy
cat > aws-load-balancer-controller-trust-policy.json << EOF
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
          "oidc.eks.ap-northeast-1.amazonaws.com/id/D96083A9D752126FC4E0B9A0B4C9A774:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
          "oidc.eks.ap-northeast-1.amazonaws.com/id/D96083A9D752126FC4E0B9A0B4C9A774:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Tạo IAM policy (sử dụng AWS managed policy)
aws iam create-role --role-name prod-eks-aws-load-balancer-controller --assume-role-policy-document file://aws-load-balancer-controller-trust-policy.json
aws iam attach-role-policy --role-name prod-eks-aws-load-balancer-controller --policy-arn arn:aws:iam::190749975524:policy/AWSLoadBalancerControllerIAMPolicy
```

### 2. Tạo ServiceAccount với IRSA
```bash
kubectl create serviceaccount aws-load-balancer-controller -n kube-system
kubectl annotate serviceaccount aws-load-balancer-controller -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::190749975524:role/prod-eks-aws-load-balancer-controller
```

### 3. Deploy AWS Load Balancer Controller với Helm
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --values ./eks/helm/addons/aws-load-balancer-controller/values.yaml
```

## Cấu hình (Configuration)

### Values.yaml
File `values.yaml` chứa cấu hình:

```yaml
# Cluster configuration
clusterName: prod-eks
region: ap-northeast-1
vpcId: vpc-xxxxxxxxx

# Service Account với IRSA
serviceAccount:
  create: false
  name: aws-load-balancer-controller
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::190749975524:role/prod-eks-aws-load-balancer-controller"

# Ingress Class
ingressClassParams:
  create: true
  name: alb
  spec:
    scheme: internet-facing
    ipAddressType: ipv4

# Resources
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi

# Security
podSecurityContext:
  fsGroup: 65534
  runAsNonRoot: true
  runAsUser: 65534

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 65534
```

## Kiểm tra trạng thái (Status Check)

```bash
# Kiểm tra pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Kiểm tra deployment
kubectl get deployment aws-load-balancer-controller -n kube-system

# Kiểm tra logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Kiểm tra IngressClass
kubectl get ingressclass
kubectl describe ingressclass alb
```

## Sử dụng (Usage)

### 1. Tạo Ingress với ALB
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/load-balancer-name: example-alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:ap-northeast-1:190749975524:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
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

### 2. Tạo Service với NLB
```yaml
apiVersion: v1
kind: Service
metadata:
  name: example-nlb-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  selector:
    app: example
```

### 3. Ingress với SSL/TLS (sử dụng cert-manager)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ssl-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    cert-manager.io/cluster-issuer: "aws-cert-manager"
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

## Annotations quan trọng (Important Annotations)

### ALB Annotations
- `kubernetes.io/ingress.class: alb` - Sử dụng ALB
- `alb.ingress.kubernetes.io/scheme: internet-facing` - Public ALB
- `alb.ingress.kubernetes.io/target-type: ip` - Target type
- `alb.ingress.kubernetes.io/load-balancer-name: my-alb` - Tên ALB
- `alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'` - Ports
- `alb.ingress.kubernetes.io/ssl-redirect: '443'` - Redirect HTTP to HTTPS
- `alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...` - SSL certificate

### NLB Annotations
- `service.beta.kubernetes.io/aws-load-balancer-type: "nlb"` - Sử dụng NLB
- `service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"` - Public NLB
- `service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"` - Cross-zone LB

## Troubleshooting

### Kiểm tra IRSA
```bash
# Kiểm tra ServiceAccount annotation
kubectl get sa aws-load-balancer-controller -n kube-system -o yaml

# Kiểm tra IAM role trust policy
aws iam get-role --role-name prod-eks-aws-load-balancer-controller
```

### Kiểm tra Load Balancer
```bash
# Kiểm tra ALB
aws elbv2 describe-load-balancers --region ap-northeast-1

# Kiểm tra Target Groups
aws elbv2 describe-target-groups --region ap-northeast-1

# Kiểm tra Listeners
aws elbv2 describe-listeners --load-balancer-arn <alb-arn>
```

### Logs
```bash
kubectl logs -n kube-system deployment/aws-load-balancer-controller
kubectl logs -n kube-system deployment/aws-load-balancer-controller --previous
```

### Events
```bash
kubectl get events -n kube-system --sort-by='.lastTimestamp'
kubectl describe ingress <ingress-name>
kubectl describe service <service-name>
```

## Security Notes

- Controller chạy với non-root user (65534)
- Read-only root filesystem
- Minimal capabilities
- IRSA thay vì AWS credentials
- Resource limits được áp dụng
- Pod security context được cấu hình

## Dependencies

- EKS cluster với OIDC provider
- IAM permissions cho ELB, EC2, VPC
- VPC với public/private subnets
- Security groups cho ALB/NLB
- Route53 (optional, cho custom domains)
- cert-manager (optional, cho SSL certificates)

## Monitoring

### CloudWatch Metrics
- ALB metrics: RequestCount, TargetResponseTime, HTTPCode_Target_2XX_Count
- NLB metrics: ActiveFlowCount, NewFlowCount, ProcessedBytes

### Prometheus Metrics
```yaml
# Enable metrics trong values.yaml
metrics:
  service:
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "8080"
      prometheus.io/path: "/metrics"
```

## Best Practices

1. **Sử dụng ALB cho HTTP/HTTPS traffic**
2. **Sử dụng NLB cho TCP/UDP traffic**
3. **Enable cross-zone load balancing cho NLB**
4. **Sử dụng SSL/TLS certificates từ ACM**
5. **Configure proper security groups**
6. **Monitor load balancer metrics**
7. **Use appropriate target types (ip vs instance)**
8. **Configure health checks properly**
