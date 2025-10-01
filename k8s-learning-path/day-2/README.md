# Ngày 2: Deployments & Scaling 🔥🔥

**Mục tiêu**: Học cách quản lý ứng dụng với Deployments

## 📚 **Nội dung học**

### **1. Deployments - Quản lý Pods**
#### **Deployment Concepts:**
- **Declarative updates** cho Pods và ReplicaSets
- **Rolling updates** và rollbacks
- **Scaling** applications
- **Self-healing** capabilities

#### **Deployment Spec:**
```yaml
# deployment-example.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```

### **2. Thực hành Deployments**
```bash
# Tạo deployment
kubectl apply -f deployment-example.yaml

# Xem deployment
kubectl get deployments
kubectl get deployments -o wide
kubectl describe deployment nginx-deployment

# Xem ReplicaSet
kubectl get replicasets
kubectl describe replicaset nginx-deployment-xxx

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5
kubectl scale deployment nginx-deployment --replicas=3

# Rolling update
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
kubectl rollout status deployment/nginx-deployment

# Xem rollout history
kubectl rollout history deployment/nginx-deployment
kubectl rollout history deployment/nginx-deployment --revision=2

# Rollback
kubectl rollout undo deployment/nginx-deployment
kubectl rollout undo deployment/nginx-deployment --to-revision=1

# Pause/Resume rollout
kubectl rollout pause deployment/nginx-deployment
kubectl rollout resume deployment/nginx-deployment
```

### **3. ReplicaSets**
```yaml
# replicaset-example.yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
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

### **4. ConfigMaps - Configuration Management**
#### **ConfigMap là gì?**
- **API object** để store non-confidential data
- **Key-value pairs** cho configuration data
- **Decouple configuration** from application code
- **Environment-specific** configurations

#### **Tại sao cần ConfigMaps?**
- **Separation of concerns**: Tách config khỏi application code
- **Environment management**: Different configs cho dev/staging/prod
- **Configuration updates**: Update config mà không cần rebuild image
- **Reusability**: Share config giữa multiple pods
- **Version control**: Track configuration changes

#### **ConfigMap Use Cases:**
- **Application settings**: Database URLs, API endpoints
- **Feature flags**: Enable/disable features
- **Logging configuration**: Log levels, output formats
- **Environment variables**: Non-sensitive environment data

#### **Tạo ConfigMap:**
```bash
# Từ literal values
kubectl create configmap app-config --from-literal=database_url=mysql://localhost:3306/mydb --from-literal=debug=true

# Từ file
kubectl create configmap app-config --from-file=config.properties

# Từ directory
kubectl create configmap app-config --from-file=config/

# Từ YAML
kubectl apply -f configmap.yaml
```

#### **ConfigMap Spec:**
```yaml
# configmap-example.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  database_url: "mysql://localhost:3306/mydb"
  debug: "true"
  log_level: "info"
  max_connections: "100"
  # Binary data
  binaryData:
    config.bin: "SGVsbG8gV29ybGQ="
```

#### **Sử dụng ConfigMap:**
```yaml
# Environment variables
env:
- name: DATABASE_URL
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: database_url
- name: DEBUG
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: debug

# Volume mounting
volumeMounts:
- name: config-volume
  mountPath: /etc/config
volumes:
- name: config-volume
  configMap:
    name: app-config
```

### **5. Secrets - Sensitive Data Management**
#### **Secrets là gì?**
- **API object** để store sensitive data
- **Base64 encoded** (không phải encrypted)
- **Similar to ConfigMaps** nhưng cho sensitive data
- **Automatic mounting** vào pods

#### **Tại sao cần Secrets?**
- **Security**: Store passwords, API keys, certificates
- **Separation**: Tách sensitive data khỏi application code
- **Access control**: RBAC để control access
- **Encryption**: Có thể encrypt at rest với encryption providers

#### **Secret Types:**
- **Opaque**: Arbitrary user data (default)
- **kubernetes.io/service-account-token**: Service account token
- **kubernetes.io/dockercfg**: Docker registry credentials
- **kubernetes.io/tls**: TLS certificate
- **kubernetes.io/ssh-auth**: SSH keys

#### **Tạo Secrets:**
```bash
# Từ literal values
kubectl create secret generic app-secret --from-literal=username=admin --from-literal=password=secret123

