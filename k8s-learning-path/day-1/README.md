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

### **8. Namespaces - Tổ chức Resources**
#### **Namespace là gì?**
- **Virtual clusters** trong một physical cluster
- **Logical separation** của resources
- **Resource isolation** và organization
- **Default namespace**: `default` (nếu không chỉ định)

#### **Tại sao cần Namespaces?**
- **Multi-tenancy**: Chia cluster cho nhiều teams/projects
- **Resource isolation**: Tránh conflicts giữa applications
- **Security boundaries**: RBAC và Network Policies
- **Resource quotas**: Giới hạn resources per namespace

#### **Built-in Namespaces:**
- **default**: Resources không chỉ định namespace
- **kube-system**: System components (kube-proxy, DNS, etc.)
- **kube-public**: Publicly accessible resources
- **kube-node-lease**: Node heartbeat data

#### **Thực hành Namespaces:**
```bash
# Tạo namespace
kubectl create namespace development
kubectl create namespace production
kubectl create namespace staging

# Xem namespaces
kubectl get namespaces
kubectl get ns

# Xem chi tiết namespace
kubectl describe namespace development

# Chuyển context
kubectl config set-context --current --namespace=development

# Xem resources trong namespace
kubectl get pods -n development
kubectl get all -n development

# Tạo resource trong namespace cụ thể
kubectl apply -f pod.yaml -n development

# Xóa namespace (cẩn thận!)
kubectl delete namespace development
```

### **9. Labels và Selectors - Organizing Resources**
#### **Labels là gì?**
- **Key-value pairs** gắn vào objects
- **Metadata** để identify và organize resources
- **Immutable** sau khi tạo object
- **Used by selectors** để group resources

#### **Tại sao cần Labels?**
- **Resource organization**: Group related resources
- **Service discovery**: Service tìm pods qua labels
- **Operations**: Bulk operations trên labeled resources
- **Monitoring**: Group metrics và alerts

#### **Label Best Practices:**
```yaml
# Pod với labels
metadata:
  labels:
    app: nginx                    # Application name
    version: v1.14.2             # Version
    environment: production       # Environment
    tier: frontend               # Application tier
    team: frontend-team          # Team ownership
    component: web-server        # Component type
```

#### **Selectors:**
```yaml
# Service selector
spec:
  selector:
    app: nginx
    tier: frontend

# Deployment selector
spec:
  selector:
    matchLabels:
      app: nginx
    matchExpressions:
    - key: environment
      operator: In
      values: [production, staging]
```

#### **Thực hành Labels:**
```bash
# Xem labels
kubectl get pods --show-labels
kubectl get pods -l app=nginx
kubectl get pods -l environment=production
kubectl get pods -l 'tier in (frontend,backend)'

# Thêm labels
kubectl label pod nginx-pod environment=production
kubectl label pod nginx-pod team=frontend-team

# Xóa labels
kubectl label pod nginx-pod environment-

# Bulk operations với labels
kubectl delete pods -l app=nginx
kubectl scale deployment nginx-deployment --replicas=5 -l environment=production
```

### **10. Resource Management - CPU & Memory**
#### **Resource Requests & Limits là gì?**
- **Requests**: Guaranteed resources cho pod
- **Limits**: Maximum resources pod có thể sử dụng
- **Scheduling**: Scheduler dựa vào requests để chọn node
- **Quality of Service**: Determines pod priority

#### **Tại sao cần Resource Management?**
- **Prevent resource starvation**: Tránh pod chiếm hết resources
- **Fair scheduling**: Đảm bảo fair distribution
- **Cost optimization**: Right-sizing containers
- **Performance**: Predictable performance

#### **Resource Units:**
```yaml
# CPU units
cpu: "100m"        # 100 millicores = 0.1 CPU
cpu: "1"           # 1 CPU core
cpu: "2.5"         # 2.5 CPU cores

# Memory units
memory: "64Mi"     # 64 Mebibytes
memory: "1Gi"      # 1 Gibibyte
memory: "2G"       # 2 Gigabytes
```

#### **Quality of Service Classes:**
- **Guaranteed**: Requests = Limits (highest priority)
- **Burstable**: Requests < Limits (medium priority)
- **BestEffort**: No requests/limits (lowest priority)

#### **Resource Management Examples:**
```yaml
# Guaranteed QoS
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "64Mi"    # Same as requests
    cpu: "50m"        # Same as requests

# Burstable QoS
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"   # Higher than requests
    cpu: "100m"       # Higher than requests

# BestEffort QoS
# No resources specified
```

#### **Thực hành Resource Management:**
```bash
# Xem resource usage
kubectl top pods
kubectl top nodes
kubectl top pods --containers

# Xem resource requests/limits
kubectl describe pod nginx-pod
kubectl get pod nginx-pod -o yaml | grep -A 10 resources

# Test resource limits
kubectl exec nginx-pod -- stress --cpu 2 --timeout 60s
```

### **11. Health Checks - Pod Health Monitoring**
#### **Health Checks là gì?**
- **Liveness Probe**: Kiểm tra container có còn sống không
- **Readiness Probe**: Kiểm tra container có sẵn sàng nhận traffic không
- **Startup Probe**: Kiểm tra container đã start thành công chưa
- **Automatic recovery**: Kubernetes tự động restart failed containers

#### **Tại sao cần Health Checks?**
- **Self-healing**: Tự động restart failed containers
- **Traffic routing**: Chỉ route traffic đến healthy pods
- **Deployment safety**: Đảm bảo new pods ready trước khi terminate old pods
- **Monitoring**: Detect và alert về unhealthy applications

#### **Probe Types:**
```yaml
# HTTP GET probe
livenessProbe:
  httpGet:
    path: /health
    port: 8080
    httpHeaders:
    - name: Custom-Header
      value: "value"
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

# TCP Socket probe
livenessProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20

# Command probe
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
  initialDelaySeconds: 5
  periodSeconds: 5
```

#### **Probe Parameters:**
- **initialDelaySeconds**: Thời gian chờ trước khi bắt đầu probe
- **periodSeconds**: Khoảng thời gian giữa các lần probe
- **timeoutSeconds**: Timeout cho mỗi probe
- **successThreshold**: Số lần probe thành công để coi là healthy
- **failureThreshold**: Số lần probe thất bại để coi là unhealthy

#### **Health Check Examples:**
```yaml
# Complete health check setup
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
      failureThreshold: 3
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
      successThreshold: 1
    startupProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 30
```

#### **Thực hành Health Checks:**
```bash
# Xem probe status
kubectl describe pod nginx-pod
kubectl get pod nginx-pod -o yaml | grep -A 20 probes

# Test liveness probe
kubectl exec nginx-pod -- rm /usr/share/nginx/html/index.html
# Pod sẽ bị restart sau vài lần probe thất bại

# Monitor pod events
kubectl get events --sort-by=.metadata.creationTimestamp
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
