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
#### **ConfigMap Concepts:**
- **Decouple configuration** from application code
- **Environment-specific** configurations
- **Volume mounting** hoặc environment variables

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
#### **Secret Types:**
- **Opaque**: Arbitrary user data
- **kubernetes.io/service-account-token**: Service account token
- **kubernetes.io/dockercfg**: Docker registry credentials
- **kubernetes.io/tls**: TLS certificate

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
#### **Volume Types:**
- **emptyDir**: Temporary storage
- **hostPath**: Node filesystem
- **persistentVolumeClaim**: Persistent storage
- **configMap/secret**: Configuration data

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
