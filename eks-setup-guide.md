# Hướng dẫn Setup EKS trên AWS Console - Step by Step

## Tổng quan
Hướng dẫn này sẽ hướng dẫn bạn tạo một EKS cluster hoàn chỉnh trên AWS Console với các thành phần cần thiết.

## Yêu cầu trước khi bắt đầu
- AWS Account với quyền tạo EKS cluster
- AWS CLI đã được cài đặt và cấu hình
- kubectl đã được cài đặt
- Helm 3.x đã được cài đặt
- eksctl đã được cài đặt
- IAM user/role có quyền: `AmazonEKSClusterPolicy`, `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`

## Bước 1: Tạo VPC và Networking

### Tổng quan về VPC và Networking

VPC (Virtual Private Cloud) là nền tảng mạng cho EKS cluster. Việc thiết lập VPC đúng cách giúp:

- **Network Isolation**: Tạo môi trường mạng riêng tư và an toàn
- **Subnet Management**: Tổ chức subnets cho public và private workloads
- **Security**: Kiểm soát traffic flow và access patterns
- **Scalability**: Hỗ trợ mở rộng cluster trong tương lai
- **High Availability**: Phân bổ resources across multiple Availability Zones

### 1.1 Tạo VPC
1. Đăng nhập AWS Console
2. Vào **VPC** service
3. Click **Create VPC**
4. Chọn **VPC and more**
5. Cấu hình:
   - **Name tag**: `eks-vpc`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - **Number of Availability Zones**: `3`
   - **Number of public subnets**: `3`
   - **Number of private subnets**: `3`
   - **NAT gateways**: `In 1 AZ` (để tiết kiệm chi phí)
   - **VPC endpoints**: `None`
   - **DNS options**: `Enable DNS hostnames` và `Enable DNS resolution`

6. Click **Create VPC**

### 1.2 Kiểm tra Subnets

#### Tại sao cần kiểm tra Subnets:
- **Network Architecture**: Xác nhận cấu trúc mạng đúng như thiết kế
- **IP Range**: Kiểm tra IP ranges không bị overlap
- **Route Tables**: Xác nhận route tables được cấu hình đúng
- **NAT Gateway**: Kiểm tra NAT Gateway hoạt động cho private subnets
- **Internet Gateway**: Xác nhận Internet Gateway cho public subnets
1. Vào **Subnets** trong VPC Console
2. Xác nhận có 6 subnets:
   - 3 public subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
   - 3 private subnets (10.0.11.0/24, 10.0.12.0/24, 10.0.13.0/24)

## Bước 2: Tạo IAM Role cho EKS Cluster

### Tổng quan về IAM Roles

IAM Roles là thành phần bảo mật quan trọng cho EKS cluster. Việc tạo IAM roles đúng cách giúp:

- **Security**: Kiểm soát quyền truy cập và permissions
- **Least Privilege**: Chỉ cấp quyền tối thiểu cần thiết
- **Service Integration**: Cho phép EKS cluster tương tác với AWS services
- **Audit Trail**: Theo dõi và audit các hoạt động
- **Compliance**: Đáp ứng các yêu cầu bảo mật và compliance

### 2.1 Tạo EKS Cluster Role
1. Vào **IAM** service
2. Click **Roles** → **Create role**
3. Chọn **AWS service** → **EKS** → **EKS - Cluster**
4. Click **Next**
5. Attach policy: `AmazonEKSClusterPolicy`
6. Click **Next**
7. **Role name**: `EKSClusterRole`
8. **Description**: `Role for EKS Cluster`
9. Click **Create role**

### 2.2 Tạo EKS Node Group Role

#### Tác dụng của EKS Node Group Role:
- **Worker Node Permissions**: Cấp quyền cho worker nodes tương tác với AWS services
- **CNI Plugin**: Hỗ trợ Container Network Interface plugin
- **ECR Access**: Truy cập Amazon Elastic Container Registry
- **CloudWatch Logs**: Gửi logs đến CloudWatch
- **Auto Scaling**: Hỗ trợ Auto Scaling Groups
- **Security Groups**: Quản lý security groups cho nodes
1. Click **Create role**
2. Chọn **AWS service** → **EC2**
3. Click **Next**
4. Attach các policies:
   - `AmazonEKSWorkerNodePolicy`
   - `AmazonEKS_CNI_Policy`
   - `AmazonEC2ContainerRegistryReadOnly`
5. Click **Next**
6. **Role name**: `EKSNodeGroupRole`
7. **Description**: `Role for EKS Node Group`
8. Click **Create role**

## Bước 3: Tạo EKS Cluster

### Tổng quan về EKS Cluster

EKS Cluster là trung tâm của Kubernetes infrastructure trên AWS. Việc tạo cluster đúng cách giúp:

- **Kubernetes Control Plane**: Cung cấp Kubernetes API server và control plane
- **High Availability**: Đảm bảo cluster luôn available và reliable
- **Security**: Tích hợp với AWS IAM và security services
- **Monitoring**: Tích hợp với CloudWatch và AWS monitoring tools
- **Networking**: Tích hợp với VPC và AWS networking services
- **Scalability**: Hỗ trợ scale từ development đến production workloads

### 3.1 Tạo Cluster
1. Vào **EKS** service
2. Click **Create cluster**
3. **Cluster configuration**:
   - **Name**: `my-eks-cluster`
   - **Kubernetes version**: Chọn version mới nhất
   - **Cluster service role**: Chọn `EKSClusterRole` đã tạo

