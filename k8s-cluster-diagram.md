# Kind Cluster and Namespace Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Docker Host                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                Kind Cluster                           │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │              Control Plane                      │  │  │
│  │  │  ┌─────────────────────────────────────────┐    │  │  │
│  │  │  │            API Server                  │    │  │  │
│  │  │  │  ┌───────────────────────────────────┐  │    │  │  │
│  │  │  │  │         Namespaces               │  │    │  │  │
│  │  │  │  │                                  │  │    │  │  │
│  │  │  │  │  ┌─────────────────────────────┐ │  │    │  │  │
│  │  │  │  │  │      default namespace     │ │  │    │  │  │
│  │  │  │  │  └─────────────────────────────┘ │  │    │  │  │
│  │  │  │  │                                  │  │    │  │  │
│  │  │  │  │  ┌─────────────────────────────┐ │  │    │  │  │
│  │  │  │  │  │    kube-system namespace    │ │  │    │  │  │
│  │  │  │  │  └─────────────────────────────┘ │  │    │  │  │
│  │  │  │  │                                  │  │    │  │  │
│  │  │  │  │  ┌─────────────────────────────┐ │  │    │  │  │
│  │  │  │  │  │    your-namespace           │ │  │    │  │  │
│  │  │  │  │  │  ┌─────────────────────┐    │ │  │    │  │  │
│  │  │  │  │  │  │     Pods            │    │ │  │    │  │  │
│  │  │  │  │  │  │     Services        │    │ │  │    │  │  │
│  │  │  │  │  │  │     ConfigMaps      │    │ │  │    │  │  │
│  │  │  │  │  │  │     Secrets         │    │ │  │    │  │  │
│  │  │  │  │  │  └─────────────────────┘    │ │  │    │  │  │
│  │  │  │  │  └─────────────────────────────┘ │  │    │  │  │
│  │  │  │  └───────────────────────────────────┘  │    │  │  │
│  │  │  └─────────────────────────────────────────┘    │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │                Worker Nodes                     │  │  │
│  │  │  (In Kind, these are also Docker containers)    │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

                              │
                              ▼
                    ┌─────────────────────┐
                    │     kubectl CLI     │
                    │                     │
                    │  kubectl get ns     │
                    │  kubectl create ns  │
                    │  kubectl apply -f   │
                    └─────────────────────┘
```

## Relationship Breakdown:

1. **Kind Cluster**: A Kubernetes cluster running in Docker containers
   - Creates a complete K8s environment locally
   - Runs control plane and worker nodes as Docker containers

2. **Namespaces**: Logical partitions within the cluster
   - Provide resource isolation
   - Allow multiple teams/applications to share the same cluster
   - Created and managed via kubectl commands

3. **Connection Flow**:
   ```
   kubectl command → Kind cluster API server → Namespace operations
   ```

## Key Commands Used:

```bash
# Create Kind cluster
kind create cluster --name my-cluster

# Create namespace
kubectl create namespace my-namespace

# List namespaces
kubectl get namespaces

# Set context to use specific namespace
kubectl config set-context --current --namespace=my-namespace
```

The namespace exists as a logical boundary within your Kind cluster, managed through the Kubernetes API server that Kind provides.
