# Ngày 4: Production & DevOps 🔥🔥🔥🔥

**Mục tiêu**: Chuẩn bị cho production và CI/CD

## 📚 **Nội dung học**

### **Helm - Package Manager**
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

### **Monitoring & Logging**
```bash
# Cài đặt Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

# Cài đặt Grafana
kubectl port-forward svc/prometheus-grafana 3000:80
```

### **CI/CD với GitHub Actions**
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

### **Best Practices**
- Resource limits và requests
- Health checks (liveness, readiness)
- Security contexts
- RBAC (Role-Based Access Control)

## 🎯 **Mục tiêu ngày 4**

- [ ] Sử dụng Helm
- [ ] Monitoring và logging
- [ ] CI/CD integration
- [ ] Security best practices
- [ ] Production readiness

## 📝 **Bài tập**

Xem [Exercises](./exercises.md) để làm bài tập thực hành.

## 📁 **Examples**

Tham khảo các file trong thư mục [examples/](./examples/) để có code mẫu.

## 🎉 **Hoàn thành khóa học**

Chúc mừng! Bạn đã hoàn thành lộ trình học Kubernetes 4 ngày!

Xem [Next Steps](../README.md#next-steps) để tiếp tục phát triển kỹ năng.
