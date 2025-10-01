# Ngày 3: Networking & Ingress 🔥🔥🔥

**Mục tiêu**: Hiểu networking và expose services

## 📚 **Nội dung học**

### **Services Types**
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

### **Ingress - HTTP Routing**
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

### **Cài đặt Ingress Controller**
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

### **SSL/TLS với cert-manager**
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

### **Network Policies**
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

## 🎯 **Mục tiêu ngày 3**

- [ ] Hiểu các loại Services
- [ ] Cài đặt Ingress Controller
- [ ] Cấu hình HTTP routing
- [ ] SSL/TLS certificates
- [ ] Network policies

## 📝 **Bài tập**

Xem [Exercises](./exercises.md) để làm bài tập thực hành.

## 📁 **Examples**

Tham khảo các file trong thư mục [examples/](./examples/) để có code mẫu.

## ➡️ **Tiếp theo**

Sau khi hoàn thành ngày 3, chuyển sang [Day 4: Production & DevOps](../day-4/README.md)
