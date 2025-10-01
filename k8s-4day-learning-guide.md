# 🚀 Kubernetes 4-Day Learning Guide for Developers

Hướng dẫn học Kubernetes trong 4 ngày dành cho developers - từ cơ bản đến thực hành.

## 📅 **Lộ trình 4 ngày**

### **Ngày 1: Kubernetes Fundamentals** 🎯
**Mục tiêu**: Hiểu các khái niệm cơ bản của Kubernetes

- [ ] **Kubernetes là gì?**
  - Container orchestration
  - Microservices architecture
  - Cloud-native applications

- [ ] **Kiến trúc Kubernetes**
  - Control Plane vs Worker Nodes
  - API Server, etcd, Scheduler, Controller Manager
  - kubelet, kube-proxy, Container Runtime

- [ ] **Kết nối EKS cluster có sẵn**
  ```bash
  # Cấu hình kubeconfig cho EKS
  aws eks update-kubeconfig --region ap-southeast-1 --name your-cluster-name
  
  # Kiểm tra kết nối
  kubectl get nodes
  kubectl get pods --all-namespaces
  ```
- [ ] **Pods - Đơn vị nhỏ nhất**
  ```yaml
  # pod-example.yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: nginx-pod
  spec:
    containers:
    - name: nginx
      image: nginx:1.14.2
      ports:
      - containerPort: 80
  ```

- [ ] **Thực hành với Pods**
  ```bash
  # Tạo pod
  kubectl apply -f pod-example.yaml
  
  # Xem pods
  kubectl get pods
  kubectl describe pod nginx-pod
  
  # Xem logs
  kubectl logs nginx-pod
  
  # Xóa pod
  kubectl delete pod nginx-pod
  ```

- [ ] **Services - Kết nối Pods**
  ```yaml
  # service-example.yaml
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
    type: ClusterIP
  ```

- [ ] **Bài tập ngày 1** 🔥
  - Tạo 3 pods nginx với labels khác nhau
  - Tạo 2 services: 1 ClusterIP và 1 NodePort
  - Tạo pod với multiple containers (nginx + busybox)
  - Test connectivity giữa các pods qua service
  - Sử dụng `kubectl exec` để debug network issues
  - Tạo pod với resource limits và requests
  - Thử tạo pod với image không tồn tại và debug lỗi

---

### **Ngày 2: Deployments & Scaling** 📈
**Mục tiêu**: Học cách quản lý ứng dụng với Deployments

- [ ] **Deployments - Quản lý Pods**
  ```yaml
  # deployment-example.yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: nginx-deployment
  spec:
    replicas: 3
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
  ```

- [ ] **Thực hành Deployments**
  ```bash
  # Tạo deployment
  kubectl apply -f deployment-example.yaml
  
  # Xem deployment
  kubectl get deployments
  kubectl describe deployment nginx-deployment
  
  # Scale deployment
  kubectl scale deployment nginx-deployment --replicas=5
  
  # Rolling update
  kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
  
  # Rollback
  kubectl rollout undo deployment/nginx-deployment
  ```

- [ ] **ConfigMaps & Secrets**
  ```yaml
  # configmap-example.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: app-config
  data:
    database_url: "mysql://localhost:3306/mydb"
    debug: "true"
  ```

  ```yaml
  # secret-example.yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: app-secret
  type: Opaque
  data:
    username: YWRtaW4=  # base64 encoded
    password: cGFzc3dvcmQ=  # base64 encoded
  ```

- [ ] **Volumes & Persistent Storage**
  ```yaml
  # pvc-example.yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: app-pvc
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
  ```

- [ ] **Bài tập ngày 2** 🔥🔥
  - Tạo deployment với 5 replicas và resource limits
  - Tạo 3 ConfigMaps khác nhau và mount vào deployment
  - Tạo Secret với multiple keys và sử dụng trong pod
  - Tạo PVC và mount vào pod, test data persistence
  - Thực hiện rolling update với strategy: maxUnavailable=1, maxSurge=2
  - Test rollback và xem history
  - Tạo HPA (Horizontal Pod Autoscaler) cho deployment
  - Tạo StatefulSet với persistent volume
  - Test pod disruption và recovery
  - Sử dụng `kubectl patch` để update deployment

