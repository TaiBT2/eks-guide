# Cluster Autoscaler

## Mục đích
Cluster Autoscaler tự động điều chỉnh kích thước của EKS node groups dựa trên nhu cầu tài nguyên của pods. Nó sẽ:
- **Scale up**: Thêm nodes khi có pods không thể schedule được
- **Scale down**: Xóa nodes khi không cần thiết (theo cấu hình)

## Các bước triển khai

### 1. Tạo IAM Role và Policy
```bash
# Tạo IAM role với trust policy
aws iam create-role --role-name prod-eks-cluster-autoscaler --assume-role-policy-document file://cluster-autoscaler-trust-policy.json

# Tạo IAM policy
aws iam create-policy --policy-name prod-eks-cluster-autoscaler --policy-document file://cluster-autoscaler-policy.json

# Attach policy to role
aws iam attach-role-policy --role-name prod-eks-cluster-autoscaler --policy-arn arn:aws:iam::190749975524:policy/prod-eks-cluster-autoscaler
```

### 2. Cài đặt EKS Pod Identity Agent
```bash
# Cài đặt EKS Pod Identity Agent addon
aws eks create-addon --cluster-name prod-eks --addon-name eks-pod-identity-agent --region ap-northeast-1
```

### 3. Deploy với Helm
```bash
# Add Helm repository
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

# Deploy Cluster Autoscaler
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --values .\eks\helm\addons\cluster-autoscaler\values.yaml
```

## Cấu hình

### Helm Values
```yaml
# Service Account với IRSA
serviceAccount:
  create: false
  name: cluster-autoscaler-aws-cluster-autoscaler
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::190749975524:role/prod-eks-cluster-autoscaler"

# Auto Scaling Groups
autoDiscovery:
  clusterName: prod-eks
  enabled: true

# Node groups configuration
nodeGroups:
  - name: "prod-eks-on-demand"
    minSize: 1
    maxSize: 10
  - name: "prod-eks-spot"
    minSize: 0
    maxSize: 6

# Scaling configuration
scaleDownDelayAfterAdd: 10m
scaleDownDelayAfterDelete: 10s
scaleDownDelayAfterFailure: 3m
scaleDownUnneededTime: 10m
scaleDownUtilizationThreshold: 0.5
skipNodesWithLocalStorage: false
skipNodesWithSystemPods: true
```

### IAM Permissions
Cluster Autoscaler cần các quyền sau:
- `autoscaling:*` - Quản lý Auto Scaling Groups
- `ec2:Describe*` - Mô tả EC2 instances và configurations
- `eks:DescribeNodegroup` - Mô tả EKS node groups

## Cách sử dụng

### 1. Kiểm tra trạng thái
```bash
# Kiểm tra pods
kubectl get pods -n kube-system -l "app.kubernetes.io/name=aws-cluster-autoscaler"

# Kiểm tra logs
kubectl logs -n kube-system deployment/cluster-autoscaler-aws-cluster-autoscaler
```

### 2. Cấu hình Auto Scaling Groups
Để Cluster Autoscaler quản lý node groups, cần thêm tags:
```bash
# Tag cho On-Demand node group
aws autoscaling create-or-update-tags \
  --tags ResourceId=prod-eks-on_demand-xxx,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true

aws autoscaling create-or-update-tags \
  --tags ResourceId=prod-eks-on_demand-xxx,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/prod-eks,Value=true,PropagateAtLaunch=true

# Tag cho Spot node group
aws autoscaling create-or-update-tags \
  --tags ResourceId=prod-eks-spot-xxx,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true

aws autoscaling create-or-update-tags \
  --tags ResourceId=prod-eks-spot-xxx,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/prod-eks,Value=true,PropagateAtLaunch=true
```

### 3. Test scaling
```bash
# Deploy test workload
kubectl create deployment nginx --image=nginx --replicas=10

# Kiểm tra scaling events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Troubleshooting

### 1. Lỗi IRSA
```bash
# Kiểm tra ServiceAccount annotation
kubectl get sa cluster-autoscaler-aws-cluster-autoscaler -n kube-system -o yaml

# Kiểm tra EKS Pod Identity Agent
kubectl get pods -n kube-system | grep pod-identity
```

### 2. Lỗi Auto Scaling Groups
```bash
# Kiểm tra ASG tags
aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[].Tags[?Key==`k8s.io/cluster-autoscaler/enabled`]'
```

### 3. Lỗi permissions
```bash
# Kiểm tra IAM role trust policy
aws iam get-role --role-name prod-eks-cluster-autoscaler

# Kiểm tra IAM policy
aws iam get-role-policy --role-name prod-eks-cluster-autoscaler --policy-name prod-eks-cluster-autoscaler
```

## Security Notes

1. **IRSA**: Sử dụng IAM Roles for Service Accounts thay vì AWS credentials
2. **Least Privilege**: Chỉ cấp quyền cần thiết cho Cluster Autoscaler
3. **Network**: Cluster Autoscaler chạy trong kube-system namespace
4. **RBAC**: Có quyền đọc pods, nodes, và PDBs

## Dependencies

- EKS Cluster với node groups
- EKS Pod Identity Agent addon
- IAM role và policy được cấu hình đúng
- Auto Scaling Groups được tag đúng

## Monitoring

### CloudWatch Metrics
- `cluster_autoscaler_scale_up_total`
- `cluster_autoscaler_scale_down_total`
- `cluster_autoscaler_scale_up_errors_total`
- `cluster_autoscaler_scale_down_errors_total`

### Logs
```bash
# Xem logs chi tiết
kubectl logs -n kube-system deployment/cluster-autoscaler-aws-cluster-autoscaler -f
```

## Best Practices

1. **Cấu hình scale down delays** phù hợp với workload
2. **Sử dụng Pod Disruption Budgets** để bảo vệ critical workloads
3. **Monitor scaling events** qua CloudWatch
4. **Test scaling behavior** trước khi deploy production
5. **Cấu hình resource requests/limits** cho pods
6. **Sử dụng multiple node groups** cho different workload types