4. **Networking**:
   - **VPC**: Chọn VPC đã tạo (`eks-vpc`)
   - **Subnets**: Chọn 3 private subnets
   - **Security groups**: Để mặc định
   - **Endpoint access**:
     - **Public access**: `Enabled`
     - **Private access**: `Enabled` (tùy chọn)

5. **Logging**: Chọn các log types cần thiết
6. Click **Create**

### 3.2 Chờ Cluster tạo xong

#### Tại sao cần chờ Cluster tạo xong:
- **Control Plane Setup**: EKS cần thời gian để setup control plane components
- **Networking Configuration**: Cấu hình networking và security groups
- **IAM Integration**: Tích hợp với IAM roles và policies
- **Health Checks**: Thực hiện health checks cho tất cả components
- **DNS Configuration**: Cấu hình DNS và service discovery
- **Monitoring Setup**: Thiết lập CloudWatch integration
- Thời gian: 10-15 phút
- Status sẽ chuyển từ "Creating" → "Active"

## Bước 4: Tạo Node Group

### Tổng quan về Node Group

Node Group là nhóm các EC2 instances chạy Kubernetes worker nodes. Việc tạo Node Group đúng cách giúp:

- **Worker Nodes**: Cung cấp compute resources cho Kubernetes pods
- **Auto Scaling**: Tự động scale nodes dựa trên demand
- **Instance Management**: Quản lý EC2 instances và lifecycle
- **Security**: Áp dụng security groups và IAM roles
- **Networking**: Kết nối với VPC và subnets
- **Monitoring**: Tích hợp với CloudWatch và monitoring tools

### 4.1 Tạo Managed Node Group
1. Trong EKS cluster, click tab **Compute**
2. Click **Add node group**
3. **Node group configuration**:
   - **Name**: `my-node-group`
   - **Node IAM role**: Chọn `EKSNodeGroupRole`

4. **Node group compute configuration**:
   - **Capacity type**: `On-Demand`
   - **Instance types**: `t3.medium` (hoặc `t3.small` để tiết kiệm)
   - **Disk size**: `20` GB
   - **AMI type**: `AL2_x86_64`

5. **Node group scaling configuration**:
   - **Desired size**: `2`
   - **Minimum size**: `1`
   - **Maximum size**: `4`

6. **Node group network configuration**:
   - **Subnets**: Chọn 3 private subnets
   - **SSH access**: 
     - **Allow remote access**: `Enabled`
     - **EC2 SSH key**: Chọn key pair có sẵn

7. Click **Create**

### 4.2 Chờ Node Group tạo xong

#### Tại sao cần chờ Node Group tạo xong:
- **EC2 Instance Launch**: Launch EC2 instances với EKS-optimized AMI
- **Kubernetes Node Registration**: Đăng ký nodes với Kubernetes control plane
- **CNI Plugin Setup**: Cài đặt Container Network Interface plugin
- **Security Group Configuration**: Cấu hình security groups cho nodes
- **IAM Role Attachment**: Attach IAM roles cho EC2 instances
- **Health Checks**: Thực hiện health checks cho nodes
- Thời gian: 5-10 phút
- Status sẽ chuyển từ "Creating" → "Active"

### 4.3 Tag Node Group cho Cluster Autoscaler

#### Tại sao cần tag Node Group:
- **Auto Scaling**: Cho phép Cluster Autoscaler nhận diện và quản lý Auto Scaling Group
- **Resource Management**: Giúp Cluster Autoscaler quyết định scale up/down
- **Cost Optimization**: Tự động terminate nodes khi không cần thiết
- **Integration**: Tích hợp với AWS Auto Scaling Groups
- **Monitoring**: Theo dõi và audit scaling activities
```bash
# Lấy Auto Scaling Group name
ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?contains(Tags[?Key==`kubernetes.io/cluster/my-eks-cluster`].Value, `owned`)].AutoScalingGroupName' --output text)

# Tag ASG cho Cluster Autoscaler
aws autoscaling create-or-update-tags \
  --tags ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=false

aws autoscaling create-or-update-tags \
  --tags ResourceId=$ASG_NAME,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/my-eks-cluster,Value=owned,PropagateAtLaunch=false
```

## Bước 5: Cấu hình kubectl và Helm

### Tổng quan về kubectl và Helm

kubectl và Helm là các công cụ cần thiết để quản lý Kubernetes cluster:

- **kubectl**: Command-line tool để tương tác với Kubernetes API
- **Helm**: Package manager cho Kubernetes applications
- **eksctl**: Command-line tool để quản lý EKS clusters
- **Configuration**: Cấu hình kubeconfig để kết nối với cluster
- **Authentication**: Thiết lập authentication với AWS và EKS

### 5.1 Cài đặt Helm và eksctl
```bash
# Cài đặt Helm (nếu chưa có)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Cài đặt eksctl (nếu chưa có)
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Kiểm tra cài đặt
helm version
eksctl version
```

### 5.2 Cập nhật kubeconfig

#### Tác dụng của kubeconfig:
- **Cluster Connection**: Kết nối kubectl với EKS cluster
- **Authentication**: Thiết lập authentication với AWS IAM
- **Context Management**: Quản lý multiple cluster contexts
- **Security**: Sử dụng AWS IAM roles cho authentication
- **Access Control**: Kiểm soát quyền truy cập dựa trên IAM policies
```bash
# Cập nhật kubeconfig cho cluster
aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster

# Kiểm tra kết nối
kubectl get nodes
kubectl get pods --all-namespaces
```

### 5.3 Kiểm tra cluster

