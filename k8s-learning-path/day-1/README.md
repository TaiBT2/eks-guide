# Ngày 1: Kubernetes Fundamentals 🔥

**Mục tiêu**: Hiểu các khái niệm cơ bản của Kubernetes

## 📚 **Nội dung học**

### **1. Kubernetes là gì?**
- **Container orchestration**: Quản lý containers ở quy mô lớn
- **Microservices architecture**: Kiến trúc ứng dụng phân tán
- **Cloud-native applications**: Ứng dụng được thiết kế cho cloud
- **Benefits**: High availability, scalability, portability
- **Use cases**: Web apps, APIs, databases, ML workloads

### **2. Kiến trúc Kubernetes**
> 📊 **Xem [Architecture Diagrams](../kubernetes-architecture.md) để hiểu rõ hơn về kiến trúc**

#### **Control Plane Components:**
- **API Server**: REST API endpoint cho tất cả operations
- **etcd**: Distributed key-value store cho cluster state
- **Scheduler**: Assigns pods to nodes
- **Controller Manager**: Runs controllers (Deployment, ReplicaSet, etc.)

#### **Worker Node Components:**
- **kubelet**: Agent chạy trên mỗi node
- **kube-proxy**: Network proxy cho services
- **Container Runtime**: Docker, containerd, CRI-O

#### **Add-ons:**
- **DNS**: CoreDNS cho service discovery
- **Dashboard**: Web UI cho cluster management
- **Ingress Controller**: HTTP/HTTPS routing

### **3. Kết nối EKS cluster có sẵn**
```bash
# Cấu hình kubeconfig cho EKS
aws eks update-kubeconfig --region ap-southeast-1 --name your-cluster-name

# Kiểm tra kết nối
kubectl get nodes
kubectl get pods --all-namespaces

# Xem cluster info
kubectl cluster-info
kubectl get componentstatuses
```

### **4. Pods - Đơn vị nhỏ nhất**
#### **Pod Concepts:**
- **Smallest deployable unit** trong Kubernetes
- **One or more containers** sharing network và storage
- **Lifecycle**: Pending → Running → Succeeded/Failed
- **Restart Policy**: Always, OnFailure, Never

#### **Pod Spec:**
```yaml
# pod-example.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    version: v1
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "50m"
      limits:
        memory: "128Mi"
        cpu: "100m"
    env:
    - name: ENV_VAR
      value: "production"
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: shared-data
    emptyDir: {}
  restartPolicy: Always
```

### **5. Thực hành với Pods**
```bash
# Tạo pod
kubectl apply -f pod-example.yaml

# Xem pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --show-labels

# Xem chi tiết pod
kubectl describe pod nginx-pod
kubectl get pod nginx-pod -o yaml

# Xem logs
kubectl logs nginx-pod
kubectl logs nginx-pod -f  # follow logs
kubectl logs nginx-pod --previous  # previous container logs

# Exec vào pod
kubectl exec -it nginx-pod -- /bin/bash
kubectl exec nginx-pod -- nginx -v

# Xóa pod
kubectl delete pod nginx-pod
kubectl delete pod --all
```

### **6. Services - Kết nối Pods**
#### **Service Types:**
- **ClusterIP**: Internal cluster IP (default)
- **NodePort**: Expose on node's IP
- **LoadBalancer**: External load balancer
- **ExternalName**: Maps to external DNS name

#### **Service Spec:**
```yaml
# service-example.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  type: ClusterIP
  sessionAffinity: None
```

### **7. Service Discovery**
- **DNS-based**: `service-name.namespace.svc.cluster.local`
- **Environment variables**: Injected vào pods
- **Service endpoints**: Automatic endpoint management

### **8. Namespaces**
```bash
# Tạo namespace
kubectl create namespace development
kubectl create namespace production

# Xem namespaces
kubectl get namespaces
kubectl get ns

# Chuyển context
kubectl config set-context --current --namespace=development

# Xem resources trong namespace
kubectl get pods -n development
kubectl get all -n development
```

### **9. Labels và Selectors**
```yaml
# Pod với labels
metadata:
  labels:
    app: nginx
    version: v1.14.2
    environment: production
    tier: frontend

# Service selector
spec:
  selector:
    app: nginx
    tier: frontend
```

### **10. Resource Management**
```yaml
# Resource requests và limits
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
```

### **11. Health Checks**
```yaml
# Liveness probe
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

# Readiness probe
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## 🎯 **Mục tiêu ngày 1**

- [ ] Hiểu kiến trúc Kubernetes
- [ ] Kết nối EKS cluster có sẵn
- [ ] Cấu hình kubeconfig
- [ ] Tạo và quản lý Pods
- [ ] Tạo Services
- [ ] Test connectivity

## 📝 **Bài tập**

Xem [Exercises](./exercises.md) để làm bài tập thực hành.

## 📁 **Examples**

Tham khảo các file trong thư mục [examples/](./examples/) để có code mẫu.

## ➡️ **Tiếp theo**

Sau khi hoàn thành ngày 1, chuyển sang [Day 2: Deployments & Scaling](../day-2/README.md)
