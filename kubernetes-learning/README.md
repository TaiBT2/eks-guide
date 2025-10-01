# Kubernetes Learning Materials

Tài liệu học tập Kubernetes với Amazon EKS - từ cơ bản đến nâng cao.

#### Mục tiêu
- **Độ tin cậy**: Multi-AZ, autoscaling, self-healing, backup/restore.
- **Bảo mật**: IAM least privilege, IRSA, network policy, secrets an toàn, TLS.
- **Vận hành**: Observability, logging/metrics/tracing, GitOps/CI-CD, cost control.

#### Kiến trúc tổng quan
- **VPC riêng**: 3 AZ, public/private subnets, NAT Gateway cho private.
- **EKS**: 1 control plane managed, phiên bản Kubernetes LTS.
- **Node Groups**: Managed Node Groups (on-demand + spot), tách workload (prod vs sys).
- **Ingress**: AWS Load Balancer Controller (ALB), HTTPS end-to-end với ACM.
- **DNS**: Route53 + ExternalDNS (quản lý record tự động).
- **TLS**: cert-manager + ACM, auto-renew.
- **Secrets**: AWS Secrets Manager/Parameter Store + IRSA; tùy chọn Sealed Secrets.
- **Observability**: CloudWatch Logs/Container Insights + Prometheus/Grafana (AMP/AMG tùy chọn).
- **Autoscaling**: Cluster Autoscaler, HPA/VPA (tùy nhu cầu), Karpenter (tuỳ chọn).
- **Security**: IRSA, Security Groups for Pods (tuỳ chọn), Calico/Cilium NetworkPolicy.
- **Backup/DR**: Velero (S3 + KMS) sao lưu namespace/volume; multi-region DR plan.

#### Yêu cầu tiên quyết
- AWS Account tách biệt cho prod; tối thiểu 3 AZ khả dụng.
- Domain trong Route53 (hoặc external), certificate ACM cho prod.
- Quyền IAM để tạo: VPC, EKS, IAM roles/policies, ALB, S3, KMS.

#### IaC đề xuất (ưu tiên Terraform)
- `terraform` modules: VPC, EKS, Node Groups, IAM roles (IRSA), addons.
- State backend: S3 + DynamoDB (state lock).
- Tách workspace: `prod` (và `staging` nếu có).

#### Addons chủ đạo (qua Helm/GitOps)
- aws-load-balancer-controller
- cluster-autoscaler (IRSA)
- external-dns (IRSA, giới hạn hosted zone)
- cert-manager (CA/ACM Issuer)
- metrics-server, kube-state-metrics
- logging: aws-for-fluent-bit hoặc fluent-bit to CloudWatch
- ingress-nginx (chỉ khi không dùng ALB Ingress cho mọi thứ)
- velero (backup)

#### Bảo mật & tuân thủ
- IAM: Least privilege; IRSA cho từng addon/workload.
- NetworkPolicy: default deny giữa namespaces, chỉ mở khi cần.
- Security Group: tách nhóm cho sys vs app; SG for Pods (nếu cần granular).
- Secrets: tránh env plain text; dùng Secrets Manager/SSM + CSI driver.
- KMS: mã hoá EBS, S3, Secrets; bật envelope encryption cho etcd (EKS secret encryption).
- Admission: OPA Gatekeeper/Kyverno policy (image registry allowlist, resource limits, TLS, …).

#### Observability
- Logs: CloudWatch Logs (log retention); phân tách namespace.
- Metrics: Prometheus (AMP) + Grafana (AMG) hoặc tự host.
- Tracing: AWS X-Ray hoặc OpenTelemetry Collector.
- Alerts: CloudWatch Alarms + Alertmanager (PagerDuty/Slack).

#### Networking & Ingress
- ALB Ingress (internet-facing/private) map theo namespace/app.
- WAFv2 gắn vào ALB (rate limit, OWASP rules).
- Route53 records managed bởi ExternalDNS (TTL hợp lý).
- PrivateLink/NLB nội bộ cho dịch vụ nội bộ (nếu cần).

#### Scaling & Chi phí
- Node groups: mix On-Demand/Spot, multiple instance types.
- Sizing: Requests/Limits chuẩn, HPA theo CPU/memory/custom.
- Schedules: scale to zero/giảm đêm cuối tuần (nếu phù hợp SLA).
- Rightsizing/cleanup: TTL jobs, xóa dangling resources.

