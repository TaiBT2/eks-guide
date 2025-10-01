# Velero - Backup và Disaster Recovery

## Tổng quan
Velero được cấu hình để backup namespace `gitlab` và cung cấp disaster recovery cho EKS production cluster.

## Chức năng chính

### 1. **Scheduled Backup**
- **Tự động backup**: Mỗi ngày lúc 2:00 AM
- **Namespace**: Chỉ backup namespace `gitlab`
- **Retention**: Giữ backup trong 30 ngày
- **Storage**: S3 bucket `eks-prod-velero-backups-190749975524`

### 2. **Manual Backup**
- Tạo backup theo yêu cầu
- Backup toàn bộ namespace hoặc specific resources
- Cross-region backup support

### 3. **Disaster Recovery**
- Khôi phục namespace từ backup
- Cluster migration support
- Volume snapshot và restore

## Cấu hình

### AWS Resources
- **S3 Bucket**: `eks-prod-velero-backups-190749975524`
- **IAM Role**: `prod-eks-velero`
- **Region**: `ap-northeast-1`
- **EBS Snapshots**: Tự động tạo snapshot cho persistent volumes

### Kubernetes Resources
- **Namespace**: `velero`
- **ServiceAccount**: `velero` với IRSA
- **DaemonSet**: `restic` cho volume backup
- **Deployment**: `velero` server

## Triển khai

### 1. Chạy setup script
```bash
# Linux/Mac
chmod +x setup-velero.sh
./setup-velero.sh

# Windows PowerShell
.\setup-velero.ps1
```

### 2. Kiểm tra installation
```bash
# Kiểm tra Velero pods
kubectl get pods -n velero

# Kiểm tra backup location
velero get backup-locations

# Kiểm tra schedules
velero get schedules
```

## Sử dụng

### 1. **Tạo manual backup**
```bash
# Backup toàn bộ namespace gitlab
velero backup create gitlab-manual-backup --include-namespaces gitlab

# Backup với label selector
velero backup create gitlab-selective-backup --include-namespaces gitlab --selector app=gitlab

# Backup với TTL
velero backup create gitlab-temp-backup --include-namespaces gitlab --ttl 7d
```

### 2. **Restore từ backup**
```bash
# List available backups
velero get backups

# Restore toàn bộ namespace
velero restore create --from-backup gitlab-manual-backup

# Restore với tên mới
velero restore create gitlab-restore-$(date +%Y%m%d) --from-backup gitlab-manual-backup

# Restore specific resources
velero restore create --from-backup gitlab-manual-backup --include-resources deployments,services
```

### 3. **Quản lý schedules**
```bash
# List schedules
velero get schedules

# Tạo schedule mới
velero create schedule gitlab-daily-backup \
    --schedule="0 2 * * *" \
    --include-namespaces gitlab \
    --ttl 30d

# Xóa schedule
velero delete schedule gitlab-backup
```

### 4. **Monitor backups**
```bash
# Xem status backup
velero describe backup gitlab-manual-backup

# Xem logs backup
velero logs backup gitlab-manual-backup

# Xem restore status
velero describe restore gitlab-restore-20240910
```

## Troubleshooting

### 1. **Backup failed**
```bash
# Kiểm tra logs
kubectl logs -n velero deployment/velero

# Kiểm tra backup status
velero describe backup <backup-name>

# Kiểm tra S3 permissions
aws s3 ls s3://eks-prod-velero-backups-190749975524/
```

### 2. **Restore failed**
```bash
# Kiểm tra restore logs
velero logs restore <restore-name>

# Kiểm tra namespace conflicts
kubectl get namespaces
kubectl get pods -n gitlab
```

### 3. **Volume backup issues**
```bash
# Kiểm tra restic daemonset
kubectl get pods -n velero -l app.kubernetes.io/name=restic

# Kiểm tra volume snapshots
velero get volume-snapshots
```

## Monitoring

### 1. **Health checks**
```bash
# Kiểm tra Velero server status
kubectl get pods -n velero

# Kiểm tra backup location
velero get backup-locations

# Kiểm tra volume snapshot locations
velero get volume-snapshot-locations
```

### 2. **Metrics**
```bash
# Port forward để xem metrics
kubectl port-forward -n velero deployment/velero 8085:8085

# Truy cập metrics: http://localhost:8085/metrics
```

## Best Practices

### 1. **Backup Strategy**
- **Daily backups**: Tự động backup mỗi ngày
- **Weekly full backup**: Backup toàn bộ cluster
- **Retention policy**: Giữ backup 30-90 ngày
- **Cross-region**: Backup sang region khác

### 2. **Testing**
- **Regular restore tests**: Test restore định kỳ
- **Disaster recovery drills**: Test toàn bộ quy trình
- **Documentation**: Ghi lại quy trình restore

### 3. **Security**
- **Encryption**: S3 bucket encryption enabled
- **Access control**: IAM roles với least privilege
- **Audit logging**: CloudTrail cho backup activities

## Lưu ý quan trọng

1. **Namespace gitlab**: Chỉ backup namespace này theo yêu cầu
2. **EBS Snapshots**: Tự động tạo snapshot cho persistent volumes
3. **S3 Storage**: Backup data được lưu trên S3 với encryption
4. **IRSA**: Sử dụng IAM Roles for Service Accounts
5. **Monitoring**: Cần monitor backup success/failure rates

## Commands Reference

```bash
# Backup commands
velero backup create <name> --include-namespaces <namespace>
velero backup create <name> --include-namespaces <namespace> --ttl <duration>
velero get backups
velero describe backup <name>
velero delete backup <name>

# Restore commands
velero restore create --from-backup <backup-name>
velero restore create <name> --from-backup <backup-name>
velero get restores
velero describe restore <name>

# Schedule commands
velero create schedule <name> --schedule="0 2 * * *" --include-namespaces <namespace>
velero get schedules
velero delete schedule <name>

# General commands
velero get backup-locations
velero get volume-snapshot-locations
velero logs backup <name>
velero logs restore <name>
```