---

### **Ngày 3: Networking & Ingress** 🌐
**Mục tiêu**: Hiểu networking và expose services

- [ ] **Services Types**
  ```yaml
  # service-types.yaml
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
    type: LoadBalancer  # ClusterIP, NodePort, LoadBalancer
  ```

- [ ] **Ingress - HTTP Routing**
  ```yaml
  # ingress-example.yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: app-ingress
  spec:
    rules:
    - host: myapp.local
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: nginx-service
              port:
                number: 80
  ```

- [ ] **Cài đặt Ingress Controller**
  ```bash
  # Cài đặt NGINX Ingress Controller với Helm
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  
  helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb
  
  # Kiểm tra
  kubectl get pods -n ingress-nginx
  kubectl get svc -n ingress-nginx
  ```

- [ ] **SSL/TLS với cert-manager**
  ```bash
  # Cài đặt cert-manager
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  
  helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.13.0 \
    --set installCRDs=true
  ```

  ```yaml
  # cert-manager.yaml
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: letsencrypt-prod
  spec:
    acme:
      server: https://acme-v02.api.letsencrypt.org/directory
      email: your-email@example.com
      privateKeySecretRef:
        name: letsencrypt-prod
      solvers:
      - http01:
          ingress:
            class: nginx
  ```

- [ ] **Network Policies**
  ```yaml
  # network-policy.yaml
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: default-deny
  spec:
    podSelector: {}
    policyTypes:
    - Ingress
    - Egress
  ```

- [ ] **Bài tập ngày 3** 🔥🔥🔥
  - Tạo 3 microservices: frontend (nginx), backend (nodejs), database (mysql)
  - Tạo LoadBalancer service cho frontend
  - Tạo Ingress với multiple hosts và paths
  - Cấu hình SSL certificate với cert-manager
  - Tạo NetworkPolicy để isolate database
  - Test service discovery giữa các pods
  - Tạo Headless service cho database
  - Cấu hình Ingress với rate limiting
  - Test canary deployment với Ingress
  - Tạo ServiceAccount và RBAC cho applications
  - Debug network connectivity issues
  - Test pod-to-pod communication across namespaces

---

### **Ngày 4: Production & DevOps** 🚀
**Mục tiêu**: Chuẩn bị cho production và CI/CD

- [ ] **Helm - Package Manager**
  ```bash
  # Cài đặt Helm
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  
  # Tạo Helm chart
  helm create myapp
  
  # Install chart
  helm install myapp ./myapp
  
  # Upgrade
  helm upgrade myapp ./myapp
  
  # Uninstall
  helm uninstall myapp
  ```

- [ ] **Monitoring & Logging**
  ```bash
  # Cài đặt Prometheus
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm install prometheus prometheus-community/kube-prometheus-stack
  
  # Cài đặt Grafana
  kubectl port-forward svc/prometheus-grafana 3000:80
  ```

- [ ] **CI/CD với GitHub Actions**
  ```yaml
  # .github/workflows/deploy.yml
  name: Deploy to Kubernetes
  on:
    push:
      branches: [main]
  jobs:
    deploy:
      runs-on: ubuntu-latest
      steps:
      - uses: actions/checkout@v2
      - name: Deploy to K8s
        run: |
          kubectl apply -f k8s/
  ```

- [ ] **Best Practices**
  - Resource limits và requests
  - Health checks (liveness, readiness)
  - Security contexts
  - RBAC (Role-Based Access Control)

- [ ] **Bài tập ngày 4** 🔥🔥🔥🔥
  - Tạo Helm chart với values.yaml cho 3 environments (dev, staging, prod)
  - Cấu hình Prometheus monitoring với custom metrics
  - Tạo Grafana dashboard cho application metrics
  - Thiết lập CI/CD pipeline với GitHub Actions
  - Implement blue-green deployment strategy
  - Tạo Kubernetes Operator cho custom resource
  - Cấu hình Pod Security Standards
  - Implement admission controllers
  - Tạo custom ResourceQuota và LimitRange
  - Setup log aggregation với Fluentd/Fluent Bit
  - Cấu hình backup strategy với Velero
  - Test disaster recovery scenario
  - Implement GitOps với ArgoCD
  - Tạo custom Helm plugin
  - Performance testing với load testing tools