#### Backup & Khôi phục
- Velero: backup định kỳ namespaces, CRDs, PVs (EBS snapshot).
- S3 versioning + lifecycle; test restore định kỳ.

#### CI/CD & GitOps
- GitHub Actions/GitLab CI: build, scan (SAST/DAST), image push ECR, helm chart.
- Argo CD/Flux: sync manifests/Helm charts vào cluster prod.
- Image policy: chỉ cho phép image đã ký (Cosign) từ ECR.

#### Quy trình triển khai (gợi ý)
1) Terraform: tạo VPC + EKS + Node Groups + IRSA cơ bản.
2) Helm/GitOps: cài addons core (metrics-server, aws-load-balancer-controller, external-dns, cert-manager).
3) Bật CloudWatch logging, thiết lập log retention.
4) Cấu hình cert-manager issuers, tạo ingress TLS.
5) Cài cluster-autoscaler/Karpenter, thiết lập quyền.
6) Cài logging/monitoring stack; thiết lập dashboards/alerts.
7) Cài velero + lịch backup.
8) Áp dụng NetworkPolicy/OPA/Kyverno.
9) Tích hợp CI/CD và rollout app.

#### Cấu trúc thư mục đề xuất (tương lai)
```
eks/
  terraform/
    modules/
      vpc/
      eks/
      node-group/
      iam/
    envs/
      prod/
        main.tf
        variables.tf
        backend.tf
        outputs.tf
  helm/
    addons/
      aws-load-balancer-controller/
      external-dns/
      cert-manager/
      cluster-autoscaler/
      velero/
  manifests/
    networking/
    security/
    monitoring/
```

#### Next steps
- Xác nhận yêu cầu SLA/RTO/RPO, domain, khu vực (region), ngân sách.
- Quyết định Terraform hay eksctl cho bootstrap ban đầu (đề xuất Terraform).
- Tôi có thể scaffold bộ Terraform/Helm ban đầu nếu bạn đồng ý.

#### Bảo mật & lưu trữ nâng cao (bổ sung)
- Secrets encryption: EKS được mã hoá bằng KMS CMK (đã cấu hình trong Terraform).
- EBS CSI: đã bật addon và `StorageClass` mặc định `gp3-encrypted`.
- IRSA: tách trust policy theo từng ServiceAccount (least privilege).
- NetworkPolicy: `default-deny` + cho phép DNS egress mẫu.
- Pod Security Admission: labels cho `default`, `kube-system`, `velero`.

#### Quickstart (prod)
1) Terraform backend S3 (ví dụ `prod`):
   - Tạo S3 bucket (versioning) và DynamoDB table cho state lock.
   - Cấu hình `eks/terraform/envs/prod/backend.tf` trong lần `terraform init`:
     - Dùng lệnh: `terraform init -backend-config="bucket=<s3-bucket>" -backend-config="key=eks/prod/terraform.tfstate" -backend-config="region=<region>" -backend-config="dynamodb_table=<lock-table>"`
