# Day 4 Exercises 🔥🔥🔥🔥

## **Bài tập ngày 4** 🔥🔥🔥🔥

### **Exercise 1: Advanced Helm Charts**
- Tạo Helm chart với values.yaml cho 3 environments (dev, staging, prod)
- Sử dụng templates với conditionals và loops
- Tạo custom values files cho từng environment

### **Exercise 2: Monitoring & Observability**
- Cấu hình Prometheus monitoring với custom metrics
- Tạo Grafana dashboard cho application metrics
- Setup alerting rules cho critical metrics

### **Exercise 3: CI/CD Pipeline**
- Thiết lập CI/CD pipeline với GitHub Actions
- Implement blue-green deployment strategy
- Test automated deployment và rollback

### **Exercise 4: Kubernetes Operators**
- Tạo Kubernetes Operator cho custom resource
- Implement CRD (Custom Resource Definition)
- Test operator functionality

### **Exercise 5: Security Hardening**
- Cấu hình Pod Security Standards
- Implement admission controllers
- Tạo custom ResourceQuota và LimitRange

### **Exercise 6: Log Management**
- Setup log aggregation với Fluentd/Fluent Bit
- Cấu hình log forwarding đến Elasticsearch
- Tạo log parsing và filtering rules

### **Exercise 7: Backup & Recovery**
- Cấu hình backup strategy với Velero
- Test disaster recovery scenario
- Implement automated backup scheduling

### **Exercise 8: GitOps Implementation**
- Implement GitOps với ArgoCD
- Cấu hình automated sync
- Test Git-based deployment workflow

### **Exercise 9: Advanced Helm**
- Tạo custom Helm plugin
- Implement Helm hooks cho lifecycle management
- Test Helm chart testing framework

### **Exercise 10: Performance & Load Testing**
- Performance testing với load testing tools
- Cấu hình resource optimization
- Test cluster scaling under load

## **Commands Reference**

```bash
# Helm Advanced
helm create <chart-name>
helm package <chart-directory>
helm lint <chart-directory>
helm test <release-name>
helm plugin install <plugin-url>

# Monitoring
kubectl get prometheus
kubectl get servicemonitor
kubectl get alertmanager

# GitOps
kubectl get applications
kubectl describe application <app-name>
argocd app sync <app-name>

# Backup
velero backup create <backup-name>
velero restore create --from-backup <backup-name>
velero backup get

# Security
kubectl get psp
kubectl get networkpolicies
kubectl get podsecuritypolicies

# Performance
kubectl top nodes
kubectl top pods
kubectl describe node <node-name>
```

## **Advanced Production Concepts**

### **Helm Chart Structure**
```
myapp/
├── Chart.yaml
├── values.yaml
├── values-dev.yaml
├── values-staging.yaml
├── values-prod.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   └── _helpers.tpl
└── tests/
    └── test-connection.yaml
```

### **Prometheus Custom Metrics**
```yaml
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: app-metrics
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: metrics
    path: /metrics
```

### **ArgoCD Application**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
spec:
  project: default
  source:
    repoURL: https://github.com/user/repo
    targetRevision: HEAD
    path: k8s/
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### **Velero Backup**
```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"
  template:
    includedNamespaces:
    - default
    - production
    ttl: "720h"
```

## **Success Criteria**

- [ ] Tạo được Helm chart với multi-environment support
- [ ] Cấu hình được monitoring và alerting
- [ ] Thiết lập được CI/CD pipeline
- [ ] Implement được blue-green deployment
- [ ] Tạo được Kubernetes Operator
- [ ] Cấu hình được security best practices
- [ ] Setup được log aggregation
- [ ] Cấu hình được backup strategy
- [ ] Implement được GitOps workflow
- [ ] Tạo được custom Helm plugin
- [ ] Thực hiện được performance testing
- [ ] Hiểu được production readiness checklist