# Từ file
kubectl create secret generic app-secret --from-file=username.txt --from-file=password.txt

# Từ YAML
kubectl apply -f secret.yaml
```

#### **Secret Spec:**
```yaml
# secret-example.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: default
type: Opaque
data:
  username: YWRtaW4=  # admin (base64 encoded)
  password: c2VjcmV0MTIz  # secret123 (base64 encoded)
  api_key: YWJjZGVmZ2hpams=  # abcdefghijk (base64 encoded)
```

#### **Sử dụng Secrets:**
```yaml
# Environment variables
env:
- name: DB_USERNAME
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: username
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: password

# Volume mounting
volumeMounts:
- name: secret-volume
  mountPath: /etc/secrets
  readOnly: true
volumes:
- name: secret-volume
  secret:
    secretName: app-secret
```

### **6. Volumes & Persistent Storage**
#### **Volumes là gì?**
- **Storage abstraction** cho pods
- **Lifecycle independent** của pods
- **Multiple types** cho different use cases
- **Mount points** trong containers

#### **Tại sao cần Volumes?**
- **Data persistence**: Data survive pod restarts
- **Data sharing**: Share data giữa containers trong pod
- **Configuration**: Mount config files và secrets
- **Backup**: Persistent data có thể backup

#### **Volume Types:**
- **emptyDir**: Temporary storage (pod lifecycle)
- **hostPath**: Node filesystem (development only)
- **persistentVolumeClaim**: Persistent storage (production)
- **configMap/secret**: Configuration data
- **downwardAPI**: Pod metadata
- **projected**: Multiple volume sources

#### **PersistentVolume (PV):**
```yaml
# pv-example.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: app-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: gp2
  awsElasticBlockStore:
    volumeID: vol-12345678
    fsType: ext4
```

#### **PersistentVolumeClaim (PVC):**
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
  storageClassName: gp2
```

#### **Sử dụng Volumes:**
```yaml
# Volume mounting
volumeMounts:
- name: app-storage
  mountPath: /var/www/html
- name: config-volume
  mountPath: /etc/config
volumes:
- name: app-storage
  persistentVolumeClaim:
    claimName: app-pvc
- name: config-volume
  configMap:
    name: app-config
```

### **7. StatefulSets - Stateful Applications**
#### **StatefulSets là gì?**
- **Workload API object** cho stateful applications
- **Stable, unique network identifiers** cho pods
- **Stable, persistent storage** cho pods
- **Ordered, graceful deployment** và scaling

#### **Tại sao cần StatefulSets?**
- **Database applications**: MySQL, PostgreSQL, MongoDB
- **Distributed systems**: Elasticsearch, Kafka clusters
- **Stable identity**: Pods có stable hostname và storage
- **Ordered operations**: Deploy, scale, update theo thứ tự

#### **StatefulSet Features:**
- **Stable network identity**: Pod name + ordinal
- **Stable storage**: PersistentVolumeClaim template
- **Ordered deployment**: Pods created theo thứ tự
- **Ordered scaling**: Pods terminated theo thứ tự ngược
- **Ordered updates**: Rolling updates theo thứ tự

