# 🏗️ Kubernetes Architecture Diagrams

## **Kiến trúc tổng quan Kubernetes**

```mermaid
graph TB
    subgraph "Control Plane"
        API[API Server]
        ETCD[(etcd)]
        SCHED[Scheduler]
        CM[Controller Manager]
    end
    
    subgraph "Worker Node 1"
        KUBELET1[kubelet]
        PROXY1[kube-proxy]
        RUNTIME1[Container Runtime]
        POD1[Pods]
    end
    
    subgraph "Worker Node 2"
        KUBELET2[kubelet]
        PROXY2[kube-proxy]
        RUNTIME2[Container Runtime]
        POD2[Pods]
    end
    
    subgraph "Worker Node N"
        KUBELETN[kubelet]
        PROXYN[kube-proxy]
        RUNTIMEN[Container Runtime]
        PODN[Pods]
    end
    
    API --> ETCD
    API --> SCHED
    API --> CM
    API --> KUBELET1
    API --> KUBELET2
    API --> KUBELETN
    
    SCHED --> KUBELET1
    SCHED --> KUBELET2
    SCHED --> KUBELETN
    
    KUBELET1 --> RUNTIME1
    KUBELET2 --> RUNTIME2
    KUBELETN --> RUNTIMEN
    
    RUNTIME1 --> POD1
    RUNTIME2 --> POD2
    RUNTIMEN --> PODN
```

## **Chi tiết Control Plane Components**

```mermaid
graph LR
    subgraph "Control Plane"
        subgraph "API Server"
            API1[REST API]
            API2[Authentication]
            API3[Authorization]
            API4[Admission Control]
        end
        
        subgraph "etcd"
            ETCD1[Cluster State]
            ETCD2[Configuration]
            ETCD3[Secrets]
        end
        
        subgraph "Scheduler"
            SCHED1[Node Selection]
            SCHED2[Resource Requirements]
            SCHED3[Constraints]
        end
        
        subgraph "Controller Manager"
            CM1[Deployment Controller]
            CM2[ReplicaSet Controller]
            CM3[Service Controller]
            CM4[Node Controller]
        end
    end
    
    API1 --> ETCD1
    API1 --> SCHED1
    API1 --> CM1
```

## **Pod Lifecycle**

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Running : Container started
    Pending --> Failed : Container failed to start
    Running --> Succeeded : Container completed successfully
    Running --> Failed : Container failed
    Running --> Running : Container restarted
    Succeeded --> [*]
    Failed --> [*]
```

## **Service Types**

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "Pod"
            APP[Application]
        end
        
        subgraph "Services"
            CLUSTERIP[ClusterIP<br/>Internal only]
            NODEPORT[NodePort<br/>Node IP:Port]
            LOADBALANCER[LoadBalancer<br/>External IP]
            EXTERNALNAME[ExternalName<br/>External DNS]
        end
        
        subgraph "External"
            USER[User/Client]
            EXTERNAL[External Service]
        end
    end
    
    APP --> CLUSTERIP
    APP --> NODEPORT
    APP --> LOADBALANCER
    APP --> EXTERNALNAME
    
    USER --> NODEPORT
    USER --> LOADBALANCER
    EXTERNALNAME --> EXTERNAL
```

## **Deployment Strategy**

```mermaid
graph TB
    subgraph "Rolling Update"
        OLD1[Old Pod 1]
        OLD2[Old Pod 2]
        OLD3[Old Pod 3]
        
        NEW1[New Pod 1]
        NEW2[New Pod 2]
        NEW3[New Pod 3]
    end
    
    OLD1 --> NEW1
    OLD2 --> NEW2
    OLD3 --> NEW3
    
    subgraph "Blue-Green Deployment"
        BLUE[Blue Environment<br/>Current Version]
        GREEN[Green Environment<br/>New Version]
        LB[Load Balancer]
    end
    
    LB --> BLUE
    LB -.-> GREEN
```

## **Storage Architecture**