#### Tại sao cần kiểm tra cluster:
- **Health Status**: Xác nhận cluster và nodes đang healthy
- **Resource Availability**: Kiểm tra resources có sẵn
- **System Components**: Xác nhận system pods đang chạy
- **Network Connectivity**: Kiểm tra kết nối mạng
- **Authentication**: Xác nhận authentication hoạt động đúng
```bash
# Xem thông tin cluster
kubectl cluster-info

# Xem nodes
kubectl get nodes -o wide

# Xem system pods
kubectl get pods -n kube-system
```

## Bước 6: Cài đặt Ingress NGINX Controller

### Tổng quan về Ingress NGINX Controller

Ingress NGINX Controller là thành phần quan trọng để expose services ra ngoài internet:

- **Load Balancing**: Phân phối traffic đến multiple backend services
- **SSL Termination**: Xử lý SSL/TLS encryption và decryption
- **Path-based Routing**: Route traffic dựa trên URL path
- **Host-based Routing**: Route traffic dựa trên domain name
- **Rate Limiting**: Kiểm soát rate limit và traffic shaping
- **Monitoring**: Tích hợp với monitoring và logging tools

### 6.1 Cài đặt Ingress NGINX Controller
```bash
# Thêm Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Cài đặt Ingress NGINX Controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"=internet-facing
```

### 6.2 Kiểm tra cài đặt

#### Tại sao cần kiểm tra Ingress Controller:
- **Service Status**: Xác nhận Ingress Controller đang chạy
- **Load Balancer**: Kiểm tra AWS Load Balancer được tạo
- **External IP**: Lấy external IP để cấu hình DNS
- **Health Checks**: Xác nhận health checks hoạt động
- **Configuration**: Kiểm tra cấu hình và annotations
```bash
# Kiểm tra pods
kubectl get pods -n ingress-nginx

# Kiểm tra service
kubectl get svc -n ingress-nginx

# Lấy external IP của LoadBalancer
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

### 6.3 Cấu hình DNS (Tùy chọn)

#### Tác dụng của DNS Configuration:
- **Domain Access**: Cho phép truy cập services qua domain name
- **SSL Certificates**: Hỗ trợ SSL certificates cho domain
- **Load Balancer Integration**: Tích hợp với AWS Load Balancer
- **External Access**: Expose services ra ngoài internet
- **Monitoring**: Theo dõi và monitor domain traffic
Nếu bạn có domain, cấu hình DNS record trỏ đến LoadBalancer IP:
```bash
# Lấy LoadBalancer IP
EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "LoadBalancer IP: $EXTERNAL_IP"
# Cấu hình DNS A record trỏ đến IP này
```

## Bước 7: Cài đặt cert-manager

### Tổng quan về cert-manager

cert-manager là thành phần quan trọng để quản lý SSL/TLS certificates:

- **Certificate Management**: Tự động tạo, cập nhật và gia hạn certificates
- **Let's Encrypt Integration**: Tích hợp với Let's Encrypt cho free SSL certificates
- **ACME Protocol**: Sử dụng ACME protocol để xác thực domain ownership
- **HTTP-01 Challenge**: Tự động xác thực domain qua HTTP challenge
- **DNS-01 Challenge**: Hỗ trợ DNS challenge cho wildcard certificates
- **Certificate Storage**: Lưu trữ certificates trong Kubernetes secrets

### 7.1 Cài đặt cert-manager
```bash
# Thêm Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Cài đặt cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.0 \
  --set installCRDs=true
```

### 7.2 Kiểm tra cài đặt

#### Tại sao cần kiểm tra cert-manager:
- **Pod Status**: Xác nhận cert-manager pods đang chạy
- **CRDs**: Kiểm tra Custom Resource Definitions được tạo
- **Webhook**: Xác nhận webhook hoạt động đúng
- **Health Status**: Kiểm tra health status của components
- **Configuration**: Xác nhận cấu hình đúng
```bash
# Kiểm tra pods
kubectl get pods -n cert-manager

# Kiểm tra CRDs
kubectl get crd | grep cert-manager

# Kiểm tra webhook
kubectl get validatingwebhookconfigurations | grep cert-manager
```

### 7.3 Cấu hình ClusterIssuer cho Let's Encrypt

#### Tác dụng của ClusterIssuer:
- **Certificate Authority**: Định nghĩa Certificate Authority (Let's Encrypt)
- **ACME Configuration**: Cấu hình ACME protocol và challenge methods
- **Email Notification**: Nhận thông báo về certificate expiration
- **Challenge Solver**: Cấu hình HTTP-01 challenge solver
- **Ingress Integration**: Tích hợp với Ingress NGINX Controller
- **Global Access**: ClusterIssuer có thể được sử dụng bởi tất cả namespaces
```bash
# Tạo file cluster-issuer.yaml
cat <<EOF > cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # Thay đổi email của bạn
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# Apply ClusterIssuer
kubectl apply -f cluster-issuer.yaml

