# 🚀 Kubernetes Learning Hub

Welcome to your journey into the world of **Kubernetes**! This repository is designed to help beginners understand and master Kubernetes through hands-on practice with Amazon EKS.

## 🎯 Mục đích

Repository này được tạo ra để:
- **Giúp người mới** dễ dàng tiếp cận với Kubernetes
- **Học tập thực hành** với EKS cluster thực tế
- **Hiểu rõ** các khái niệm cơ bản của Kubernetes
- **Thực hành** với các add-ons và tools phổ biến
- **Xây dựng** kiến thức từ cơ bản đến nâng cao

## 📚 Học Kubernetes từ đâu?

### 🏁 Bắt đầu với hướng dẫn chi tiết
👉 **[Hướng dẫn Setup EKS từ A-Z](./eks-setup-guide.md)** - Hướng dẫn step-by-step hoàn chỉnh  
👉 **[Kubernetes 4-Day Learning Guide](./k8s-4day-learning-guide.md)** - Học Kubernetes trong 4 ngày cho developers  
👉 **[K8s Learning Path](./k8s-learning-path/README.md)** - Lộ trình học có cấu trúc từng ngày với bài tập chi tiết

### 🧩 Các khái niệm Kubernetes cơ bản

#### 1. **Pods** - Đơn vị nhỏ nhất
```yaml
# Pod đơn giản chạy nginx
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
```

#### 2. **Deployments** - Quản lý Pods
```yaml
# Deployment quản lý nhiều Pods
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3  # Chạy 3 Pods
  selector:
    matchLabels:
      app: nginx
```

#### 3. **Services** - Kết nối Pods
```yaml
# Service expose Pods ra ngoài
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

#### 4. **Ingress** - Quản lý traffic
```yaml
# Ingress route traffic đến services
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

## 🛠️ Cấu trúc Repository

```
📁 system-prod/
├── 📖 eks-setup-guide.md          # Hướng dẫn setup EKS chi tiết
├── 📖 k8s-4day-learning-guide.md  # Học Kubernetes trong 4 ngày
├── 📁 k8s-learning-path/          # Lộ trình học có cấu trúc
│   ├── 📁 day-1/                  # Ngày 1: Fundamentals
│   ├── 📁 day-2/                  # Ngày 2: Deployments & Scaling
│   ├── 📁 day-3/                  # Ngày 3: Networking & Ingress
│   └── 📁 day-4/                  # Ngày 4: Production & DevOps
├── 📁 kubernetes-learning/        # Kubernetes Learning Materials
│   ├── 📁 helm/                   # Helm charts cho add-ons
│   ├── 📁 manifests/              # Kubernetes manifests mẫu
│   └── 📁 terraform/              # Terraform infrastructure
├── 📁 helm-template/              # Template Helm chart
└── 📄 README.md                   # File này
```

## 🎓 Lộ trình học tập

### 📋 Bước 1: Chuẩn bị môi trường
- [ ] Cài đặt AWS CLI
- [ ] Cài đặt kubectl
- [ ] Cài đặt Helm
- [ ] Cài đặt eksctl

### 📋 Bước 2: Tạo EKS Cluster
- [ ] Đọc [hướng dẫn setup](./eks-setup-guide.md)
- [ ] Tạo VPC và networking
- [ ] Tạo EKS cluster
- [ ] Tạo node groups

### 📋 Bước 3: Học các khái niệm cơ bản
- [ ] **Pods**: Đơn vị nhỏ nhất chạy containers
- [ ] **Deployments**: Quản lý lifecycle của Pods
- [ ] **Services**: Kết nối và expose Pods
- [ ] **ConfigMaps & Secrets**: Quản lý configuration
- [ ] **Namespaces**: Tổ chức resources

### 📋 Bước 4: Thực hành với add-ons
- [ ] **Ingress NGINX**: Load balancing và routing
- [ ] **cert-manager**: Quản lý SSL certificates
- [ ] **Metrics Server**: Monitoring resources
- [ ] **Cluster Autoscaler**: Tự động scale nodes

### 📋 Bước 5: Nâng cao
- [ ] **Helm**: Package manager cho Kubernetes
- [ ] **Monitoring**: Prometheus & Grafana
- [ ] **Security**: RBAC và Pod Security
- [ ] **CI/CD**: GitOps với ArgoCD

## 🚀 Bắt đầu ngay

### 1. **Đọc hướng dẫn setup**
```bash
# Mở file hướng dẫn chi tiết
cat eks-setup-guide.md
```

### 2. **Tạo EKS cluster đầu tiên**
```bash
# Làm theo hướng dẫn step-by-step
# Thời gian: 30-45 phút
```

### 3. **Thực hành với examples**
```bash
# Deploy ứng dụng mẫu
kubectl apply -f examples/nginx-deployment.yaml
kubectl get pods
kubectl get services
```

## 🎯 Mục tiêu học tập

### ✅ Sau khi hoàn thành, bạn sẽ biết:
- [ ] **Kubernetes cơ bản**: Pods, Deployments, Services
- [ ] **EKS**: Tạo và quản lý cluster trên AWS
- [ ] **Networking**: Ingress, Load Balancers, DNS
- [ ] **Storage**: Persistent Volumes, EBS
- [ ] **Security**: IAM, RBAC, Pod Security
- [ ] **Monitoring**: Metrics, Logs, Alerting
- [ ] **DevOps**: CI/CD, GitOps, Automation

## 💡 Tips cho người mới

### 🔍 **Học từ thực hành**
- Không chỉ đọc lý thuyết, hãy thực hành ngay
- Thử nghiệm với các commands khác nhau
- Đừng sợ phá vỡ, có thể tạo lại cluster

### 📚 **Tài liệu tham khảo**
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/)
- [Helm Documentation](https://helm.sh/docs/)

### 🆘 **Khi gặp lỗi**
- Kiểm tra logs: `kubectl logs <pod-name>`
- Mô tả resources: `kubectl describe <resource>`
- Kiểm tra events: `kubectl get events`

## 🤝 Đóng góp

Repository này dành cho cộng đồng học tập:
- **Báo lỗi**: Tạo issue khi gặp vấn đề
- **Đóng góp**: Cải thiện hướng dẫn
- **Chia sẻ**: Kinh nghiệm học tập

## 📞 Hỗ trợ

- 📖 **Hướng dẫn chi tiết**: [eks-setup-guide.md](./eks-setup-guide.md)
- 🐛 **Báo lỗi**: Tạo issue trên GitHub
- 💬 **Thảo luận**: GitHub Discussions

---

**🎉 Chúc bạn học tập vui vẻ và thành công với Kubernetes!**
