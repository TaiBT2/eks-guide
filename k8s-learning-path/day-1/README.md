# Ngày 1: Kubernetes Fundamentals 🔥

**Mục tiêu**: Hiểu các khái niệm cơ bản của Kubernetes

## 📚 **Nội dung học**

### **Kubernetes là gì?**
- Container orchestration
- Microservices architecture
- Cloud-native applications

### **Kiến trúc Kubernetes**
- Control Plane vs Worker Nodes
- API Server, etcd, Scheduler, Controller Manager
- kubelet, kube-proxy, Container Runtime

### **Kết nối EKS cluster có sẵn**
```bash
# Cấu hình kubeconfig cho EKS
aws eks update-kubeconfig --region ap-southeast-1 --name your-cluster-name

# Kiểm tra kết nối
kubectl get nodes
kubectl get pods --all-namespaces
```

### **Pods - Đơn vị nhỏ nhất**
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

### **Thực hành với Pods**
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

### **Services - Kết nối Pods**
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