# Kiểm tra ClusterIssuer
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-prod
```

## Bước 8: Cài đặt EKS Add-ons

### Tổng quan về EKS Add-ons

EKS Add-ons là các thành phần bổ sung giúp mở rộng chức năng của EKS cluster. Các add-ons được cài đặt trong hướng dẫn này bao gồm:

1. **VPC CNI**: Container Network Interface plugin cho EKS
2. **CoreDNS**: DNS server cho Kubernetes cluster
3. **kube-proxy**: Network proxy cho Kubernetes services
4. **AWS Load Balancer Controller**: Quản lý AWS Load Balancers (ALB/NLB) cho Kubernetes
5. **EBS CSI Driver**: Cung cấp persistent storage cho Kubernetes pods
6. **Cluster Autoscaler**: Tự động scale nodes dựa trên resource demand
7. **External DNS**: Tự động quản lý DNS records cho services
8. **Metrics Server**: Cung cấp resource metrics cho HPA và VPA
9. **AWS App Mesh Controller**: Service mesh cho microservices
10. **AWS Private CA Connector**: Quản lý certificates từ AWS Private CA

### Lợi ích tổng thể của EKS Add-ons:

- **Tự động hóa**: Giảm thiểu thao tác thủ công và human errors
- **Tối ưu chi phí**: Tự động scale và quản lý resources hiệu quả
- **High Availability**: Đảm bảo services luôn available và reliable
- **Security**: Tích hợp với AWS IAM và security best practices
- **Monitoring**: Cung cấp metrics và logging cho troubleshooting
- **Scalability**: Hỗ trợ scale từ development đến production workloads

### 8.1 Cài đặt VPC CNI Add-on

#### Tác dụng của VPC CNI:
- **Pod Networking**: Cung cấp networking cho pods trong EKS cluster
- **IP Address Management**: Quản lý IP addresses cho pods và services
- **Security Groups**: Tích hợp với AWS Security Groups
- **VPC Integration**: Tích hợp sâu với AWS VPC
- **Performance**: High-performance networking với low latency
- **Scalability**: Hỗ trợ scale đến hàng nghìn pods
- **Security**: Network isolation và security policies

```bash
# VPC CNI thường được cài đặt tự động khi tạo EKS cluster
# Kiểm tra VPC CNI đã được cài đặt
kubectl get pods -n kube-system | grep aws-node

# Kiểm tra VPC CNI configuration
kubectl get configmap aws-node -n kube-system -o yaml

# Kiểm tra VPC CNI logs
kubectl logs -n kube-system daemonset/aws-node
```

### 8.2 Cài đặt CoreDNS Add-on

#### Tác dụng của CoreDNS:
- **DNS Resolution**: Cung cấp DNS resolution cho pods và services
- **Service Discovery**: Cho phép pods tìm và giao tiếp với services
- **Load Balancing**: Hỗ trợ load balancing cho services
- **Custom DNS**: Hỗ trợ custom DNS records và configurations
- **Performance**: High-performance DNS với low latency
- **Reliability**: Đảm bảo DNS service luôn available

```bash
# CoreDNS thường được cài đặt tự động khi tạo EKS cluster
# Kiểm tra CoreDNS đã được cài đặt
kubectl get pods -n kube-system | grep coredns

# Kiểm tra CoreDNS configuration
kubectl get configmap coredns -n kube-system -o yaml

# Kiểm tra CoreDNS logs
kubectl logs -n kube-system deployment/coredns
```

### 8.3 Cài đặt kube-proxy Add-on

#### Tác dụng của kube-proxy:
- **Service Proxy**: Proxy traffic đến backend pods
- **Load Balancing**: Load balance traffic giữa multiple pods
- **Network Rules**: Duy trì network rules trên mỗi node
- **Service Discovery**: Hỗ trợ service discovery và routing
- **Performance**: High-performance network proxy
- **Reliability**: Đảm bảo network connectivity

```bash
# kube-proxy thường được cài đặt tự động khi tạo EKS cluster
# Kiểm tra kube-proxy đã được cài đặt
kubectl get pods -n kube-system | grep kube-proxy

# Kiểm tra kube-proxy configuration
kubectl get configmap kube-proxy -n kube-system -o yaml

# Kiểm tra kube-proxy logs
kubectl logs -n kube-system daemonset/kube-proxy
```

### 8.4 Cài đặt AWS Load Balancer Controller Add-on

#### Tác dụng của AWS Load Balancer Controller:
- **Load Balancing**: Tự động tạo và quản lý AWS Application Load Balancer (ALB) và Network Load Balancer (NLB)
- **Ingress Integration**: Tích hợp với Kubernetes Ingress để expose services ra ngoài
- **SSL Termination**: Hỗ trợ SSL/TLS termination tại load balancer
- **Path-based Routing**: Hỗ trợ routing dựa trên URL path
- **Health Checks**: Tự động health check cho backend services
- **Cost Optimization**: Chia sẻ load balancer cho nhiều services
```bash
# Tạo IAM policy cho AWS Load Balancer Controller
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.0/docs/install/iam_policy.json

# Tạo IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Tạo OIDC identity provider
eksctl utils associate-iam-oidc-provider --cluster my-eks-cluster --approve

# Tạo IAM service account
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name "AmazonEKSLoadBalancerControllerRole" \
  --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# Cài đặt AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 8.5 Cài đặt EBS CSI Driver Add-on

#### Tác dụng của EBS CSI Driver:
- **Persistent Storage**: Cung cấp persistent storage cho Kubernetes pods sử dụng AWS EBS volumes
- **Dynamic Provisioning**: Tự động tạo EBS volumes khi cần thiết
- **Volume Snapshots**: Hỗ trợ tạo và restore snapshots của EBS volumes
- **Multi-AZ Support**: Hỗ trợ volumes across multiple Availability Zones
- **Encryption**: Hỗ trợ encryption at rest cho EBS volumes
- **Performance**: Hỗ trợ gp3 volumes với performance tuning
- **Backup & Restore**: Tích hợp với AWS Backup service
```bash
# Tạo IAM policy cho EBS CSI Driver
curl -o ebs-csi-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json

# Tạo IAM policy
aws iam create-policy \
    --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
    --policy-document file://ebs-csi-policy.json

# Tạo IAM service account
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=ebs-csi-controller-sa \
  --role-name "AmazonEKS_EBS_CSI_DriverRole" \
  --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AmazonEKS_EBS_CSI_Driver_Policy \
  --approve

# Cài đặt EBS CSI Driver
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=false \
  --set controller.serviceAccount.name=ebs-csi-controller-sa
```

