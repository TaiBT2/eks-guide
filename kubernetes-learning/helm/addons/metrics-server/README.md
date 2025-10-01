# Metrics Server

## Mục đích
Metrics Server thu thập metrics về CPU và memory usage từ các nodes và pods trong EKS cluster. Nó cung cấp:

- **API cho `kubectl top`** commands
- **Dữ liệu cho HPA** (Horizontal Pod Autoscaler)
- **Metrics cho Cluster Autoscaler** để quyết định scaling
- **Resource monitoring** cho cluster observability

## Các bước triển khai thực tế

### 1. Deploy bằng Kubernetes Manifest
```bash
# Deploy Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 2. Xóa deployment cũ (do lỗi certificate)
```bash
# Xóa deployment cũ
kubectl delete deployment metrics-server -n kube-system
```

### 3. Tạo deployment mới với cấu hình đúng cho EKS
Tạo file `metrics-server-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
        - --v=2
        image: registry.k8s.io/metrics-server/metrics-server:v0.7.1
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
          limits:
            cpu: 200m
            memory: 400Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      tolerations:
      - key: "eks.amazonaws.com/capacityType"
        operator: "Equal"
        value: "SPOT"
        effect: "NoSchedule"
      volumes:
      - emptyDir: {}
        name: tmp-dir
```

### 4. Deploy deployment mới
```bash
# Deploy Metrics Server với cấu hình đúng
kubectl apply -f metrics-server-deployment.yaml
```

## Cấu hình

### Arguments quan trọng cho EKS:
- `--kubelet-insecure-tls`: Bỏ qua TLS verification khi kết nối với kubelet
- `--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname`: Ưu tiên InternalIP cho EKS
- `--kubelet-use-node-status-port`: Sử dụng node status port
- `--metric-resolution=15s`: Thu thập metrics mỗi 15 giây

### Resource Limits:
```yaml
resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 200m
    memory: 400Mi
```

## Cách sử dụng

### 1. Kiểm tra trạng thái
```bash
# Kiểm tra pods
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Kiểm tra API service
kubectl get apiservice | grep metrics

# Kiểm tra logs
kubectl logs -n kube-system deployment/metrics-server
```

### 2. Sử dụng Metrics API
```bash
# Xem node metrics
kubectl top nodes

# Xem pod metrics
kubectl top pods

# Xem metrics raw
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods"
```

### 3. Test với HPA
```bash
# Tạo HPA cho deployment
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=10

# Kiểm tra HPA status
kubectl get hpa
```

## Troubleshooting

### 1. Lỗi "Metrics API not available"
```bash
# Kiểm tra pod status
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Kiểm tra API service
kubectl get apiservice v1beta1.metrics.k8s.io

# Kiểm tra logs
kubectl logs -n kube-system deployment/metrics-server
```

### 2. Lỗi certificate (đã gặp)
```bash
# Lỗi: panic: unable to create request header authentication config: open /etc/kubernetes/pki/front-proxy-ca.crt: no such file or directory

# Giải pháp: Bỏ các arguments không cần thiết
# Không sử dụng:
# - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
# - --requestheader-username-headers=X-Remote-User
# - --requestheader-group-headers=X-Remote-Group
# - --requestheader-extra-headers-prefix=X-Remote-Extra-
```

### 3. Pod CrashLoopBackOff
```bash
# Kiểm tra logs chi tiết
kubectl logs -n kube-system deployment/metrics-server --previous

# Xóa deployment cũ và tạo lại
kubectl delete deployment metrics-server -n kube-system
kubectl apply -f metrics-server-deployment.yaml
```

## Dependencies

- **EKS Cluster** với nodes
- **kubelet** trên worker nodes
- **RBAC** permissions (được tạo tự động)
- **API Server** với aggregation layer

## Monitoring

### Metrics được thu thập:
- **Node metrics**: CPU, memory usage
- **Pod metrics**: CPU, memory usage per pod
- **Container metrics**: CPU, memory usage per container

### CloudWatch Integration:
Metrics Server metrics có thể được scrape bởi CloudWatch Container Insights hoặc Prometheus.

## Security Notes

1. **TLS**: Sử dụng self-signed certificates
2. **RBAC**: Có quyền đọc metrics từ kubelet
3. **Network**: Chạy trong kube-system namespace
4. **Insecure TLS**: Cần thiết cho EKS (không ảnh hưởng security)

## Best Practices

1. **Monitor resource usage** của Metrics Server
2. **Cấu hình resource limits** phù hợp
3. **Test HPA** sau khi deploy
4. **Monitor API availability** qua health checks
5. **Backup configuration** trước khi thay đổi

## Common Issues

### EKS Specific:
- **kubelet-insecure-tls**: Bắt buộc cho EKS
- **InternalIP preference**: Cần thiết cho EKS networking
- **Certificate issues**: Thường gặp với EKS

### General:
- **API not available**: Kiểm tra endpoints và certificates
- **No metrics**: Kiểm tra kubelet connectivity
- **High resource usage**: Điều chỉnh metric-resolution
