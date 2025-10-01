# Day 1 Exercises 🔥

## **Bài tập ngày 1** 🔥

### **Exercise 1: Basic Pods**
- Tạo 3 pods nginx với labels khác nhau
- Sử dụng labels: `app: nginx`, `version: v1`, `env: dev`

### **Exercise 2: Services**
- Tạo 2 services: 1 ClusterIP và 1 NodePort
- Test connectivity giữa các pods qua service

### **Exercise 3: Multi-container Pod**
- Tạo pod với multiple containers (nginx + busybox)
- Sử dụng `kubectl exec` để debug network issues

### **Exercise 4: Resource Management**
- Tạo pod với resource limits và requests
- CPU: 100m, Memory: 128Mi

### **Exercise 5: Error Handling**
- Thử tạo pod với image không tồn tại và debug lỗi
- Sử dụng `kubectl describe` để xem chi tiết lỗi

## **Commands Reference**

```bash
# Tạo pod
kubectl apply -f pod-example.yaml

# Xem pods
kubectl get pods
kubectl get pods -o wide

# Xem chi tiết pod
kubectl describe pod <pod-name>

# Xem logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>

# Exec vào pod
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh

# Xóa pod
kubectl delete pod <pod-name>
kubectl delete pod --all

# Xem services
kubectl get services
kubectl get svc

# Test connectivity
kubectl port-forward pod/<pod-name> 8080:80
```

## **Troubleshooting Tips**

1. **Pod không start**: Check `kubectl describe pod`
2. **Image pull error**: Verify image name và registry
3. **Network issues**: Check service selector và pod labels
4. **Resource issues**: Check resource limits và node capacity

## **Success Criteria**

- [ ] Tạo được 3 pods với labels khác nhau
- [ ] Tạo được 2 services (ClusterIP và NodePort)
- [ ] Test được connectivity giữa pods
- [ ] Tạo được multi-container pod
- [ ] Debug được lỗi khi pod không start
- [ ] Hiểu được resource limits và requests