### 8.6 Cài đặt Cluster Autoscaler Add-on

#### Tác dụng của Cluster Autoscaler:
- **Auto Scaling**: Tự động scale nodes dựa trên resource demand và pod scheduling requirements
- **Cost Optimization**: Tự động terminate nodes khi không cần thiết để tiết kiệm chi phí
- **Resource Management**: Đảm bảo có đủ resources cho pods mà không lãng phí
- **Multi-Node Group Support**: Hỗ trợ scaling multiple node groups với different instance types
- **Pod Disruption Budget**: Tôn trọng Pod Disruption Budget khi scale down
- **Graceful Shutdown**: Gracefully drain nodes trước khi terminate
- **Integration**: Tích hợp với HPA (Horizontal Pod Autoscaler) và VPA (Vertical Pod Autoscaler)
```bash
# Tạo IAM policy cho Cluster Autoscaler
cat <<EOF > cluster-autoscaler-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Tạo IAM policy
aws iam create-policy \
    --policy-name AmazonEKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler-policy.json

# Tạo IAM service account
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --role-name "AmazonEKSClusterAutoscalerRole" \
  --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AmazonEKSClusterAutoscalerPolicy \
  --approve

# Cài đặt Cluster Autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Cập nhật cluster name trong deployment
kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict":"false"}},"spec":{"containers":[{"name":"cluster-autoscaler","image":"k8s.gcr.io/autoscaling/cluster-autoscaler:v1.21.0","command":["./cluster-autoscaler","--v=4","--stderrthreshold=info","--cloud-provider=aws","--skip-nodes-with-local-storage=false","--expander=least-waste","--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/my-eks-cluster","--balance-similar-node-groups","--scale-down-enabled=true","--scale-down-delay-after-add=10m","--scale-down-unneeded-time=10m"]}]}}}}'
```

### 8.7 Cài đặt External DNS Add-on

#### Tác dụng của External DNS:
- **DNS Automation**: Tự động tạo và quản lý DNS records cho Kubernetes services
- **Multi-Provider Support**: Hỗ trợ nhiều DNS providers (Route53, Cloudflare, Google Cloud DNS, etc.)
- **Service Discovery**: Tự động tạo DNS records cho LoadBalancer và Ingress services
- **Health Checks**: Tự động xóa DNS records khi services không available
- **Annotation-based**: Sử dụng annotations để cấu hình DNS records
- **TXT Records**: Tự động tạo TXT records cho domain ownership verification
- **Cost Optimization**: Chỉ tạo DNS records khi cần thiết
```bash
# Tạo IAM policy cho External DNS
cat <<EOF > external-dns-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

# Tạo IAM policy
aws iam create-policy \
    --policy-name ExternalDNSPolicy \
    --policy-document file://external-dns-policy.json

# Tạo IAM service account
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=external-dns \
  --role-name "ExternalDNSRole" \
  --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/ExternalDNSPolicy \
  --approve

# Cài đặt External DNS
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update

helm install external-dns external-dns/external-dns \
  --namespace kube-system \
  --set serviceAccount.create=false \
  --set serviceAccount.name=external-dns \
  --set provider=aws \
  --set aws.region=us-west-2 \
  --set txtOwnerId=my-eks-cluster
```

### 8.8 Cài đặt Metrics Server

#### Tác dụng của Metrics Server:
- **Resource Metrics**: Cung cấp resource usage metrics (CPU, memory) cho nodes và pods
- **HPA Support**: Hỗ trợ Horizontal Pod Autoscaler (HPA) để auto-scale pods
- **VPA Support**: Hỗ trợ Vertical Pod Autoscaler (VPA) để optimize resource requests
- **kubectl top**: Hỗ trợ lệnh `kubectl top nodes` và `kubectl top pods`
- **Lightweight**: Lightweight và efficient, không ảnh hưởng đến performance
- **Real-time**: Cung cấp real-time metrics với low latency
- **Integration**: Tích hợp với Kubernetes monitoring stack
```bash
# Tải và apply manifest
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Kiểm tra
kubectl get deployment metrics-server -n kube-system
```

### 8.9 Cài đặt AWS App Mesh Controller (Tùy chọn)

#### Tác dụng của AWS App Mesh Controller:
- **Service Mesh**: Cung cấp service mesh cho microservices
- **Traffic Management**: Quản lý traffic flow giữa services
- **Observability**: Monitoring và tracing cho microservices
- **Security**: mTLS và traffic encryption
- **Load Balancing**: Advanced load balancing strategies
- **Circuit Breaker**: Fault tolerance và resilience patterns

```bash
# Cài đặt AWS App Mesh Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Tạo IAM service account cho App Mesh
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=appmesh-system \
  --name=appmesh-controller \
  --role-name "AppMeshControllerRole" \
  --attach-policy-arn=arn:aws:iam::aws:policy/AWSAppMeshFullAccess \
  --approve

# Cài đặt App Mesh Controller
helm install appmesh-controller eks/appmesh-controller \
  --namespace appmesh-system \
  --create-namespace \
  --set serviceAccount.create=false \
  --set serviceAccount.name=appmesh-controller
```

