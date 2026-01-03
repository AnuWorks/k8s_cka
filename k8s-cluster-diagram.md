# Kubernetes Cluster Architecture with Multi-Environment Setup

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Kubernetes Cluster                                   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                              Control Plane Node                                │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐  │   │
│  │  │ API Server  │ │   etcd      │ │ Scheduler   │ │ Controller  │ │  CCM    │  │   │
│  │  │             │ │             │ │             │ │  Manager    │ │         │  │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                Worker Node 1                                   │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │   │
│  │  │   kubelet   │ │ kube-proxy  │ │ Container   │ │   CNI       │              │   │
│  │  │             │ │             │ │  Runtime    │ │  Plugin     │              │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘              │   │
│  │                                                                                 │   │
│  │  Taints: node-role.kubernetes.io/worker:NoSchedule                            │   │
│  │  Resource Limits: CPU: 2, Memory: 4Gi                                         │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                Worker Node 2                                   │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │   │
│  │  │   kubelet   │ │ kube-proxy  │ │ Container   │ │   CNI       │              │   │
│  │  │             │ │             │ │  Runtime    │ │  Plugin     │              │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘              │   │
│  │                                                                                 │   │
│  │  Taints: node-role.kubernetes.io/worker:NoSchedule                            │   │
│  │  Resource Limits: CPU: 2, Memory: 4Gi                                         │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    NAMESPACES                                           │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                              default namespace                                  │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │                          System Pods                                   │   │   │
│  │  └─────────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                            kube-system namespace                                │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │  CoreDNS │ kube-proxy │ CNI │ Metrics Server │ Dashboard                │   │   │
│  │  └─────────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                dev namespace                                    │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐         │   │   │
│  │  │ │nginx-pod    │ │postgres-pod │ │ ConfigMaps  │ │  Secrets    │         │   │   │
│  │  │ │nginx:latest │ │postgres:13  │ │ app-config  │ │ db-password │         │   │   │
│  │  │ │CPU: 100m    │ │CPU: 200m    │ │ nginx.conf  │ │ tls-certs   │         │   │   │
│  │  │ │Mem: 128Mi   │ │Mem: 512Mi   │ └─────────────┘ └─────────────┘         │   │   │
│  │  │ │Tolerations: │ │Tolerations: │                                         │   │   │
│  │  │ │worker-taint │ │worker-taint │                                         │   │   │
│  │  │ └─────────────┘ └─────────────┘                                         │   │   │
│  │  │                                                                         │   │   │
│  │  │ ┌─────────────┐ ┌─────────────┐                                         │   │   │
│  │  │ │nginx-svc    │ │postgres-svc │                                         │   │   │
│  │  │ │Type: LB     │ │Type: ClusterIP                                        │   │   │
│  │  │ │Port: 80     │ │Port: 5432   │                                         │   │   │
│  │  │ └─────────────┘ └─────────────┘                                         │   │   │
│  │  └─────────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                               test namespace                                    │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐         │   │   │
│  │  │ │nginx-pod    │ │postgres-pod │ │ ConfigMaps  │ │  Secrets    │         │   │   │
│  │  │ │nginx:latest │ │postgres:13  │ │ app-config  │ │ db-password │         │   │   │
│  │  │ │CPU: 150m    │ │CPU: 300m    │ │ nginx.conf  │ │ tls-certs   │         │   │   │
│  │  │ │Mem: 256Mi   │ │Mem: 1Gi     │ └─────────────┘ └─────────────┘         │   │   │
│  │  │ │Tolerations: │ │Tolerations: │                                         │   │   │
│  │  │ │worker-taint │ │worker-taint │                                         │   │   │
│  │  │ └─────────────┘ └─────────────┘                                         │   │   │
│  │  │                                                                         │   │   │
│  │  │ ┌─────────────┐ ┌─────────────┐                                         │   │   │
│  │  │ │nginx-svc    │ │postgres-svc │                                         │   │   │
│  │  │ │Type: LB     │ │Type: ClusterIP                                        │   │   │
│  │  │ │Port: 80     │ │Port: 5432   │                                         │   │   │
│  │  │ └─────────────┘ └─────────────┘                                         │   │   │
│  │  └─────────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                               prod namespace                                    │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐         │   │   │
│  │  │ │nginx-pod    │ │postgres-pod │ │ ConfigMaps  │ │  Secrets    │         │   │   │
│  │  │ │nginx:stable │ │postgres:13  │ │ app-config  │ │ db-password │         │   │   │
│  │  │ │CPU: 500m    │ │CPU: 1000m   │ │ nginx.conf  │ │ tls-certs   │         │   │   │
│  │  │ │Mem: 1Gi     │ │Mem: 4Gi     │ └─────────────┘ └─────────────┘         │   │   │
│  │  │ │Tolerations: │ │Tolerations: │                                         │   │   │
│  │  │ │worker-taint │ │worker-taint │                                         │   │   │
│  │  │ └─────────────┘ └─────────────┘                                         │   │   │
│  │  │                                                                         │   │   │
│  │  │ ┌─────────────┐ ┌─────────────┐                                         │   │   │
│  │  │ │nginx-svc    │ │postgres-svc │                                         │   │   │
│  │  │ │Type: LB     │ │Type: ClusterIP                                        │   │   │
│  │  │ │Port: 80     │ │Port: 5432   │                                         │   │   │
│  │  │ └─────────────┘ └─────────────┘                                         │   │   │
│  │  └─────────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

