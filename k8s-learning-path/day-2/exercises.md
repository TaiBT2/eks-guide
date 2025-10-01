# Day 2 Exercises 🔥🔥

## **Bài tập ngày 2** 🔥🔥

### **Exercise 1: Advanced Deployments**
- Tạo deployment với 5 replicas và resource limits
- CPU: 200m, Memory: 256Mi per pod

### **Exercise 2: ConfigMaps & Secrets**
- Tạo 3 ConfigMaps khác nhau và mount vào deployment
- Tạo Secret với multiple keys và sử dụng trong pod
- Test việc update ConfigMap và restart pods

### **Exercise 3: Persistent Storage**
- Tạo PVC và mount vào pod
- Test data persistence khi pod restart
- Tạo StatefulSet với persistent volume

### **Exercise 4: Rolling Updates**
- Thực hiện rolling update với strategy: maxUnavailable=1, maxSurge=2
- Test rollback và xem history
- Sử dụng `kubectl patch` để update deployment

### **Exercise 5: Auto Scaling**
- Tạo HPA (Horizontal Pod Autoscaler) cho deployment
- Test scaling khi CPU usage tăng

### **Exercise 6: Pod Disruption**
- Test pod disruption và recovery
- Sử dụng `kubectl drain` để test node maintenance

## **Commands Reference**

```bash
# Deployment management
kubectl get deployments
kubectl describe deployment <deployment-name>
kubectl scale deployment <deployment-name> --replicas=5

# Rolling updates
kubectl set image deployment/<deployment-name> <container>=<new-image>
kubectl rollout status deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name>

# ConfigMaps & Secrets
kubectl create configmap <name> --from-literal=key=value
kubectl create secret generic <name> --from-literal=username=admin
kubectl get configmaps
kubectl get secrets

# Volumes
kubectl get pvc
kubectl get pv
kubectl describe pvc <pvc-name>

# HPA
kubectl autoscale deployment <deployment-name> --cpu-percent=50 --min=1 --max=10
kubectl get hpa

# StatefulSet
kubectl get statefulsets
kubectl describe statefulset <statefulset-name>

# Patch
kubectl patch deployment <deployment-name> -p '{"spec":{"replicas":3}}'
```

## **Advanced Concepts**

### **Rolling Update Strategy**
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 2
```

### **HPA Configuration**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

## **Success Criteria**

- [ ] Tạo được deployment với resource limits
- [ ] Sử dụng được ConfigMaps và Secrets
- [ ] Mount được persistent volume
- [ ] Thực hiện được rolling update và rollback
- [ ] Tạo được HPA cho auto scaling
- [ ] Tạo được StatefulSet với persistent storage
- [ ] Test được pod disruption và recovery