### 8.10 Cài đặt AWS Private CA Connector (Tùy chọn)

#### Tác dụng của AWS Private CA Connector:
- **Certificate Management**: Quản lý certificates từ AWS Private CA
- **Security**: Enhanced security với private certificate authority
- **Compliance**: Đáp ứng các yêu cầu compliance về certificates
- **Integration**: Tích hợp với cert-manager
- **Automation**: Tự động tạo và quản lý certificates
- **Audit**: Audit trail cho certificate lifecycle

```bash
# Cài đặt AWS Private CA Connector
helm repo add aws-privateca-connector https://aws.github.io/aws-privateca-connector
helm repo update

# Tạo IAM service account
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=aws-privateca-connector-system \
  --name=aws-privateca-connector \
  --role-name "AWSPrivateCAConnectorRole" \
  --attach-policy-arn=arn:aws:iam::aws:policy/AWSPrivateCAFullAccess \
  --approve

# Cài đặt AWS Private CA Connector
helm install aws-privateca-connector aws-privateca-connector/aws-privateca-connector \
  --namespace aws-privateca-connector-system \
  --create-namespace \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-privateca-connector
```

### 8.11 Kiểm tra tất cả Add-ons

#### Tại sao cần kiểm tra Add-ons:
- **Health Check**: Đảm bảo tất cả add-ons đang chạy bình thường
- **Troubleshooting**: Phát hiện sớm các vấn đề để khắc phục
- **Performance**: Kiểm tra performance và resource usage
- **Integration**: Xác nhận các add-ons hoạt động đúng với nhau
- **Monitoring**: Thiết lập monitoring và alerting cho production
```bash
# Kiểm tra pods của các add-ons
kubectl get pods -n kube-system | grep -E "(aws-node|coredns|kube-proxy|aws-load-balancer|ebs-csi|cluster-autoscaler|external-dns|metrics-server)"

# Kiểm tra App Mesh Controller (nếu đã cài đặt)
kubectl get pods -n appmesh-system

# Kiểm tra AWS Private CA Connector (nếu đã cài đặt)
kubectl get pods -n aws-privateca-connector-system

# Kiểm tra services
kubectl get svc -n kube-system

# Kiểm tra storage classes
kubectl get storageclass

# Kiểm tra cluster autoscaler logs
kubectl logs -n kube-system deployment/cluster-autoscaler

# Kiểm tra external DNS logs
kubectl logs -n kube-system deployment/external-dns

# Kiểm tra EBS CSI driver logs
kubectl logs -n kube-system deployment/ebs-csi-controller

# Kiểm tra AWS Load Balancer Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### 8.12 Test EBS CSI Driver

#### Tại sao cần test EBS CSI Driver:
- **Functionality**: Xác nhận EBS CSI Driver hoạt động đúng
- **Storage Classes**: Kiểm tra storage classes có sẵn
- **Dynamic Provisioning**: Test dynamic volume provisioning
- **Volume Attachment**: Xác nhận volumes được attach đúng cách
- **Data Persistence**: Test data persistence across pod restarts
- **Performance**: Kiểm tra performance của EBS volumes
```bash
# Tạo file test-pvc.yaml
cat <<EOF > test-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: busybox
    command: ['sleep', '3600']
    volumeMounts:
    - name: test-volume
      mountPath: /data
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: test-pvc
EOF

# Apply và test
kubectl apply -f test-pvc.yaml

# Kiểm tra PVC
kubectl get pvc
kubectl describe pvc test-pvc

# Kiểm tra PV
kubectl get pv

# Cleanup
kubectl delete -f test-pvc.yaml
```

## Bước 9: Test Cluster với SSL

### Tổng quan về Testing

Testing là bước quan trọng để xác nhận cluster hoạt động đúng:

- **Functionality**: Kiểm tra tất cả components hoạt động đúng
- **SSL/TLS**: Xác nhận SSL certificates được tạo và hoạt động
- **Load Balancing**: Test load balancing và traffic routing
- **Security**: Kiểm tra security configurations
- **Performance**: Đánh giá performance và response times
- **Integration**: Xác nhận các components tích hợp đúng

### 9.1 Deploy ứng dụng test với Ingress và SSL
```bash
# Tạo file nginx-deployment.yaml
cat <<EOF > nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - nginx.example.com  # Thay đổi domain của bạn
    secretName: nginx-tls
  rules:
  - host: nginx.example.com  # Thay đổi domain của bạn
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
EOF

# Deploy
kubectl apply -f nginx-deployment.yaml

# Kiểm tra
kubectl get pods
kubectl get services
kubectl get ingress
kubectl get certificates
kubectl get certificaterequests
```

### 9.2 Kiểm tra SSL Certificate

#### Tại sao cần kiểm tra SSL Certificate:
- **Certificate Status**: Xác nhận certificate được tạo thành công
- **Validity**: Kiểm tra certificate validity và expiration date
- **Chain**: Xác nhận certificate chain hoàn chỉnh
- **Domain Verification**: Kiểm tra domain được verify đúng
- **Security**: Đảm bảo SSL/TLS encryption hoạt động
- **Browser Compatibility**: Test certificate với browsers
```bash
# Lấy external IP của Ingress Controller
kubectl get svc ingress-nginx-controller -n ingress-nginx

# Kiểm tra Ingress
kubectl describe ingress nginx-ingress

# Kiểm tra Certificate
kubectl describe certificate nginx-tls

# Kiểm tra CertificateRequest
kubectl get certificaterequests

