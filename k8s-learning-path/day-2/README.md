# Ngày 2: Deployments & Scaling 🔥🔥

**Mục tiêu**: Học cách quản lý ứng dụng với Deployments

## 📚 **Nội dung học**

### **Deployments - Quản lý Pods**
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

### **Thực hành Deployments**
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

### **ConfigMaps & Secrets**
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

### **Volumes & Persistent Storage**
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

## 🎯 **Mục tiêu ngày 2**

- [ ] Tạo và quản lý Deployments
- [ ] Scale applications
- [ ] Rolling updates và rollbacks
- [ ] Sử dụng ConfigMaps và Secrets
- [ ] Mount volumes

## 📝 **Bài tập**

Xem [Exercises](./exercises.md) để làm bài tập thực hành.

## 📁 **Examples**

Tham khảo các file trong thư mục [examples/](./examples/) để có code mẫu.

## ➡️ **Tiếp theo**

Sau khi hoàn thành ngày 2, chuyển sang [Day 3: Networking & Ingress](../day-3/README.md)