2) Điền biến `eks/terraform/envs/prod/variables.tf` bằng `terraform.tfvars`:
```
name           = "prod-eks"
aws_region     = "ap-southeast-1"
vpc_cidr       = "10.20.0.0/16"
azs            = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
private_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
public_subnets  = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
cluster_version = "1.29"
```
3) Apply hạ tầng:
```
cd eks/terraform/envs/prod
terraform init -reconfigure -backend-config="bucket=<bucket>" -backend-config="key=eks/prod/terraform.tfstate" -backend-config="region=<region>" -backend-config="dynamodb_table=<table>"
terraform plan
terraform apply -auto-approve
```
4) Kết nối kubeconfig:
```
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region <region>
```
5) Cài addons bằng Helm (ví dụ):
```
helm repo add eks https://aws.github.io/eks-charts
helm repo add jetstack https://charts.jetstack.io
helm repo add fluent https://fluent.github.io/helm-charts
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# aws-load-balancer-controller (yêu cầu IRSA + OIDC đã bật)
# Tạo ServiceAccounts bằng Helm (lấy ARN từ Terraform outputs)
cat > irsa-values.yaml <<EOF
roles:
  albControllerArn: $(terraform output -raw irsa_role_arns | jq -r .alb_controller)
  externalDnsArn: $(terraform output -raw irsa_role_arns | jq -r .external_dns)
  clusterAutoscalerArn: $(terraform output -raw irsa_role_arns | jq -r .cluster_autoscaler)
  fluentBitArn: $(terraform output -raw irsa_role_arns | jq -r .fluent_bit)
  veleroArn: $(terraform output -raw irsa_role_arns | jq -r .velero)
EOF

helm upgrade --install irsa-serviceaccounts ../../helm/irsa-serviceaccounts \
  -n kube-system \
  -f irsa-values.yaml

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  -f ../../helm/addons/aws-load-balancer-controller/values.yaml \
  --set clusterName=$(terraform output -raw cluster_name) \
  --set region=<region> \
  --set vpcId=$(terraform output -raw vpc_id)

# metrics-server
helm upgrade --install metrics-server bitnami/metrics-server \
  -n kube-system \
  -f ../../helm/addons/metrics-server/values.yaml

# external-dns
helm upgrade --install external-dns bitnami/external-dns \
  -n kube-system \
  -f ../../helm/addons/external-dns/values.yaml \
  --set domainFilters={<your-domain.com>}

# cert-manager
helm upgrade --install cert-manager jetstack/cert-manager \
  -n cert-manager --create-namespace \
  -f ../../helm/addons/cert-manager/values.yaml

# cluster-autoscaler
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
  -n kube-system \
  -f ../../helm/addons/cluster-autoscaler/values.yaml \
  --set autoDiscovery.clusterName=$(terraform output -raw cluster_name) \
  --set awsRegion=<region>

# fluent-bit (CloudWatch)
helm upgrade --install fluent-bit eks/aws-for-fluent-bit \
  -n kube-system \
  -f ../../helm/addons/fluent-bit/values.yaml \
  --set cloudWatch.region=<region>

# velero (yêu cầu S3 và IRSA)
helm upgrade --install velero vmware-tanzu/velero \
  -n velero --create-namespace \
  -f ../../helm/addons/velero/values.yaml \
  --set configuration.backupStorageLocation[0].bucket=<s3-bucket> \
  --set configuration.backupStorageLocation[0].config.region=<region>
```

6) Lưu trữ & bảo mật sau khi cluster up:
```
kubectl apply -f ../../manifests/storage/storageclass-gp3.yaml
kubectl apply -f ../../manifests/security/networkpolicy-default-deny.yaml
kubectl apply -f ../../manifests/security/pod-security-namespaces.yaml
```

7) RBAC, aws-auth & SSO mapping:
```
# Sửa <account-id> và role names theo IAM/SSO của bạn
kubectl apply -f ../../manifests/security/aws-auth-configmap.yaml
kubectl apply -f ../../manifests/security/rbac-groups.yaml
```
Gợi ý: Map IAM Identity Center (SSO) → IAM Roles (DevOpsAdminRole, DevReadOnlyRole), sau đó update file `aws-auth-configmap.yaml`.

#### Ingress ALB cho nhiều domain (shared ALB)
- Mẫu manifest: `eks/manifests/networking/ingress-alb-multi-domain.yaml`
- Thay thế các placeholder:
  - `<region>`, `<account-id>`, `<cert-id>` trong `alb.ingress.kubernetes.io/certificate-arn`
  - `alb.ingress.kubernetes.io/wafv2-acl-arn` dùng output Terraform: `$(terraform output -raw wafv2_web_acl_arn)`
  - Hosts và services tương ứng (`app1-svc`, `app2-svc`, `api-svc`)
  - Domain list trong `external-dns.alpha.kubernetes.io/hostname`
- Áp dụng:
```
kubectl apply -f ../../manifests/networking/ingress-alb-multi-domain.yaml
```
- Ghi chú:
  - Annotation `alb.ingress.kubernetes.io/group.name` giúp nhiều Ingress dùng chung 1 ALB.
  - Dùng 1 certificate ACM multi-SAN hoặc wildcard cho nhiều domain.
  - ExternalDNS sẽ tạo/điều chỉnh các bản ghi Route53 trỏ về ALB.


#### IRSA/OIDC setup
- Module EKS đã bật OIDC (`enable_irsa = true`).
- Terraform đã tạo IAM roles/policies cho addons trong `eks/terraform/envs/prod/irsa.tf`.
- Cập nhật role ARN theo account thực tế (thay `123456789012`) trong `manifests/security/serviceaccounts.yaml`, hoặc tham chiếu outputs Terraform qua GitOps/templating.
- Áp dụng ServiceAccounts trước khi cài các chart tương ứng để Helm không tự tạo SA mặc định.