# Kiểm tra Challenge (nếu có)
kubectl get challenges

# Test truy cập HTTP (sẽ redirect đến HTTPS)
curl -H "Host: nginx.example.com" http://EXTERNAL-IP

# Test truy cập HTTPS
curl -H "Host: nginx.example.com" https://EXTERNAL-IP -k

# Hoặc thêm vào /etc/hosts
echo "EXTERNAL-IP nginx.example.com" | sudo tee -a /etc/hosts
curl https://nginx.example.com -k
```

### 9.3 Kiểm tra SSL Certificate chi tiết

#### Tại sao cần kiểm tra SSL Certificate chi tiết:
- **Certificate Details**: Xem thông tin chi tiết về certificate
- **Issuer Information**: Kiểm tra certificate issuer và CA
- **Subject Information**: Xác nhận subject và domain information
- **Validity Period**: Kiểm tra not before và not after dates
- **Key Information**: Xem thông tin về public key và key size
- **Troubleshooting**: Debug các vấn đề về certificate
```bash
# Xem thông tin certificate
kubectl get secret nginx-tls -o yaml

# Decode certificate (nếu cần)
kubectl get secret nginx-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout

# Kiểm tra certificate chain
kubectl get secret nginx-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -issuer -subject -dates
```

## Bước 10: Cấu hình Security

### Tổng quan về Security Configuration

Security là thành phần quan trọng để bảo vệ EKS cluster:

- **Network Security**: Kiểm soát traffic flow với Security Groups
- **Access Control**: Quản lý quyền truy cập với IAM và RBAC
- **Encryption**: Mã hóa data in transit và at rest
- **Compliance**: Đáp ứng các yêu cầu bảo mật và compliance
- **Monitoring**: Theo dõi và audit security events
- **Best Practices**: Áp dụng security best practices

### 10.1 Tạo Security Group cho EKS
1. Vào **EC2** → **Security Groups**
2. Click **Create security group**
3. **Name**: `eks-cluster-sg`
4. **Description**: `Security group for EKS cluster`
5. **VPC**: Chọn VPC đã tạo
6. **Inbound rules**:
   - **Type**: `HTTPS`, **Port**: `443`, **Source**: `0.0.0.0/0`
   - **Type**: `SSH`, **Port**: `22`, **Source**: `Your IP`

### 10.2 Cấu hình Network ACLs

#### Tác dụng của Network ACLs:
- **Network-level Security**: Kiểm soát traffic ở network level
- **Subnet Protection**: Bảo vệ subnets khỏi unauthorized access
- **Traffic Filtering**: Filter traffic dựa trên IP addresses và ports
- **Compliance**: Đáp ứng các yêu cầu network security
- **Defense in Depth**: Tầng bảo mật bổ sung cho Security Groups
- **Audit Trail**: Log network traffic cho audit purposes
1. Vào **VPC** → **Network ACLs**
2. Tạo Network ACL cho private subnets
3. Cấu hình rules phù hợp

## Bước 11: Monitoring và Logging

### Tổng quan về Monitoring và Logging

Monitoring và Logging là thành phần quan trọng để quản lý EKS cluster:

- **Observability**: Theo dõi health và performance của cluster
- **Troubleshooting**: Debug và khắc phục sự cố
- **Alerting**: Cảnh báo khi có vấn đề xảy ra
- **Compliance**: Đáp ứng các yêu cầu audit và compliance
- **Cost Optimization**: Theo dõi và tối ưu chi phí
- **Capacity Planning**: Lập kế hoạch capacity cho tương lai

### 11.1 Cài đặt CloudWatch Container Insights
```bash
# Tải và apply manifest
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed 's/{{cluster_name}}/my-eks-cluster/;s/{{region_name}}/us-west-2/' | kubectl apply -f -
```

### 11.2 Cấu hình Log Groups

#### Tác dụng của Log Groups:
- **Centralized Logging**: Tập trung logs từ tất cả components
- **Log Retention**: Quản lý log retention policies
- **Search and Analysis**: Tìm kiếm và phân tích logs
- **Alerting**: Cảnh báo dựa trên log patterns
- **Compliance**: Đáp ứng các yêu cầu log retention
- **Cost Management**: Tối ưu chi phí log storage
1. Vào **CloudWatch** → **Log groups**
2. Tạo log group: `/aws/eks/my-eks-cluster/cluster`
3. Cấu hình retention policy

## Troubleshooting

### Tổng quan về Troubleshooting

Troubleshooting là kỹ năng quan trọng để quản lý EKS cluster:

- **Problem Identification**: Xác định nguyên nhân gốc của vấn đề
- **Log Analysis**: Phân tích logs để tìm thông tin debug
- **Health Checks**: Kiểm tra health status của components
- **Resource Monitoring**: Theo dõi resource usage và performance
- **Network Diagnostics**: Kiểm tra network connectivity
- **Security Issues**: Xác định và khắc phục security issues

### Lỗi thường gặp

1. **"aws-iam-authenticator: command not found"**
   ```bash
   # Cài đặt aws-iam-authenticator
   curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
   chmod +x ./aws-iam-authenticator
   sudo mv ./aws-iam-authenticator /usr/local/bin
   ```

2. **"Unable to connect to the server"**
   ```bash
   # Kiểm tra kubeconfig
   kubectl config view
   
   # Cập nhật lại kubeconfig
   aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster
   ```

3. **"nodes not ready"**
   ```bash
   # Kiểm tra node status
   kubectl describe nodes
   
   # Kiểm tra system pods
   kubectl get pods -n kube-system
   ```

4. **"Certificate not ready"**
   ```bash
   # Kiểm tra certificate status
   kubectl describe certificate nginx-tls
   
   # Kiểm tra certificate request
   kubectl describe certificaterequest
   
   # Kiểm tra challenge
   kubectl describe challenge
   
   # Kiểm tra cert-manager logs
   kubectl logs -n cert-manager deployment/cert-manager
   ```

5. **"Let's Encrypt rate limit"**
   ```bash
   # Sử dụng staging environment để test
   # Tạo staging ClusterIssuer
   cat <<EOF > cluster-issuer-staging.yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-staging
   spec:
     acme:
       server: https://acme-staging-v02.api.letsencrypt.org/directory
       email: your-email@example.com
       privateKeySecretRef:
         name: letsencrypt-staging
       solvers:
       - http01:
           ingress:
             class: nginx
   EOF
   
   kubectl apply -f cluster-issuer-staging.yaml
   ```

## Cleanup

### Tổng quan về Cleanup

Cleanup là bước quan trọng để tránh phí không cần thiết:

- **Cost Management**: Tránh phí cho resources không sử dụng
- **Resource Cleanup**: Xóa tất cả resources được tạo
- **IAM Cleanup**: Xóa IAM policies và roles
- **Network Cleanup**: Xóa VPC và networking resources
- **Storage Cleanup**: Xóa EBS volumes và snapshots
- **Monitoring Cleanup**: Xóa CloudWatch logs và metrics

### Xóa tài nguyên
```bash
# Xóa ứng dụng test
kubectl delete -f nginx-deployment.yaml

