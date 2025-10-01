# Fluent Bit - Elasticsearch Logging

## Tổng quan
Fluent Bit được cấu hình để thu thập logs chỉ từ namespace `z-wallet-prod` và gửi đến Elasticsearch thay vì CloudWatch.

## Cấu hình hiện tại

### Namespace
- **observability**: Chứa Fluent Bit DaemonSet và các resources liên quan

### Components
1. **ServiceAccount**: `fluent-bit` với IRSA role `prod-eks-fluent-bit`
2. **ConfigMap**: `fluent-bit-simple-config` chứa cấu hình Fluent Bit
3. **DaemonSet**: `fluent-bit-elasticsearch` chạy trên tất cả nodes
4. **Secret**: `elasticsearch-credentials` chứa thông tin kết nối Elasticsearch

### Cấu hình chính
- **Input**: Thu thập logs từ `/var/log/containers/*.log`
- **Filter**: 
  - Kubernetes metadata enrichment
  - Grep filter chỉ lấy logs từ namespace `z-wallet-prod`
  - Record modifier thêm thông tin cluster, node, namespace, environment
- **Output**: Gửi logs đến Elasticsearch với Logstash format

## Các bước triển khai đã thực hiện

### 1. Tạo namespace và ServiceAccount
```bash
kubectl create namespace observability
kubectl create serviceaccount fluent-bit -n observability
kubectl annotate serviceaccount fluent-bit -n observability eks.amazonaws.com/role-arn=arn:aws:iam::190749975524:role/prod-eks-fluent-bit
```

### 2. Tạo Elasticsearch Secret
```bash
kubectl create secret generic elasticsearch-credentials -n observability \
  --from-literal=host=your-elasticsearch-host \
  --from-literal=port=9200 \
  --from-literal=index=z-wallet-prod-logs \
  --from-literal=username=your-username \
  --from-literal=password=your-password
```

### 3. Deploy Fluent Bit
```bash
kubectl apply -f fluent-bit-simple-configmap.yaml
kubectl apply -f fluent-bit-custom.yaml
```

## Kiểm tra hoạt động

### Kiểm tra pod status
```bash
kubectl get pods -n observability
```

### Kiểm tra logs
```bash
kubectl logs -n observability daemonset/fluent-bit-elasticsearch
```

### Test với namespace z-wallet-prod
```bash
kubectl run test-pod --image=nginx --namespace=z-wallet-prod
```

## Cấu hình Elasticsearch

### Cập nhật Secret
```bash
kubectl create secret generic elasticsearch-credentials -n observability \
  --from-literal=host=your-new-host \
  --from-literal=port=9200 \
  --from-literal=index=z-wallet-prod-logs \
  --from-literal=username=your-username \
  --from-literal=password=your-password \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Restart Fluent Bit sau khi cập nhật Secret
```bash
kubectl rollout restart daemonset/fluent-bit-elasticsearch -n observability
```

## Troubleshooting

### Lỗi parser không được đăng ký
- **Nguyên nhân**: Fluent Bit không hỗ trợ parser được chỉ định
- **Giải pháp**: Bỏ parser hoặc sử dụng parser được hỗ trợ

### Lỗi kết nối Elasticsearch
- **Nguyên nhân**: Thông tin kết nối Elasticsearch không đúng
- **Giải pháp**: Kiểm tra và cập nhật Secret `elasticsearch-credentials`

### Không thấy logs từ namespace z-wallet-prod
- **Nguyên nhân**: Grep filter không hoạt động đúng
- **Giải pháp**: Kiểm tra cấu hình grep filter trong ConfigMap

## Monitoring

### Health check
```bash
kubectl get pods -n observability -l app=fluent-bit-elasticsearch
```

### Logs output
```bash
kubectl logs -n observability daemonset/fluent-bit-elasticsearch --tail=50
```

## Lưu ý quan trọng

1. **Namespace filtering**: Chỉ logs từ namespace `z-wallet-prod` được gửi đến Elasticsearch
2. **IRSA**: Fluent Bit sử dụng IRSA để truy cập AWS services
3. **DaemonSet**: Chạy trên tất cả nodes để thu thập logs
4. **Elasticsearch**: Cần cấu hình đúng thông tin kết nối trong Secret