```mermaid
graph TB
    subgraph "Storage Layer"
        PV[PersistentVolume<br/>Cluster Resource]
        PVC[PersistentVolumeClaim<br/>User Request]
        SC[StorageClass<br/>Provisioner]
    end
    
    subgraph "Pod"
        VM[Volume Mount]
        APP[Application]
    end
    
    subgraph "External Storage"
        EBS[AWS EBS]
        NFS[NFS Server]
        CEPH[Ceph Storage]
    end
    
    PVC --> PV
    SC --> PV
    PV --> EBS
    PV --> NFS
    PV --> CEPH
    PV --> VM
    VM --> APP
```

## **Network Architecture**

```mermaid
graph TB
    subgraph "Pod Network"
        POD1[Pod 1<br/>10.244.1.2]
        POD2[Pod 2<br/>10.244.2.3]
        POD3[Pod 3<br/>10.244.1.4]
    end
    
    subgraph "Services"
        SVC1[Service 1<br/>10.96.1.1]
        SVC2[Service 2<br/>10.96.2.2]
    end
    
    subgraph "DNS"
        COREDNS[CoreDNS<br/>10.96.0.10]
    end
    
    subgraph "Ingress"
        INGRESS[Ingress Controller]
        LB[Load Balancer]
    end
    
    POD1 --> SVC1
    POD2 --> SVC1
    POD3 --> SVC2
    
    SVC1 --> COREDNS
    SVC2 --> COREDNS
    
    LB --> INGRESS
    INGRESS --> SVC1
    INGRESS --> SVC2
```

## **Security Architecture**

```mermaid
graph TB
    subgraph "Authentication & Authorization"
        USER[User]
        SA[Service Account]
        RBAC[RBAC]
        PSP[Pod Security Policy]
    end
    
    subgraph "Network Security"
        NP[Network Policy]
        CNI[CNI Plugin]
    end
    
    subgraph "Secrets Management"
        SECRET[Secrets]
        CM[ConfigMaps]
        VAULT[External Vault]
    end
    
    USER --> RBAC
    SA --> RBAC
    RBAC --> PSP
    PSP --> NP
    NP --> CNI
    SECRET --> VAULT
    CM --> SECRET
```

## **Monitoring & Observability**

```mermaid
graph TB
    subgraph "Applications"
        APP1[App 1]
        APP2[App 2]
        APP3[App 3]
    end
    
    subgraph "Metrics Collection"
        METRICS[Metrics Server]
        PROMETHEUS[Prometheus]
        EXPORTER[Exporters]
    end
    
    subgraph "Logging"
        FLUENTD[Fluentd]
        ELASTICSEARCH[Elasticsearch]
        KIBANA[Kibana]
    end
    
    subgraph "Tracing"
        JAEGER[Jaeger]
        ZIPKIN[Zipkin]
    end
    
    subgraph "Visualization"
        GRAFANA[Grafana]
        DASHBOARD[Kubernetes Dashboard]
    end
    
    APP1 --> METRICS
    APP2 --> METRICS
    APP3 --> METRICS
    
    METRICS --> PROMETHEUS
    EXPORTER --> PROMETHEUS
    
    APP1 --> FLUENTD
    APP2 --> FLUENTD
    APP3 --> FLUENTD
    
    FLUENTD --> ELASTICSEARCH
    ELASTICSEARCH --> KIBANA
    
    PROMETHEUS --> GRAFANA
    ELASTICSEARCH --> GRAFANA
```

## **Cách sử dụng diagrams**

1. **Copy code Mermaid** từ các diagram trên
2. **Paste vào** [Mermaid Live Editor](https://mermaid.live/)
3. **Hoặc sử dụng** VS Code với Mermaid extension
4. **Hoặc tích hợp** vào documentation tools

## **Lưu ý quan trọng**

- **Control Plane**: Quản lý cluster state và scheduling
- **Worker Nodes**: Chạy applications và workloads
- **Pods**: Đơn vị nhỏ nhất có thể deploy
- **Services**: Cung cấp stable network endpoint
- **Volumes**: Persistent storage cho applications
- **Security**: Multi-layer security với RBAC, Network Policies
- **Monitoring**: Comprehensive observability stack