# Xóa ClusterIssuer
kubectl delete -f cluster-issuer.yaml

# Xóa cert-manager
helm uninstall cert-manager -n cert-manager

# Xóa Ingress NGINX Controller
helm uninstall ingress-nginx -n ingress-nginx

# Xóa các add-ons
helm uninstall aws-load-balancer-controller -n kube-system
helm uninstall aws-ebs-csi-driver -n kube-system
helm uninstall external-dns -n kube-system
kubectl delete deployment cluster-autoscaler -n kube-system

# Xóa App Mesh Controller (nếu đã cài đặt)
helm uninstall appmesh-controller -n appmesh-system

# Xóa AWS Private CA Connector (nếu đã cài đặt)
helm uninstall aws-privateca-connector -n aws-privateca-connector-system

# Xóa IAM policies (tùy chọn)
aws iam delete-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy
aws iam delete-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AmazonEKS_EBS_CSI_Driver_Policy
aws iam delete-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AmazonEKSClusterAutoscalerPolicy
aws iam delete-policy --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/ExternalDNSPolicy

# Xóa node group
aws eks delete-nodegroup --cluster-name my-eks-cluster --nodegroup-name my-node-group

# Xóa cluster
aws eks delete-cluster --name my-eks-cluster

# Xóa VPC (sau khi xóa cluster)
# Vào VPC Console và xóa VPC
```

## Chi phí ước tính

### Tổng quan về Chi phí

Chi phí EKS cluster bao gồm nhiều thành phần:

- **EKS Cluster**: ~$72/tháng
- **EC2 Instances (2x t3.medium)**: ~$60/tháng
- **NAT Gateway**: ~$45/tháng
- **Network Load Balancer (cho Ingress NGINX)**: ~$18/tháng
- **EBS Volumes (nếu sử dụng)**: ~$10/tháng
- **Route53 (nếu sử dụng External DNS)**: ~$0.50/tháng
- **CloudWatch Logs**: ~$5/tháng
- **Tổng cộng**: ~$210.50/tháng

### Tối ưu chi phí:
- **Spot Instances**: Sử dụng Spot instances cho non-production workloads
- **Reserved Instances**: Mua Reserved Instances cho production workloads
- **Auto Scaling**: Sử dụng Cluster Autoscaler để tối ưu chi phí
- **Resource Monitoring**: Theo dõi và tối ưu resource usage

## Tài liệu tham khảo

- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [External DNS](https://github.com/kubernetes-sigs/external-dns)
- [Helm Documentation](https://helm.sh/docs/)
- [eksctl Documentation](https://eksctl.io/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## Lưu ý quan trọng

### Tổng quan về Best Practices

Các lưu ý quan trọng để đảm bảo EKS cluster hoạt động tốt:

1. **Region**: Thay đổi region trong các lệnh nếu cần
2. **Account ID**: Thay `YOUR_ACCOUNT_ID` bằng account ID thực tế
3. **Email**: Thay đổi email trong ClusterIssuer để nhận thông báo từ Let's Encrypt
4. **Domain**: Thay đổi domain trong Ingress để phù hợp với domain thực tế
5. **Security**: Luôn cấu hình security groups và network ACLs phù hợp
6. **Backup**: Cấu hình backup cho persistent volumes
7. **Monitoring**: Thiết lập monitoring và alerting
8. **Cost Optimization**: Sử dụng Spot instances cho non-production workloads
9. **SSL Certificate**: Let's Encrypt có rate limit, sử dụng staging environment để test
10. **DNS**: Đảm bảo domain trỏ đúng đến LoadBalancer IP trước khi tạo certificate

### Production Considerations:
- **High Availability**: Sử dụng multiple AZs cho production
- **Disaster Recovery**: Thiết lập backup và disaster recovery
- **Security Hardening**: Áp dụng security best practices
- **Performance Tuning**: Tối ưu performance cho production workloads
- **Compliance**: Đáp ứng các yêu cầu compliance và audit