---

## 🛠️ **Tools & Resources**

### **Essential Tools**
- **kubectl**: Kubernetes command-line tool
- **eksctl**: EKS cluster management
- **AWS CLI**: AWS command-line interface
- **k9s**: Terminal UI for Kubernetes
- **Helm**: Package manager for Kubernetes

### **Learning Resources**
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Kubernetes by Example](https://kubernetesbyexample.com/)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Katacoda Kubernetes Scenarios](https://www.katacoda.com/courses/kubernetes)

### **Practice Platforms**
- **AWS EKS**: Managed Kubernetes on AWS (Khuyến nghị)
- **Other Cloud**: GKE, AKS
- **Online**: Play with Kubernetes, Katacoda

---

## 📚 **Daily Checklist**

### **Ngày 1 Checklist**
- [ ] Hiểu kiến trúc Kubernetes
- [ ] Kết nối EKS cluster có sẵn
- [ ] Cấu hình kubeconfig
- [ ] Tạo và quản lý Pods
- [ ] Tạo Services
- [ ] Test connectivity

### **Ngày 2 Checklist**
- [ ] Tạo và quản lý Deployments
- [ ] Scale applications
- [ ] Rolling updates và rollbacks
- [ ] Sử dụng ConfigMaps và Secrets
- [ ] Mount volumes

### **Ngày 3 Checklist**
- [ ] Hiểu các loại Services
- [ ] Cài đặt Ingress Controller
- [ ] Cấu hình HTTP routing
- [ ] SSL/TLS certificates
- [ ] Network policies

### **Ngày 4 Checklist**
- [ ] Sử dụng Helm
- [ ] Monitoring và logging
- [ ] CI/CD integration
- [ ] Security best practices
- [ ] Production readiness

---

## 🎯 **Mục tiêu cuối khóa (Try Hard Edition)**

Sau 4 ngày, bạn sẽ có thể:

✅ **Master Kubernetes**: Kiến trúc, components, và advanced concepts  
✅ **Production Ready**: Deploy complex applications với high availability  
✅ **Advanced Resource Management**: Pods, Services, Deployments, StatefulSets, Operators  
✅ **Enterprise Networking**: Ingress, SSL, Network Policies, Service Mesh  
✅ **DevOps Expert**: Helm, CI/CD, Monitoring, GitOps, Backup/Recovery  
✅ **Troubleshooting Pro**: Debug complex issues, performance optimization  
✅ **Security Expert**: RBAC, Pod Security, Admission Controllers, Compliance  
✅ **Architecture Design**: Microservices, scalability, disaster recovery  

---

## 🚀 **Next Steps (Try Hard Path)**

Sau khi hoàn thành 4 ngày:

1. **Real World Projects**: Deploy production-grade applications với full monitoring
2. **Advanced Certifications**: CKA, CKS, CKAD
3. **Service Mesh Mastery**: Istio, Linkerd, Consul Connect
4. **Cloud Native Ecosystem**: Prometheus, Grafana, Jaeger, Fluentd
5. **Kubernetes Operators**: Tạo custom operators cho business logic
6. **Multi-cluster Management**: Federation, Cross-cluster networking
7. **Security Hardening**: CIS benchmarks, vulnerability scanning
8. **Performance Tuning**: Resource optimization, cluster sizing
9. **Cleanup**: Dọn dẹp resources sau khi học xong
   ```bash
   # Xóa tất cả resources (cẩn thận!)
   kubectl delete all --all --all-namespaces
   kubectl delete pvc --all --all-namespaces
   kubectl delete configmap --all --all-namespaces
   kubectl delete secret --all --all-namespaces
   kubectl delete ingress --all --all-namespaces
   ```

---

**🔥 Try Hard Mode Activated! Chúc bạn chinh phục Kubernetes! 🔥**
