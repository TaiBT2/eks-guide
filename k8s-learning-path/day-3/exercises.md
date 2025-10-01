# Day 3 Exercises 🔥🔥🔥

## **Bài tập ngày 3** 🔥🔥🔥

### **Exercise 1: Microservices Architecture**
- Tạo 3 microservices: frontend (nginx), backend (nodejs), database (mysql)
- Mỗi service có deployment và service riêng
- Test connectivity giữa các services

### **Exercise 2: LoadBalancer Service**
- Tạo LoadBalancer service cho frontend
- Test access từ bên ngoài cluster
- Xem AWS Load Balancer được tạo

### **Exercise 3: Advanced Ingress**
- Tạo Ingress với multiple hosts và paths
- Cấu hình routing cho frontend và backend
- Test path-based routing

### **Exercise 4: SSL/TLS Configuration**
- Cấu hình SSL certificate với cert-manager
- Tạo Ingress với TLS termination
- Test HTTPS access

### **Exercise 5: Network Security**
- Tạo NetworkPolicy để isolate database
- Chỉ cho phép backend access database
- Test network isolation

### **Exercise 6: Service Discovery**
- Test service discovery giữa các pods
- Sử dụng DNS names để connect
- Tạo Headless service cho database

### **Exercise 7: Advanced Ingress Features**
- Cấu hình Ingress với rate limiting
- Test canary deployment với Ingress
- Cấu hình custom annotations

### **Exercise 8: RBAC & Security**
- Tạo ServiceAccount cho applications
- Cấu hình RBAC rules
- Test permission restrictions

### **Exercise 9: Cross-Namespace Communication**
- Tạo applications trong different namespaces
- Test pod-to-pod communication across namespaces
- Cấu hình NetworkPolicy cho cross-namespace access

### **Exercise 10: Troubleshooting**
- Debug network connectivity issues
- Sử dụng `kubectl port-forward` để test services
- Analyze network traffic với `tcpdump`

## **Commands Reference**

```bash
# Services
kubectl get services
kubectl describe service <service-name>
kubectl expose deployment <deployment-name> --type=LoadBalancer

# Ingress
kubectl get ingress
kubectl describe ingress <ingress-name>
kubectl get ingressclass

# Network Policies
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>

# Service Discovery
kubectl get endpoints
kubectl get endpointslices

# DNS Testing
kubectl run dns-test --image=busybox --rm -it -- nslookup <service-name>

# Port Forwarding
kubectl port-forward service/<service-name> 8080:80
kubectl port-forward pod/<pod-name> 8080:80

# Network Debugging
kubectl exec -it <pod-name> -- netstat -tulpn
kubectl exec -it <pod-name> -- tcpdump -i any
```

## **Advanced Networking Concepts**

### **Headless Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

### **NetworkPolicy Example**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-isolation
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 3306
```

### **Ingress with Rate Limiting**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rate-limited-ingress
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80
```

## **Success Criteria**

- [ ] Tạo được 3-tier microservices architecture
- [ ] Cấu hình được LoadBalancer service
- [ ] Tạo được Ingress với multiple hosts/paths
- [ ] Cấu hình được SSL/TLS với cert-manager
- [ ] Tạo được NetworkPolicy cho security
- [ ] Test được service discovery
- [ ] Cấu hình được Headless service
- [ ] Test được cross-namespace communication
- [ ] Debug được network issues
- [ ] Hiểu được RBAC và security concepts