#### **StatefulSet vs Deployment:**
| Feature | Deployment | StatefulSet |
|---------|------------|-------------|
| Pod identity | Random | Stable |
| Storage | Ephemeral | Persistent |
| Scaling | Any order | Ordered |
| Updates | Rolling | Ordered rolling |
| Use case | Stateless apps | Stateful apps |
```yaml
# statefulset-example.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
spec:
  serviceName: mysql-service
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### **8. Horizontal Pod Autoscaler (HPA)**
#### **HPA là gì?**
- **Automatic scaling** dựa trên metrics
- **Horizontal scaling**: Tăng/giảm số pods
- **Resource-based scaling**: CPU, memory, custom metrics
- **Target utilization**: Maintain target resource usage

#### **Tại sao cần HPA?**
- **Cost optimization**: Scale down khi ít traffic
- **Performance**: Scale up khi high load
- **Automation**: Không cần manual intervention
- **Resource efficiency**: Right-size applications

#### **HPA Metrics:**
- **Resource metrics**: CPU, memory usage
- **Pods metrics**: Pod-level metrics
- **Object metrics**: Ingress, Service metrics
- **External metrics**: Custom application metrics

#### **HPA Scaling Behavior:**
- **Scale up**: Khi metrics > target
- **Scale down**: Khi metrics < target
- **Cooldown periods**: Prevent rapid scaling
- **Stabilization**: Gradual scaling changes
```yaml
# hpa-example.yaml
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
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
```

### **9. Jobs và CronJobs**
#### **Jobs là gì?**
- **One-time tasks** hoặc batch jobs
- **Run to completion**: Job chạy đến khi hoàn thành
- **Parallel execution**: Multiple pods cho parallel processing
- **Retry mechanism**: Retry failed jobs

#### **Tại sao cần Jobs?**
- **Batch processing**: Data processing, ETL jobs
- **One-time tasks**: Database migrations, cleanup
- **Parallel processing**: Distribute work across pods
- **Reliability**: Automatic retry on failure

#### **CronJobs là gì?**
- **Scheduled Jobs**: Chạy jobs theo schedule
- **Cron syntax**: Standard cron expressions
- **Time-based execution**: Daily, weekly, monthly tasks
- **Job history**: Keep track of job executions

#### **Job Types:**
- **Non-parallel Jobs**: Single pod, run once
- **Parallel Jobs with fixed completion count**: Multiple pods, fixed completion
- **Parallel Jobs with work queue**: Multiple pods, process queue
```yaml
# job-example.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
spec:
  template:
    spec:
      containers:
      - name: backup
        image: busybox
        command: ["sh", "-c", "echo 'Backup completed'"]
      restartPolicy: Never
  backoffLimit: 3
```

```yaml
# cronjob-example.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cronjob
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ["sh", "-c", "echo 'Scheduled backup'"]
          restartPolicy: OnFailure
```

### **10. Resource Quotas và Limits**
#### **Resource Quotas là gì?**
- **Namespace-level resource limits**: Giới hạn resources per namespace
- **Prevent resource exhaustion**: Tránh một namespace chiếm hết resources
- **Multi-tenancy**: Isolate resources giữa teams/projects
- **Cost control**: Control resource usage và costs

#### **Tại sao cần Resource Quotas?**
- **Resource isolation**: Prevent resource conflicts
- **Fair sharing**: Ensure fair resource distribution
- **Cost management**: Control resource costs
- **Security**: Prevent resource abuse

#### **Resource Quota Types:**
- **Compute resources**: CPU, memory requests/limits
- **Storage resources**: PersistentVolumeClaims
- **Object counts**: Pods, Services, ConfigMaps, Secrets
- **Extended resources**: GPU, custom resources

#### **LimitRanges là gì?**
- **Default resource limits**: Set default requests/limits
- **Resource constraints**: Min/max resource values
- **Container-level limits**: Per-container resource limits
- **Namespace-wide defaults**: Apply to all containers
```yaml
# resourcequota-example.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    persistentvolumeclaims: "10"
```

```yaml
# limitrange-example.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: "512Mi"
      cpu: "500m"
    defaultRequest:
      memory: "256Mi"
      cpu: "250m"
    type: Container
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