## Architecture Components Breakdown:

### Control Plane Components:
- **API Server**: Central management component, handles all REST operations
- **etcd**: Distributed key-value store for cluster data
- **Scheduler**: Assigns pods to nodes based on resource requirements
- **Controller Manager**: Runs controller processes
- **Cloud Controller Manager (CCM)**: Manages cloud-specific controllers

### Worker Node Components:
- **kubelet**: Node agent that communicates with control plane
- **kube-proxy**: Network proxy maintaining network rules
- **Container Runtime**: Runs containers (Docker/containerd)
- **CNI Plugin**: Container Network Interface for pod networking

### Namespace Strategy:
- **default**: Basic system resources
- **kube-system**: Core Kubernetes components
- **dev**: Development environment with lower resource limits
- **test**: Testing environment with moderate resources
- **prod**: Production environment with high availability and resources

### Application Architecture:

#### Web Tier (nginx):
- **Image**: nginx:latest (dev/test), nginx:stable (prod)
- **Service**: LoadBalancer type exposing port 80
- **Resource Limits**: Scaled per environment
- **ConfigMaps**: nginx.conf for custom configuration

#### Database Tier (PostgreSQL):
- **Image**: postgres:13 across all environments
- **Service**: ClusterIP (internal access only)
- **Security**: Secrets for passwords and TLS certificates
- **Resource Limits**: Memory and CPU scaled per environment

### Security & Resource Management:

#### Taints and Tolerations:
```yaml
# Worker node taints
node-role.kubernetes.io/worker:NoSchedule

# Pod tolerations
tolerations:
- key: "node-role.kubernetes.io/worker"
  operator: "Equal"
  effect: "NoSchedule"
```

#### Resource Limits by Environment:
- **Dev**: nginx (100m CPU, 128Mi RAM), postgres (200m CPU, 512Mi RAM)
- **Test**: nginx (150m CPU, 256Mi RAM), postgres (300m CPU, 1Gi RAM)  
- **Prod**: nginx (500m CPU, 1Gi RAM), postgres (1000m CPU, 4Gi RAM)

#### ConfigMaps and Secrets:
- **ConfigMaps**: Application configuration, nginx.conf
- **Secrets**: Database passwords, TLS certificates

### Network Flow:
```
External Traffic → LoadBalancer Service → nginx Pod → postgres Service → postgres Pod
```

### Key Commands:

```bash
# Create namespaces
kubectl create namespace dev
kubectl create namespace test
kubectl create namespace prod

# Apply taints to worker nodes
kubectl taint nodes worker-node-1 node-role.kubernetes.io/worker:NoSchedule
kubectl taint nodes worker-node-2 node-role.kubernetes.io/worker:NoSchedule

# Deploy applications with resource limits
kubectl apply -f nginx-deployment.yaml -n dev
kubectl apply -f postgres-deployment.yaml -n dev

# Create services
kubectl expose deployment nginx --type=LoadBalancer --port=80 -n dev
kubectl expose deployment postgres --type=ClusterIP --port=5432 -n dev

# Create ConfigMaps and Secrets
kubectl create configmap app-config --from-file=nginx.conf -n dev
kubectl create secret generic db-password --from-literal=password=<password> -n dev
```
