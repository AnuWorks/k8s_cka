# Updated Day 2 with correct cluster info and namespace approach

#### Main Tasks

**Task 2.1: Multi-Level RBAC Setup (25 min)**
```bash
# Get your cluster server URL
CLUSTER_SERVER=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}')

# Create ClusterRole for admin
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: admin-role
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
EOF

# Create Role for developer (namespace-specific)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: cka-day2
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch"]
EOF

# Create bindings
kubectl create clusterrolebinding admin-binding --clusterrole=admin-role --user=admin
kubectl create rolebinding developer-binding --role=developer-role --user=developer -n cka-day2

# Create kubeconfigs with correct cluster name
kubectl config set-cluster kind-cka-cluster-1 --server=$CLUSTER_SERVER --certificate-authority=ca.crt --kubeconfig=developer.kubeconfig
kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key --kubeconfig=developer.kubeconfig
kubectl config set-context developer-context --cluster=kind-cka-cluster-1 --user=developer --namespace=cka-day2 --kubeconfig=developer.kubeconfig
kubectl config use-context developer-context --kubeconfig=developer.kubeconfig

kubectl config set-cluster kind-cka-cluster-1 --server=$CLUSTER_SERVER --certificate-authority=ca.crt --kubeconfig=admin.kubeconfig
kubectl config set-credentials admin --client-certificate=admin.crt --client-key=admin.key --kubeconfig=admin.kubeconfig
kubectl config set-context admin-context --cluster=kind-cka-cluster-1 --user=admin --kubeconfig=admin.kubeconfig
kubectl config use-context admin-context --kubeconfig=admin.kubeconfig
```

**Task 2.2: Security Context Implementation (20 min)**
```bash
# Create pod with security context
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: cka-day2
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: secure-container
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
    - name: var-run
      mountPath: /var/run
  volumes:
  - name: tmp-volume
    emptyDir: {}
  - name: var-run
    emptyDir: {}
EOF

# Create service account with limited permissions
kubectl create serviceaccount limited-sa -n cka-day2

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: cka-day2
  name: limited-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
EOF

kubectl create rolebinding limited-binding --role=limited-role --serviceaccount=cka-day2:limited-sa -n cka-day2
```

#### Debug Scenarios

**Debug 2.1: Permission Denied Issues (10 min)**
```bash
# Try operations that should fail
echo "=== Testing developer permissions ==="

# Should work
kubectl --kubeconfig=developer.kubeconfig get pods -n cka-day2
kubectl --kubeconfig=developer.kubeconfig create deployment test-deploy --image=nginx -n cka-day2

# Should fail - wrong namespace
kubectl --kubeconfig=developer.kubeconfig get pods -n default

# Should fail - no permission for secrets
kubectl --kubeconfig=developer.kubeconfig get secrets -n cka-day2

# Debug steps:
echo "Debugging permission issues..."

# 1. Check what user can do
kubectl --kubeconfig=developer.kubeconfig auth can-i get pods -n cka-day2
kubectl --kubeconfig=developer.kubeconfig auth can-i get secrets -n cka-day2
kubectl --kubeconfig=developer.kubeconfig auth can-i get pods -n default

# 2. Check role bindings
kubectl get rolebinding developer-binding -n cka-day2 -o yaml

# 3. Check role permissions
kubectl get role developer-role -n cka-day2 -o yaml
```

**Debug 2.2: Security Context Failures (5 min)**
```bash
# Create pod that should fail security policies
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: insecure-pod
  namespace: cka-day2
spec:
  containers:
  - name: insecure-container
    image: nginx
    securityContext:
      privileged: true
      runAsUser: 0
EOF

# Check pod status
kubectl get pod insecure-pod -n cka-day2
kubectl describe pod insecure-pod -n cka-day2

# Debug: Compare with secure pod
kubectl get pod secure-pod -n cka-day2 -o yaml | grep -A20 securityContext
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 2 Cleanup
echo "=== Day 2 Cleanup ==="

# Remove namespace and all resources
kubectl delete namespace cka-day2

# Remove cluster resources
kubectl delete clusterrole admin-role
kubectl delete clusterrolebinding admin-binding

# Remove files
rm -rf ~/cka-day2

echo "Day 2 cleanup complete"
```
