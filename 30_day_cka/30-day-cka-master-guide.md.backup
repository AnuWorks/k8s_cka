# 30-Day CKA Master Preparation Guide
**Cluster:** kind-cka-cluster-1 (Kind cluster)  
**Daily Time:** 1 hour  
**Total Duration:** 30 days  
**Exam Focus:** Hands-on debugging and troubleshooting

---

## Cluster Information
- **Cluster Name:** kind-cka-cluster-1
- **API Server:** https://127.0.0.1:49582
- **Nodes:** cka-cluster-1-control-plane, cka-cluster-1-worker, cka-cluster-1-worker2
- **Kubernetes Version:** v1.35.0
- **Existing Namespaces:** default, dev, kube-node-lease, kube-public, kube-system, local-path-storage

---

## Guide Structure
Each day includes:
- **Task Summary** - What you'll accomplish
- **Expected Outcome** - Skills gained
- **Setup Scripts** - Resource creation with daily namespace
- **Debug Scenarios** - Real exam-like problems
- **Cleanup Scripts** - Environment reset

---

## Week 1: Foundation & Cluster Management

### Day 1: Cluster Architecture & Certificate Deep Dive
**Time:** 60 minutes  
**Focus:** Understanding cluster components and PKI

#### Task Summary
- Examine cluster architecture
- Deep dive into certificate management
- Debug certificate issues
- Practice certificate rotation

#### Expected Outcome
- Understand all cluster components
- Master certificate troubleshooting
- Know certificate locations and purposes

#### Setup Script
```bash
#!/bin/bash
# Day 1 Setup
echo "=== Day 1: Cluster Architecture Setup ==="

# Create working directory and namespace
mkdir -p ~/cka-day1 && cd ~/cka-day1
kubectl create namespace cka-day1 --dry-run=client -o yaml | kubectl apply -f -

# Get cluster info
kubectl cluster-info > cluster-info.txt
kubectl get nodes -o wide > nodes-info.txt

# Extract certificates from your actual cluster
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d > client.crt

echo "Setup complete. Files created in ~/cka-day1/"
echo "Namespace: cka-day1 created"
```

#### Main Tasks

**Task 1.1: Certificate Analysis (15 min)**
```bash
# Get your actual API server endpoint
API_SERVER=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}' | sed 's|https://||' | sed 's|http://||')
echo "API Server: $API_SERVER"

# Examine API server certificate
echo | openssl s_client -connect $API_SERVER 2>/dev/null | openssl x509 -text -noout | grep -A10 "Subject:"

# Check certificate chain
openssl verify -CAfile ca.crt client.crt

# List all certificates in kind container
docker exec -it cka-cluster-1-control-plane find /etc/kubernetes/pki/ -name "*.crt" -exec basename {} \;
```

**Task 1.2: Create Custom User Certificate (20 min)**
```bash
# Generate key and CSR
openssl genrsa -out alice.key 2048
openssl req -new -key alice.key -out alice.csr -subj "/CN=alice/O=developers"

# Get CA key from your kind cluster
docker exec -it cka-cluster-1-control-plane cat /etc/kubernetes/pki/ca.key > ca.key

# Sign certificate
openssl x509 -req -in alice.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out alice.crt -days 30

# Get your actual cluster server URL
CLUSTER_SERVER=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}')

# Create kubeconfig with correct cluster name
kubectl config set-cluster kind-cka-cluster-1 --server=$CLUSTER_SERVER --certificate-authority=ca.crt --kubeconfig=alice.kubeconfig
kubectl config set-credentials alice --client-certificate=alice.crt --client-key=alice.key --kubeconfig=alice.kubeconfig
kubectl config set-context alice-context --cluster=kind-cka-cluster-1 --user=alice --namespace=cka-day1 --kubeconfig=alice.kubeconfig
kubectl config use-context alice-context --kubeconfig=alice.kubeconfig
```

#### Debug Scenarios

**Debug 1.1: Expired Certificate (10 min)**
```bash
# Create expired certificate (simulate exam problem)
openssl x509 -req -in alice.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out alice-expired.crt -days -1

# Update kubeconfig with expired cert
kubectl config set-credentials alice --client-certificate=alice-expired.crt --client-key=alice.key --kubeconfig=alice.kubeconfig

# Try to access cluster (should fail)
kubectl --kubeconfig=alice.kubeconfig get pods

# Debug steps:
# 1. Check certificate expiry
openssl x509 -in alice-expired.crt -noout -dates

# 2. Identify the issue
echo "Certificate expired - need to renew"

# 3. Fix by creating new certificate
openssl x509 -req -in alice.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out alice-fixed.crt -days 30
kubectl config set-credentials alice --client-certificate=alice-fixed.crt --client-key=alice.key --kubeconfig=alice.kubeconfig

# 4. Verify fix
kubectl --kubeconfig=alice.kubeconfig auth can-i get pods
```

**Debug 1.2: Wrong Certificate Subject (15 min)**
```bash
# Create certificate with wrong subject
openssl req -new -key alice.key -out wrong.csr -subj "/CN=bob/O=developers"
openssl x509 -req -in wrong.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out wrong.crt -days 30

# Create RBAC for alice (not bob)
kubectl create role alice-role --verb=get,list --resource=pods -n cka-day1
kubectl create rolebinding alice-binding --role=alice-role --user=alice -n cka-day1

# Use wrong certificate
kubectl config set-credentials alice --client-certificate=wrong.crt --client-key=alice.key --kubeconfig=alice.kubeconfig

# Try to access (should fail due to RBAC)
kubectl --kubeconfig=alice.kubeconfig get pods -n cka-day1

# Debug steps:
# 1. Check certificate subject
openssl x509 -in wrong.crt -noout -subject

# 2. Check RBAC binding
kubectl get rolebinding alice-binding -n cka-day1 -o yaml

# 3. Identify mismatch (cert says bob, RBAC expects alice)
# 4. Fix by using correct certificate
kubectl config set-credentials alice --client-certificate=alice.crt --client-key=alice.key --kubeconfig=alice.kubeconfig

# 5. Verify fix
kubectl --kubeconfig=alice.kubeconfig get pods -n cka-day1
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 1 Cleanup
echo "=== Day 1 Cleanup ==="

# Remove namespace and all resources
kubectl delete namespace cka-day1

# Remove working directory
rm -rf ~/cka-day1

echo "Day 1 cleanup complete"
```

---

### Day 2: RBAC & Security Contexts
**Time:** 60 minutes  
**Focus:** Role-based access control and pod security

#### Task Summary
- Create complex RBAC scenarios
- Debug permission issues
- Implement security contexts
- Troubleshoot security policies

#### Expected Outcome
- Master RBAC debugging
- Understand security context implications
- Know how to fix permission issues

#### Setup Script
```bash
#!/bin/bash
# Day 2 Setup
echo "=== Day 2: RBAC & Security Setup ==="

mkdir -p ~/cka-day2 && cd ~/cka-day2
kubectl create namespace cka-day2 --dry-run=client -o yaml | kubectl apply -f -

# Create test users certificates
openssl genrsa -out developer.key 2048
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer/O=dev-team"

openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -out admin.csr -subj "/CN=admin/O=admin-team"

# Get CA files from your cluster
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
docker exec -it cka-cluster-1-control-plane cat /etc/kubernetes/pki/ca.key > ca.key

# Sign certificates
openssl x509 -req -in developer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out developer.crt -days 30
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt -days 30

echo "Setup complete. Ready for RBAC tasks."
```

#### Setup Script
```bash
#!/bin/bash
# Day 2 Setup
echo "=== Day 2: RBAC & Security Setup ==="

mkdir -p ~/cka-day2 && cd ~/cka-day2

# Create test namespaces
kubectl create namespace cka-day2
kubectl create namespace cka-day2

# Create test users certificates
openssl genrsa -out developer.key 2048
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer/O=dev-team"

openssl genrsa -out admin.key 2048
openssl req -new -key admin.csr -out admin.csr -subj "/CN=admin/O=admin-team"

# Get CA files
kubectl get configmap -n kube-system kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' > ca.crt
docker exec -it cka-cluster-1-control-plane cat /etc/kubernetes/pki/ca.key > ca.key

# Sign certificates
openssl x509 -req -in developer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out developer.crt -days 30
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt -days 30

echo "Setup complete. Ready for RBAC tasks."
```

#### Main Tasks

**Task 2.1: Multi-Level RBAC Setup (25 min)**
```bash
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

# Create kubeconfigs
kubectl config set-cluster kind-cka-cluster-1 --server=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=ca.crt --kubeconfig=developer.kubeconfig
kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key --kubeconfig=developer.kubeconfig
kubectl config set-context developer-context --cluster=kind-cka-cluster-1 --user=developer --namespace=cka-day2 --kubeconfig=developer.kubeconfig
kubectl config use-context developer-context --kubeconfig=developer.kubeconfig

kubectl config set-cluster kind-cka-cluster-1 --server=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=ca.crt --kubeconfig=admin.kubeconfig
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

# Remove namespaces
kubectl delete namespace cka-day2
kubectl delete namespace cka-day2

# Remove cluster resources
kubectl delete clusterrole admin-role
kubectl delete clusterrolebinding admin-binding

# Remove files
rm -rf ~/cka-day2
rm -f *.key *.crt *.csr *.kubeconfig *.srl

echo "Day 2 cleanup complete"
```

---

### Day 3: Pod Lifecycle & Troubleshooting
**Time:** 60 minutes  
**Focus:** Pod creation, debugging, and lifecycle management

#### Task Summary
- Debug pod startup issues
- Fix resource constraints
- Troubleshoot networking problems
- Handle pod scheduling issues

#### Expected Outcome
- Master pod troubleshooting
- Understand resource management
- Know how to debug networking

#### Setup Script
```bash
#!/bin/bash
# Day 3 Setup
echo "=== Day 3: Pod Lifecycle Setup ==="

mkdir -p ~/cka-day3 && cd ~/cka-day3

# Create test namespace
kubectl create namespace cka-day3

# Create resource quota
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pod-quota
  namespace: cka-day3
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
EOF

# Create limit range
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limits
  namespace: cka-day3
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
EOF

echo "Setup complete. Resource constraints applied."
```

#### Main Tasks

**Task 3.1: Pod Creation and Basic Debugging (20 min)**
```bash
# Create working pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: working-pod
  namespace: cka-day3
spec:
  containers:
  - name: app
    image: nginx:1.20
    ports:
    - containerPort: 80
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
EOF

# Create problematic pods for debugging
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: image-pull-error
  namespace: cka-day3
spec:
  containers:
  - name: app
    image: nginx:nonexistent-tag
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-exceeded
  namespace: cka-day3
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 3
        memory: 3Gi
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: crash-loop
  namespace: cka-day3
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo Starting...; sleep 5; exit 1"]
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
EOF
```

**Task 3.2: Advanced Pod Configurations (25 min)**
```bash
# Pod with init containers
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
  namespace: cka-day3
spec:
  initContainers:
  - name: init-service
    image: busybox
    command: ['sh', '-c', 'echo Initializing...; sleep 10; echo Done']
  containers:
  - name: main-app
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
EOF

# Pod with multiple containers
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: multi-container
  namespace: cka-day3
spec:
  containers:
  - name: web
    image: nginx
    ports:
    - containerPort: 80
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo $(date) >> /var/log/app.log; sleep 30; done']
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
  volumes:
  - name: shared-logs
    emptyDir: {}
EOF

# Pod with probes
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: probe-pod
  namespace: cka-day3
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
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
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
EOF
```

#### Debug Scenarios

**Debug 3.1: Image and Resource Issues (10 min)**
```bash
echo "=== Debugging Pod Issues ==="

# Check all pod statuses
kubectl get pods -n cka-day3

# Debug image pull error
echo "--- Image Pull Error ---"
kubectl describe pod image-pull-error -n cka-day3
kubectl get events -n cka-day3 --field-selector involvedObject.name=image-pull-error

# Debug resource exceeded
echo "--- Resource Exceeded ---"
kubectl describe pod resource-exceeded -n cka-day3
kubectl get resourcequota pod-quota -n cka-day3

# Debug crash loop
echo "--- Crash Loop ---"
kubectl describe pod crash-loop -n cka-day3
kubectl logs crash-loop -n cka-day3 --previous

# Fix the issues:
# 1. Fix image pull error
kubectl patch pod image-pull-error -n cka-day3 -p '{"spec":{"containers":[{"name":"app","image":"nginx:1.20"}]}}'

# 2. Fix resource issue by updating quota or reducing requests
kubectl patch resourcequota pod-quota -n cka-day3 -p '{"spec":{"hard":{"requests.cpu":"5","requests.memory":"5Gi"}}}'

# 3. Fix crash loop
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: crash-loop-fixed
  namespace: cka-day3
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
EOF
```

**Debug 3.2: Networking and Connectivity (5 min)**
```bash
# Test pod networking
kubectl exec -it working-pod -n cka-day3 -- curl localhost

# Test inter-pod communication
kubectl get pods -n cka-day3 -o wide

# Create test pod for network debugging
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: network-test
  namespace: cka-day3
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
EOF

# Test DNS resolution
kubectl exec -it network-test -n cka-day3 -- nslookup kubernetes.default.svc.cluster.local

# Test connectivity to other pod
WORKING_POD_IP=$(kubectl get pod working-pod -n cka-day3 -o jsonpath='{.status.podIP}')
kubectl exec -it network-test -n cka-day3 -- wget -qO- http://$WORKING_POD_IP
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 3 Cleanup
echo "=== Day 3 Cleanup ==="

# Remove namespace (removes all pods and resources)
kubectl delete namespace cka-day3

# Remove working directory
rm -rf ~/cka-day3

echo "Day 3 cleanup complete"
```

---

*[This is the first section of the 30-day guide. The complete guide will continue with Days 4-30 covering all CKA topics with similar detailed structure.]*

**Next sections will cover:**
- Week 1 (Days 4-7): Services, Networking, Storage
- Week 2 (Days 8-14): Deployments, StatefulSets, DaemonSets, Jobs
- Week 3 (Days 15-21): Monitoring, Logging, Troubleshooting
- Week 4 (Days 22-28): Cluster Maintenance, Backup/Restore
- Days 29-30: Mock Exams and Final Review

Would you like me to continue with the next section?
### Day 4: Services & Networking
**Time:** 60 minutes  
**Focus:** Service types, endpoints, and network troubleshooting

#### Task Summary
- Create all service types (ClusterIP, NodePort, LoadBalancer)
- Debug service connectivity issues
- Troubleshoot DNS resolution
- Fix endpoint problems

#### Expected Outcome
- Master service debugging
- Understand networking concepts
- Know how to fix connectivity issues

#### Setup Script
```bash
#!/bin/bash
# Day 4 Setup
echo "=== Day 4: Services & Networking Setup ==="

mkdir -p ~/cka-day4 && cd ~/cka-day4

# Create test namespace
kubectl create namespace cka-day4

# Create backend pods
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-app
  namespace: cka-day4
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: app
        image: nginx
        ports:
        - containerPort: 80
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        command: ["/bin/sh"]
        args: ["-c", "echo 'Backend Pod: $POD_NAME' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
EOF

echo "Setup complete. Backend pods creating..."
```

#### Main Tasks

**Task 4.1: Service Types Implementation (25 min)**
```bash
# ClusterIP Service (default)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-clusterip
  namespace: cka-day4
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# NodePort Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-nodeport
  namespace: cka-day4
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF

# Headless Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-headless
  namespace: cka-day4
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
  clusterIP: None
EOF

# Service with wrong selector (for debugging)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-broken
  namespace: cka-day4
spec:
  selector:
    app: wrong-label
  ports:
  - port: 80
    targetPort: 80
EOF

# External service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: external-service
  namespace: cka-day4
spec:
  type: ExternalName
  externalName: google.com
  ports:
  - port: 80
EOF
```

**Task 4.2: Endpoint Management (20 min)**
```bash
# Create service without selector
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: manual-service
  namespace: cka-day4
spec:
  ports:
  - port: 80
    targetPort: 80
EOF

# Create manual endpoints
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Endpoints
metadata:
  name: manual-service
  namespace: cka-day4
subsets:
- addresses:
  - ip: 8.8.8.8
  ports:
  - port: 80
EOF

# Create test pod for connectivity testing
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-client
  namespace: cka-day4
spec:
  containers:
  - name: client
    image: busybox
    command: ['sleep', '3600']
EOF
```

#### Debug Scenarios

**Debug 4.1: Service Connectivity Issues (10 min)**
```bash
echo "=== Debugging Service Issues ==="

# Check service status
kubectl get svc -n cka-day4
kubectl get endpoints -n cka-day4

# Test working service
kubectl exec -it test-client -n cka-day4 -- wget -qO- backend-clusterip

# Test broken service (should fail)
kubectl exec -it test-client -n cka-day4 -- wget -qO- backend-broken

# Debug broken service
echo "--- Debugging broken service ---"
kubectl describe svc backend-broken -n cka-day4
kubectl get endpoints backend-broken -n cka-day4

# Check pod labels
kubectl get pods -n cka-day4 --show-labels

# Fix broken service
kubectl patch svc backend-broken -n cka-day4 -p '{"spec":{"selector":{"app":"backend"}}}'

# Verify fix
kubectl get endpoints backend-broken -n cka-day4
kubectl exec -it test-client -n cka-day4 -- wget -qO- backend-broken
```

**Debug 4.2: DNS Resolution Problems (5 min)**
```bash
# Test DNS resolution
kubectl exec -it test-client -n cka-day4 -- nslookup backend-clusterip

# Test cross-namespace DNS
kubectl exec -it test-client -n cka-day4 -- nslookup kubernetes.default.svc.cluster.local

# Test headless service DNS
kubectl exec -it test-client -n cka-day4 -- nslookup backend-headless

# Debug DNS issues
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 4 Cleanup
echo "=== Day 4 Cleanup ==="

kubectl delete namespace cka-day4
rm -rf ~/cka-day4

echo "Day 4 cleanup complete"
```

---

### Day 5: Persistent Volumes & Storage
**Time:** 60 minutes  
**Focus:** Storage classes, PV/PVC, and storage troubleshooting

#### Task Summary
- Create PersistentVolumes and PersistentVolumeClaims
- Debug storage mounting issues
- Implement dynamic provisioning
- Troubleshoot storage class problems

#### Expected Outcome
- Master storage concepts
- Debug volume mounting issues
- Understand storage classes

#### Setup Script
```bash
#!/bin/bash
# Day 5 Setup
echo "=== Day 5: Storage Setup ==="

mkdir -p ~/cka-day5 && cd ~/cka-day5

# Create test namespace
kubectl create namespace cka-day5

# Create directories on kind nodes for hostPath volumes
docker exec -it cka-cluster-1-control-plane mkdir -p /tmp/pv-data
docker exec -it cka-cluster-1-worker mkdir -p /tmp/pv-data
docker exec -it cka-cluster-1-worker2 mkdir -p /tmp/pv-data

echo "Setup complete. Storage directories created."
```

#### Main Tasks

**Task 5.1: Static PV/PVC Creation (25 min)**
```bash
# Create PersistentVolume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/pv-data
EOF

# Create PersistentVolumeClaim
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-test
  namespace: cka-day5
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF

# Create pod using PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
  namespace: cka-day5
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc-test
EOF

# Create problematic PVC (size mismatch)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-large
  namespace: cka-day5
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF
```

**Task 5.2: Storage Classes and Dynamic Provisioning (20 min)**
```bash
# Check existing storage classes
kubectl get storageclass

# Create custom storage class (for kind/local testing)
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

# Create multiple PVs for dynamic-like behavior
for i in {1..3}; do
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-fast-$i
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: fast-storage
  hostPath:
    path: /tmp/pv-fast-$i
EOF
done

# Create PVC with storage class
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-fast
  namespace: cka-day5
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: fast-storage
  resources:
    requests:
      storage: 1Gi
EOF

# Create StatefulSet using storage
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web-storage
  namespace: cka-day5
spec:
  serviceName: web-storage
  replicas: 2
  selector:
    matchLabels:
      app: web-storage
  template:
    metadata:
      labels:
        app: web-storage
    spec:
      containers:
      - name: web
        image: nginx
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-storage
      resources:
        requests:
          storage: 1Gi
EOF
```

#### Debug Scenarios

**Debug 5.1: PVC Binding Issues (10 min)**
```bash
echo "=== Debugging Storage Issues ==="

# Check PV/PVC status
kubectl get pv
kubectl get pvc -n cka-day5

# Debug unbound PVC
kubectl describe pvc pvc-large -n cka-day5

# Check events
kubectl get events -n cka-day5 --field-selector reason=FailedBinding

# Fix by creating appropriate PV
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-large
spec:
  capacity:
    storage: 2Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/pv-large
EOF

# Verify binding
kubectl get pvc pvc-large -n cka-day5
```

**Debug 5.2: Mount Issues (5 min)**
```bash
# Check pod with storage
kubectl get pod storage-pod -n cka-day5
kubectl describe pod storage-pod -n cka-day5

# Test writing to mounted volume
kubectl exec -it storage-pod -n cka-day5 -- sh -c "echo 'Hello from PV' > /usr/share/nginx/html/index.html"

# Verify data persistence
kubectl exec -it storage-pod -n cka-day5 -- cat /usr/share/nginx/html/index.html

# Check on host
docker exec -it cka-cluster-1-control-plane ls -la /tmp/pv-data/
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 5 Cleanup
echo "=== Day 5 Cleanup ==="

kubectl delete namespace cka-day5
kubectl delete pv --all
kubectl delete storageclass fast-storage

# Clean up host directories
docker exec -it cka-cluster-1-control-plane rm -rf /tmp/pv-*
docker exec -it cka-cluster-1-worker rm -rf /tmp/pv-*
docker exec -it cka-cluster-1-worker2 rm -rf /tmp/pv-*

rm -rf ~/cka-day5

echo "Day 5 cleanup complete"
```

---

### Day 6: ConfigMaps & Secrets
**Time:** 60 minutes  
**Focus:** Configuration management and sensitive data handling

#### Task Summary
- Create and manage ConfigMaps and Secrets
- Debug configuration issues
- Implement different mounting strategies
- Troubleshoot environment variable problems

#### Expected Outcome
- Master configuration management
- Debug config-related pod issues
- Understand security implications

#### Setup Script
```bash
#!/bin/bash
# Day 6 Setup
echo "=== Day 6: ConfigMaps & Secrets Setup ==="

mkdir -p ~/cka-day6 && cd ~/cka-day6

# Create test namespace
kubectl create namespace cka-day6

# Create sample config files
cat > app.properties << EOF
database.host=localhost
database.port=5432
database.name=myapp
log.level=INFO
feature.enabled=true
EOF

cat > nginx.conf << EOF
server {
    listen 80;
    server_name localhost;
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF

echo "Setup complete. Config files created."
```

#### Main Tasks

**Task 6.1: ConfigMap Creation and Usage (25 min)**
```bash
# Create ConfigMap from literal values
kubectl create configmap app-config \
  --from-literal=database.host=postgres \
  --from-literal=database.port=5432 \
  --from-literal=log.level=DEBUG \
  -n cka-day6

# Create ConfigMap from file
kubectl create configmap app-properties \
  --from-file=app.properties \
  -n cka-day6

# Create ConfigMap from directory
kubectl create configmap nginx-config \
  --from-file=nginx.conf \
  -n cka-day6

# Create ConfigMap using YAML
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: multi-config
  namespace: cka-day6
data:
  database.yaml: |
    host: mysql
    port: 3306
    database: production
  cache.yaml: |
    redis:
      host: redis-cluster
      port: 6379
EOF

# Pod using ConfigMap as environment variables
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-env-pod
  namespace: cka-day6
spec:
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
    env:
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    - name: DB_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.port
    envFrom:
    - configMapRef:
        name: app-config
EOF

# Pod using ConfigMap as volume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-volume-pod
  namespace: cka-day6
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: nginx-config
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: config-volume
    configMap:
      name: multi-config
  - name: nginx-config
    configMap:
      name: nginx-config
EOF
```

**Task 6.2: Secrets Management (20 min)**
```bash
# Create Secret from literal values
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secretpassword \
  -n cka-day6

# Create Secret from files
echo -n 'admin' > username.txt
echo -n 'supersecret' > password.txt
kubectl create secret generic file-secret \
  --from-file=username.txt \
  --from-file=password.txt \
  -n cka-day6

# Create TLS Secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=example.com/O=example.com"

kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  -n cka-day6

# Create Docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com \
  -n cka-day6

# Pod using Secrets
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: cka-day6
spec:
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: file-secret
  imagePullSecrets:
  - name: regcred
EOF
```

#### Debug Scenarios

**Debug 6.1: Configuration Issues (10 min)**
```bash
echo "=== Debugging Configuration Issues ==="

# Create pod with wrong ConfigMap reference
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-config-pod
  namespace: cka-day6
spec:
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
    env:
    - name: MISSING_CONFIG
      valueFrom:
        configMapKeyRef:
          name: nonexistent-config
          key: some.key
EOF

# Check pod status
kubectl get pod broken-config-pod -n cka-day6
kubectl describe pod broken-config-pod -n cka-day6

# Fix by creating the ConfigMap
kubectl create configmap nonexistent-config \
  --from-literal=some.key=some.value \
  -n cka-day6

# Delete and recreate pod
kubectl delete pod broken-config-pod -n cka-day6
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: fixed-config-pod
  namespace: cka-day6
spec:
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
    env:
    - name: MISSING_CONFIG
      valueFrom:
        configMapKeyRef:
          name: nonexistent-config
          key: some.key
EOF

# Verify fix
kubectl exec -it fixed-config-pod -n cka-day6 -- env | grep MISSING_CONFIG
```

**Debug 6.2: Secret Access Issues (5 min)**
```bash
# Test secret access
kubectl exec -it secret-pod -n cka-day6 -- env | grep DB_

# Check mounted secrets
kubectl exec -it secret-pod -n cka-day6 -- ls -la /etc/secrets/
kubectl exec -it secret-pod -n cka-day6 -- cat /etc/secrets/username.txt

# Verify ConfigMap and Secret updates
kubectl patch configmap app-config -n cka-day6 -p '{"data":{"new.key":"new.value"}}'
kubectl patch secret db-secret -n cka-day6 -p '{"data":{"newkey":"bmV3dmFsdWU="}}'

# Check if pod sees updates (may need restart for env vars)
kubectl exec -it config-env-pod -n cka-day6 -- env | grep -E "(DB_|new)"
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 6 Cleanup
echo "=== Day 6 Cleanup ==="

kubectl delete namespace cka-day6
rm -rf ~/cka-day6
rm -f username.txt password.txt tls.key tls.crt

echo "Day 6 cleanup complete"
```

---

### Day 7: Week 1 Review & Integration
**Time:** 60 minutes  
**Focus:** Combining all Week 1 concepts in complex scenarios

#### Task Summary
- Create multi-component application
- Debug complex inter-service issues
- Implement end-to-end security
- Practice exam-style troubleshooting

#### Expected Outcome
- Integrate all Week 1 concepts
- Handle complex debugging scenarios
- Build confidence for Week 2

#### Setup Script
```bash
#!/bin/bash
# Day 7 Setup
echo "=== Day 7: Integration Review Setup ==="

mkdir -p ~/cka-day7 && cd ~/cka-day7

# Create integration namespace
kubectl create namespace cka-day7

echo "Setup complete. Ready for integration tasks."
```

#### Integration Task: Complete Application Stack (45 min)
```bash
# Create ConfigMap for application
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: cka-day7
data:
  database.host: "postgres-service"
  database.port: "5432"
  database.name: "myapp"
  redis.host: "redis-service"
  redis.port: "6379"
EOF

# Create Secrets
kubectl create secret generic db-credentials \
  --from-literal=username=appuser \
  --from-literal=password=apppass123 \
  -n cka-day7

# Create PostgreSQL deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: cka-day7
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.name
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: cka-day7
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
EOF

# Create Redis deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: cka-day7
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:6
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: cka-day7
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
EOF

# Create application deployment with issues (for debugging)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: cka-day7
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: app
        image: nginx
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.host
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: REDIS_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: redis.host
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
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
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: cka-day7
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
EOF

# Create RBAC for application
kubectl create serviceaccount app-sa -n cka-day7

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: cka-day7
  name: app-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
EOF

kubectl create rolebinding app-binding \
  --role=app-role \
  --serviceaccount=cka-day7:app-sa \
  -n cka-day7
```

#### Complex Debug Scenario (15 min)
```bash
echo "=== Complex Integration Debugging ==="

# Introduce multiple issues
# 1. Wrong service selector
kubectl patch service postgres-service -n cka-day7 -p '{"spec":{"selector":{"app":"wrong-postgres"}}}'

# 2. Missing secret key
kubectl patch deployment web-app -n cka-day7 -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","env":[{"name":"MISSING_SECRET","valueFrom":{"secretKeyRef":{"name":"db-credentials","key":"nonexistent"}}}]}]}}}}'

# 3. Resource constraints
kubectl patch deployment web-app -n cka-day7 -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"2","memory":"4Gi"}}}]}}}}'

# Debug process
echo "--- Checking application status ---"
kubectl get pods -n cka-day7
kubectl get svc -n cka-day7
kubectl get endpoints -n cka-day7

echo "--- Debugging service connectivity ---"
kubectl describe svc postgres-service -n cka-day7
kubectl get endpoints postgres-service -n cka-day7

echo "--- Debugging pod issues ---"
kubectl describe deployment web-app -n cka-day7
kubectl get events -n cka-day7 --sort-by='.lastTimestamp'

# Fix the issues
echo "--- Fixing issues ---"
# Fix service selector
kubectl patch service postgres-service -n cka-day7 -p '{"spec":{"selector":{"app":"postgres"}}}'

# Remove problematic env var
kubectl patch deployment web-app -n cka-day7 --type='json' -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/env/3"}]'

# Fix resource constraints
kubectl patch deployment web-app -n cka-day7 -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"100m","memory":"128Mi"}}}]}}}}'

# Verify fixes
echo "--- Verifying fixes ---"
kubectl get pods -n cka-day7
kubectl get endpoints -n cka-day7
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 7 Cleanup
echo "=== Day 7 Cleanup ==="

kubectl delete namespace cka-day7
rm -rf ~/cka-day7

echo "Week 1 complete! Ready for Week 2."
```

---

## Week 1 Summary

**Completed Topics:**
- ✅ Cluster Architecture & Certificates
- ✅ RBAC & Security Contexts  
- ✅ Pod Lifecycle & Troubleshooting
- ✅ Services & Networking
- ✅ Persistent Volumes & Storage
- ✅ ConfigMaps & Secrets
- ✅ Integration & Complex Debugging

**Skills Gained:**
- Certificate management and troubleshooting
- RBAC implementation and debugging
- Pod lifecycle understanding
- Service connectivity troubleshooting
- Storage configuration and issues
- Configuration management
- Complex multi-component debugging

**Next Week Preview:**
Week 2 will cover Workloads (Deployments, StatefulSets, DaemonSets, Jobs) with advanced scheduling and resource management.
---

## Week 2: Workloads & Advanced Scheduling

### Day 8: Deployments & Rolling Updates
**Time:** 60 minutes  
**Focus:** Deployment strategies, rolling updates, and rollback scenarios

#### Task Summary
- Create and manage deployments
- Implement rolling update strategies
- Debug failed deployments
- Practice rollback scenarios

#### Expected Outcome
- Master deployment lifecycle
- Handle update failures
- Understand deployment strategies

#### Setup Script
```bash
#!/bin/bash
# Day 8 Setup
echo "=== Day 8: Deployments Setup ==="

mkdir -p ~/cka-day8 && cd ~/cka-day8

# Create test namespace
kubectl create namespace deploy-test

echo "Setup complete. Ready for deployment tasks."
```

#### Main Tasks

**Task 8.1: Basic Deployment Management (25 min)**
```bash
# Create initial deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: deploy-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
        version: v1
    spec:
      containers:
      - name: web
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF

# Scale deployment
kubectl scale deployment web-app --replicas=5 -n deploy-test

# Update deployment with new image
kubectl set image deployment/web-app web=nginx:1.21 -n deploy-test

# Check rollout status
kubectl rollout status deployment/web-app -n deploy-test

# View rollout history
kubectl rollout history deployment/web-app -n deploy-test
```

**Task 8.2: Advanced Deployment Strategies (20 min)**
```bash
# Deployment with custom rolling update strategy
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-app
  namespace: deploy-test
spec:
  replicas: 6
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 2
  selector:
    matchLabels:
      app: api-app
  template:
    metadata:
      labels:
        app: api-app
    spec:
      containers:
      - name: api
        image: nginx:1.20
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
EOF

# Deployment with recreate strategy
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-app
  namespace: deploy-test
spec:
  replicas: 2
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: batch-app
  template:
    metadata:
      labels:
        app: batch-app
    spec:
      containers:
      - name: batch
        image: busybox
        command: ['sleep', '3600']
EOF
```

#### Debug Scenarios

**Debug 8.1: Failed Rolling Update (10 min)**
```bash
# Create deployment with bad image
kubectl set image deployment/web-app web=nginx:nonexistent -n deploy-test

# Check rollout status (should be stuck)
kubectl rollout status deployment/web-app -n deploy-test --timeout=60s

# Debug the issue
kubectl get pods -n deploy-test -l app=web-app
kubectl describe deployment web-app -n deploy-test
kubectl get events -n deploy-test --field-selector involvedObject.name=web-app

# Rollback to previous version
kubectl rollout undo deployment/web-app -n deploy-test

# Verify rollback
kubectl rollout status deployment/web-app -n deploy-test
kubectl get pods -n deploy-test -l app=web-app
```

**Debug 8.2: Resource Constraints (5 min)**
```bash
# Update with resource constraints that exceed node capacity
kubectl patch deployment api-app -n deploy-test -p '{"spec":{"template":{"spec":{"containers":[{"name":"api","resources":{"requests":{"cpu":"10","memory":"20Gi"}}}]}}}}'

# Check deployment status
kubectl get deployment api-app -n deploy-test
kubectl describe deployment api-app -n deploy-test
kubectl get events -n deploy-test --field-selector involvedObject.name=api-app

# Fix resource constraints
kubectl patch deployment api-app -n deploy-test -p '{"spec":{"template":{"spec":{"containers":[{"name":"api","resources":{"requests":{"cpu":"100m","memory":"128Mi"}}}]}}}}'
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 8 Cleanup
echo "=== Day 8 Cleanup ==="

kubectl delete namespace deploy-test
rm -rf ~/cka-day8

echo "Day 8 cleanup complete"
```

---

### Day 9: StatefulSets & Persistent Workloads
**Time:** 60 minutes  
**Focus:** StatefulSet management, persistent storage, and ordered deployment

#### Task Summary
- Create and manage StatefulSets
- Implement persistent storage for stateful apps
- Debug StatefulSet scaling issues
- Handle pod management policies

#### Expected Outcome
- Understand StatefulSet behavior
- Master persistent workload management
- Debug stateful application issues

#### Setup Script
```bash
#!/bin/bash
# Day 9 Setup
echo "=== Day 9: StatefulSets Setup ==="

mkdir -p ~/cka-day9 && cd ~/cka-day9

# Create test namespace
kubectl create namespace stateful-test

# Create storage class for StatefulSets
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: stateful-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

# Create PVs for StatefulSet
for i in {0..4}; do
  docker exec -it cka-cluster-1-control-plane mkdir -p /tmp/stateful-$i
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-stateful-$i
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: stateful-storage
  hostPath:
    path: /tmp/stateful-$i
EOF
done

echo "Setup complete. Storage ready for StatefulSets."
```

#### Main Tasks

**Task 9.1: Basic StatefulSet Creation (25 min)**
```bash
# Create headless service for StatefulSet
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: stateful-test
spec:
  clusterIP: None
  selector:
    app: web-stateful
  ports:
  - port: 80
    targetPort: 80
EOF

# Create StatefulSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web-stateful
  namespace: stateful-test
spec:
  serviceName: web-service
  replicas: 3
  selector:
    matchLabels:
      app: web-stateful
  template:
    metadata:
      labels:
        app: web-stateful
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
        command: ["/bin/sh"]
        args: ["-c", "echo 'Pod: $HOSTNAME' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: stateful-storage
      resources:
        requests:
          storage: 1Gi
EOF

# Watch StatefulSet creation
kubectl get pods -n stateful-test -w --timeout=120s

# Test ordered creation and DNS
kubectl exec -it web-stateful-0 -n stateful-test -- nslookup web-stateful-1.web-service.stateful-test.svc.cluster.local
```

**Task 9.2: StatefulSet Scaling and Updates (20 min)**
```bash
# Scale StatefulSet up
kubectl scale statefulset web-stateful --replicas=5 -n stateful-test

# Watch scaling behavior (ordered)
kubectl get pods -n stateful-test -l app=web-stateful

# Update StatefulSet with rolling update
kubectl patch statefulset web-stateful -n stateful-test -p '{"spec":{"template":{"spec":{"containers":[{"name":"web","image":"nginx:1.21"}]}}}}'

# Watch rolling update (ordered)
kubectl rollout status statefulset/web-stateful -n stateful-test

# Scale down (reverse order)
kubectl scale statefulset web-stateful --replicas=2 -n stateful-test

# Verify persistent storage
kubectl exec -it web-stateful-0 -n stateful-test -- cat /usr/share/nginx/html/index.html
kubectl exec -it web-stateful-1 -n stateful-test -- cat /usr/share/nginx/html/index.html
```

#### Debug Scenarios

**Debug 9.1: StatefulSet Pod Stuck (10 min)**
```bash
# Create StatefulSet with problematic pod
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
  namespace: stateful-test
spec:
  serviceName: database-service
  replicas: 3
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: db
        image: postgres:13
        env:
        - name: POSTGRES_PASSWORD
          value: "password"
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: nonexistent-storage
      resources:
        requests:
          storage: 1Gi
EOF

# Check StatefulSet status
kubectl get statefulset database -n stateful-test
kubectl describe statefulset database -n stateful-test

# Debug PVC issues
kubectl get pvc -n stateful-test
kubectl describe pvc data-database-0 -n stateful-test

# Fix by updating storage class
kubectl patch statefulset database -n stateful-test -p '{"spec":{"volumeClaimTemplates":[{"metadata":{"name":"data"},"spec":{"storageClassName":"stateful-storage"}}]}}'

# Delete and recreate (StatefulSet doesn't update VCT)
kubectl delete statefulset database -n stateful-test
kubectl patch pvc data-database-0 -n stateful-test -p '{"spec":{"storageClassName":"stateful-storage"}}'
```

**Debug 9.2: Pod Management Policy (5 min)**
```bash
# Create StatefulSet with parallel pod management
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: parallel-stateful
  namespace: stateful-test
spec:
  serviceName: parallel-service
  replicas: 3
  podManagementPolicy: Parallel
  selector:
    matchLabels:
      app: parallel-stateful
  template:
    metadata:
      labels:
        app: parallel-stateful
    spec:
      containers:
      - name: app
        image: busybox
        command: ['sleep', '3600']
EOF

# Watch parallel creation
kubectl get pods -n stateful-test -l app=parallel-stateful -w --timeout=60s
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 9 Cleanup
echo "=== Day 9 Cleanup ==="

kubectl delete namespace stateful-test
kubectl delete pv --all
kubectl delete storageclass stateful-storage

# Clean up host directories
for i in {0..4}; do
  docker exec -it cka-cluster-1-control-plane rm -rf /tmp/stateful-$i
done

rm -rf ~/cka-day9

echo "Day 9 cleanup complete"
```

---

### Day 10: DaemonSets & Node Management
**Time:** 60 minutes  
**Focus:** DaemonSet deployment, node selection, and system-level workloads

#### Task Summary
- Create and manage DaemonSets
- Implement node selection strategies
- Debug DaemonSet scheduling issues
- Handle node maintenance scenarios

#### Expected Outcome
- Master DaemonSet concepts
- Understand node affinity and selection
- Debug node-level deployment issues

#### Setup Script
```bash
#!/bin/bash
# Day 10 Setup
echo "=== Day 10: DaemonSets Setup ==="

mkdir -p ~/cka-day10 && cd ~/cka-day10

# Create test namespace
kubectl create namespace daemon-test

# Label nodes for testing
kubectl label node cka-cluster-1-worker node-type=worker
kubectl label node cka-cluster-1-worker2 node-type=worker
kubectl label node cka-cluster-1-control-plane node-type=master

echo "Setup complete. Nodes labeled for DaemonSet testing."
```

#### Main Tasks

**Task 10.1: Basic DaemonSet Creation (25 min)**
```bash
# Create basic DaemonSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
  namespace: daemon-test
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
      - name: collector
        image: busybox
        command: ['sh', '-c', 'while true; do echo "$(date): Collecting logs from $(hostname)"; sleep 30; done']
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
EOF

# Check DaemonSet deployment
kubectl get daemonset log-collector -n daemon-test
kubectl get pods -n daemon-test -o wide
```

**Task 10.2: Node Selection and Affinity (20 min)**
```bash
# DaemonSet with node selector
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: worker-monitor
  namespace: daemon-test
spec:
  selector:
    matchLabels:
      app: worker-monitor
  template:
    metadata:
      labels:
        app: worker-monitor
    spec:
      nodeSelector:
        node-type: worker
      containers:
      - name: monitor
        image: busybox
        command: ['sh', '-c', 'while true; do echo "$(date): Monitoring worker node $(hostname)"; sleep 60; done']
EOF

# DaemonSet with node affinity
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ssd-monitor
  namespace: daemon-test
spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        app: ssd-monitor
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-type
                operator: In
                values: ["worker"]
      containers:
      - name: ssd-monitor
        image: busybox
        command: ['sh', '-c', 'while true; do echo "$(date): SSD monitoring on $(hostname)"; sleep 45; done']
EOF

# DaemonSet with anti-affinity (should fail on single node)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: exclusive-daemon
  namespace: daemon-test
spec:
  selector:
    matchLabels:
      app: exclusive-daemon
  template:
    metadata:
      labels:
        app: exclusive-daemon
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values: ["exclusive-daemon"]
            topologyKey: kubernetes.io/hostname
      containers:
      - name: exclusive
        image: busybox
        command: ['sleep', '3600']
EOF
```

#### Debug Scenarios

**Debug 10.1: DaemonSet Not Scheduling (10 min)**
```bash
# Create DaemonSet with impossible requirements
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: broken-daemon
  namespace: daemon-test
spec:
  selector:
    matchLabels:
      app: broken-daemon
  template:
    metadata:
      labels:
        app: broken-daemon
    spec:
      nodeSelector:
        nonexistent-label: "true"
      containers:
      - name: broken
        image: busybox
        command: ['sleep', '3600']
EOF

# Debug scheduling issues
kubectl get daemonset broken-daemon -n daemon-test
kubectl describe daemonset broken-daemon -n daemon-test
kubectl get events -n daemon-test --field-selector involvedObject.name=broken-daemon

# Check node labels
kubectl get nodes --show-labels

# Fix by updating node selector
kubectl patch daemonset broken-daemon -n daemon-test -p '{"spec":{"template":{"spec":{"nodeSelector":{"node-type":"worker"}}}}}'

# Verify fix
kubectl get pods -n daemon-test -l app=broken-daemon
```

**Debug 10.2: Taint and Toleration Issues (5 min)**
```bash
# Taint a node
kubectl taint node cka-cluster-1-worker special=true:NoSchedule

# Check DaemonSet pods
kubectl get pods -n daemon-test -o wide

# Create DaemonSet with toleration
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: tolerant-daemon
  namespace: daemon-test
spec:
  selector:
    matchLabels:
      app: tolerant-daemon
  template:
    metadata:
      labels:
        app: tolerant-daemon
    spec:
      tolerations:
      - key: special
        operator: Equal
        value: "true"
        effect: NoSchedule
      containers:
      - name: tolerant
        image: busybox
        command: ['sleep', '3600']
EOF

# Remove taint
kubectl taint node cka-cluster-1-worker special=true:NoSchedule-
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 10 Cleanup
echo "=== Day 10 Cleanup ==="

kubectl delete namespace daemon-test

# Remove node labels
kubectl label node cka-cluster-1-worker node-type-
kubectl label node cka-cluster-1-worker2 node-type-
kubectl label node cka-cluster-1-control-plane node-type-

# Remove any remaining taints
kubectl taint node cka-cluster-1-worker special- --ignore-not-found

rm -rf ~/cka-day10

echo "Day 10 cleanup complete"
```
---

### Day 11: Jobs & CronJobs
**Time:** 60 minutes  
**Focus:** Batch workloads, scheduled tasks, and job management

#### Task Summary
- Create and manage Jobs and CronJobs
- Debug job execution failures
- Handle job completion and cleanup
- Implement parallel job processing

#### Expected Outcome
- Master batch workload concepts
- Debug job-related issues
- Understand job patterns and strategies

#### Setup Script
```bash
#!/bin/bash
# Day 11 Setup
echo "=== Day 11: Jobs & CronJobs Setup ==="

mkdir -p ~/cka-day11 && cd ~/cka-day11

# Create test namespace
kubectl create namespace job-test

echo "Setup complete. Ready for job tasks."
```

#### Main Tasks

**Task 11.1: Basic Job Management (25 min)**
```bash
# Simple Job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: simple-job
  namespace: job-test
spec:
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c', 'echo "Job started at $(date)"; sleep 30; echo "Job completed at $(date)"']
      restartPolicy: Never
  backoffLimit: 3
EOF

# Parallel Job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
  namespace: job-test
spec:
  parallelism: 3
  completions: 6
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c', 'echo "Worker $HOSTNAME started"; sleep $((RANDOM % 30 + 10)); echo "Worker $HOSTNAME completed"']
      restartPolicy: Never
  backoffLimit: 2
EOF

# Job with deadline
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: deadline-job
  namespace: job-test
spec:
  activeDeadlineSeconds: 60
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c', 'echo "Long running job"; sleep 120; echo "Should not reach here"']
      restartPolicy: Never
EOF

# Monitor jobs
kubectl get jobs -n job-test -w --timeout=120s
```

**Task 11.2: CronJob Implementation (20 min)**
```bash
# Basic CronJob
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-cronjob
  namespace: job-test
spec:
  schedule: "*/2 * * * *"  # Every 2 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ['sh', '-c', 'echo "Backup started at $(date)"; sleep 10; echo "Backup completed"']
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
EOF

# CronJob with concurrency policy
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report-cronjob
  namespace: job-test
spec:
  schedule: "*/1 * * * *"  # Every minute
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: report
            image: busybox
            command: ['sh', '-c', 'echo "Report generation started"; sleep 90; echo "Report completed"']
          restartPolicy: OnFailure
EOF

# Suspended CronJob
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: maintenance-cronjob
  namespace: job-test
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  suspend: true
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: maintenance
            image: busybox
            command: ['sh', '-c', 'echo "Maintenance task"; sleep 5']
          restartPolicy: OnFailure
EOF

# Monitor CronJobs
kubectl get cronjobs -n job-test
```

#### Debug Scenarios

**Debug 11.1: Failed Job Debugging (10 min)**
```bash
# Create failing job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: failing-job
  namespace: job-test
spec:
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sh', '-c', 'echo "Starting job"; exit 1']
      restartPolicy: Never
  backoffLimit: 2
EOF

# Debug job failure
kubectl get job failing-job -n job-test
kubectl describe job failing-job -n job-test
kubectl get pods -n job-test -l job-name=failing-job
kubectl logs -n job-test -l job-name=failing-job

# Create job with resource issues
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: resource-job
  namespace: job-test
spec:
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ['sleep', '30']
        resources:
          requests:
            cpu: 10
            memory: 20Gi
      restartPolicy: Never
EOF

# Debug resource issues
kubectl describe job resource-job -n job-test
kubectl get events -n job-test --field-selector involvedObject.name=resource-job
```

**Debug 11.2: CronJob Issues (5 min)**
```bash
# Check CronJob execution
kubectl get cronjobs -n job-test
kubectl get jobs -n job-test

# Debug CronJob that's not running
kubectl describe cronjob backup-cronjob -n job-test

# Manually trigger CronJob
kubectl create job manual-backup --from=cronjob/backup-cronjob -n job-test

# Check job history
kubectl get jobs -n job-test -l cronjob=backup-cronjob
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 11 Cleanup
echo "=== Day 11 Cleanup ==="

kubectl delete namespace job-test
rm -rf ~/cka-day11

echo "Day 11 cleanup complete"
```

---

### Day 12: Resource Management & Scheduling
**Time:** 60 minutes  
**Focus:** Resource quotas, limits, requests, and advanced scheduling

#### Task Summary
- Implement resource quotas and limits
- Debug resource constraint issues
- Configure priority classes
- Handle resource-based scheduling problems

#### Expected Outcome
- Master resource management
- Debug resource-related pod failures
- Understand scheduling constraints

#### Setup Script
```bash
#!/bin/bash
# Day 12 Setup
echo "=== Day 12: Resource Management Setup ==="

mkdir -p ~/cka-day12 && cd ~/cka-day12

# Create test namespaces
kubectl create namespace resource-test
kubectl create namespace quota-test

echo "Setup complete. Ready for resource management tasks."
```

#### Main Tasks

**Task 12.1: Resource Quotas and Limits (25 min)**
```bash
# Create ResourceQuota
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: quota-test
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    persistentvolumeclaims: "4"
    pods: "10"
    services: "5"
EOF

# Create LimitRange
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: resource-limits
  namespace: quota-test
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    max:
      cpu: 1
      memory: 1Gi
    min:
      cpu: 50m
      memory: 64Mi
    type: Container
  - max:
      storage: 2Gi
    min:
      storage: 100Mi
    type: PersistentVolumeClaim
EOF

# Test pods within limits
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: within-limits
  namespace: quota-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 200m
        memory: 256Mi
      limits:
        cpu: 400m
        memory: 512Mi
EOF

# Test pod exceeding limits
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: exceeds-limits
  namespace: quota-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 2
        memory: 2Gi
      limits:
        cpu: 3
        memory: 3Gi
EOF
```

**Task 12.2: Priority Classes and Scheduling (20 min)**
```bash
# Create PriorityClasses
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "High priority class for critical workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
globalDefault: false
description: "Low priority class for batch workloads"
EOF

# Create pods with different priorities
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: high-priority-pod
  namespace: resource-test
spec:
  priorityClassName: high-priority
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: low-priority-pod
  namespace: resource-test
spec:
  priorityClassName: low-priority
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
EOF

# Create resource-intensive deployment to test preemption
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-hog
  namespace: resource-test
spec:
  replicas: 10
  selector:
    matchLabels:
      app: resource-hog
  template:
    metadata:
      labels:
        app: resource-hog
    spec:
      priorityClassName: low-priority
      containers:
      - name: hog
        image: busybox
        command: ['sleep', '3600']
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
EOF
```

#### Debug Scenarios

**Debug 12.1: Resource Quota Violations (10 min)**
```bash
echo "=== Debugging Resource Issues ==="

# Check quota usage
kubectl describe resourcequota compute-quota -n quota-test

# Try to create pod that exceeds quota
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: quota-violation
  namespace: quota-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 3
        memory: 3Gi
EOF

# Debug quota violation
kubectl describe pod quota-violation -n quota-test
kubectl get events -n quota-test --field-selector involvedObject.name=quota-violation

# Check current resource usage
kubectl top pods -n quota-test
kubectl describe limitrange resource-limits -n quota-test
```

**Debug 12.2: Scheduling Failures (5 min)**
```bash
# Create pod with impossible resource requirements
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: unschedulable-pod
  namespace: resource-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 20
        memory: 50Gi
EOF

# Debug scheduling failure
kubectl describe pod unschedulable-pod -n resource-test
kubectl get events -n resource-test --field-selector involvedObject.name=unschedulable-pod

# Check node resources
kubectl describe nodes
kubectl top nodes
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 12 Cleanup
echo "=== Day 12 Cleanup ==="

kubectl delete namespace resource-test
kubectl delete namespace quota-test
kubectl delete priorityclass high-priority low-priority

rm -rf ~/cka-day12

echo "Day 12 cleanup complete"
```
---

### Day 13: Taints, Tolerations & Node Affinity
**Time:** 60 minutes  
**Focus:** Advanced pod scheduling, node selection, and workload placement

#### Task Summary
- Implement taints and tolerations
- Configure node and pod affinity rules
- Debug scheduling constraint issues
- Handle node maintenance scenarios

#### Expected Outcome
- Master advanced scheduling concepts
- Debug complex scheduling failures
- Understand workload placement strategies

#### Setup Script
```bash
#!/bin/bash
# Day 13 Setup
echo "=== Day 13: Advanced Scheduling Setup ==="

mkdir -p ~/cka-day13 && cd ~/cka-day13

# Create test namespace
kubectl create namespace scheduling-test

# Label nodes for testing
kubectl label node cka-cluster-1-worker environment=production
kubectl label node cka-cluster-1-worker2 environment=development
kubectl label node cka-cluster-1-control-plane environment=management

kubectl label node cka-cluster-1-worker disk=ssd
kubectl label node cka-cluster-1-worker2 disk=hdd

echo "Setup complete. Nodes labeled for scheduling tests."
```

#### Main Tasks

**Task 13.1: Taints and Tolerations (25 min)**
```bash
# Apply taints to nodes
kubectl taint node cka-cluster-1-worker environment=production:NoSchedule
kubectl taint node cka-cluster-1-worker2 maintenance=true:NoExecute

# Create pod without toleration (should not schedule on tainted node)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: no-toleration
  namespace: scheduling-test
spec:
  containers:
  - name: app
    image: nginx
  nodeSelector:
    environment: production
EOF

# Create pod with toleration
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: with-toleration
  namespace: scheduling-test
spec:
  tolerations:
  - key: environment
    operator: Equal
    value: production
    effect: NoSchedule
  containers:
  - name: app
    image: nginx
  nodeSelector:
    environment: production
EOF

# Create pod with NoExecute toleration
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: tolerate-noexecute
  namespace: scheduling-test
spec:
  tolerations:
  - key: maintenance
    operator: Equal
    value: "true"
    effect: NoExecute
    tolerationSeconds: 300
  containers:
  - name: app
    image: nginx
  nodeSelector:
    environment: development
EOF

# Check pod scheduling
kubectl get pods -n scheduling-test -o wide
```

**Task 13.2: Node and Pod Affinity (20 min)**
```bash
# Pod with node affinity
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-pod
  namespace: scheduling-test
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disk
            operator: In
            values: ["ssd"]
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: environment
            operator: In
            values: ["production"]
  containers:
  - name: app
    image: nginx
EOF

# Deployment with pod anti-affinity
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-ha
  namespace: scheduling-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app-ha
  template:
    metadata:
      labels:
        app: web-app-ha
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values: ["web-app-ha"]
            topologyKey: kubernetes.io/hostname
      containers:
      - name: web
        image: nginx
EOF

# Pod with pod affinity
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cache-pod
  namespace: scheduling-test
  labels:
    app: cache
spec:
  containers:
  - name: cache
    image: redis
---
apiVersion: v1
kind: Pod
metadata:
  name: app-with-cache
  namespace: scheduling-test
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values: ["cache"]
        topologyKey: kubernetes.io/hostname
  containers:
  - name: app
    image: nginx
EOF
```

#### Debug Scenarios

**Debug 13.1: Scheduling Constraint Conflicts (10 min)**
```bash
echo "=== Debugging Scheduling Issues ==="

# Create pod with conflicting requirements
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: conflicting-requirements
  namespace: scheduling-test
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disk
            operator: In
            values: ["ssd"]
          - key: environment
            operator: In
            values: ["development"]
  containers:
  - name: app
    image: nginx
EOF

# Debug scheduling failure
kubectl describe pod conflicting-requirements -n scheduling-test
kubectl get events -n scheduling-test --field-selector involvedObject.name=conflicting-requirements

# Check node labels
kubectl get nodes --show-labels | grep -E "(disk|environment)"

# Create pod that can't be scheduled due to anti-affinity
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: impossible-antiaffinity
  namespace: scheduling-test
  labels:
    app: web-app-ha
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values: ["web-app-ha"]
        topologyKey: kubernetes.io/hostname
  containers:
  - name: app
    image: nginx
EOF

# Debug anti-affinity issue
kubectl describe pod impossible-antiaffinity -n scheduling-test
```

**Debug 13.2: Taint and Toleration Mismatches (5 min)**
```bash
# Check current taints
kubectl describe nodes | grep -A5 Taints

# Create pod with wrong toleration
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: wrong-toleration
  namespace: scheduling-test
spec:
  tolerations:
  - key: environment
    operator: Equal
    value: development  # Wrong value
    effect: NoSchedule
  containers:
  - name: app
    image: nginx
  nodeSelector:
    environment: production
EOF

# Debug toleration mismatch
kubectl describe pod wrong-toleration -n scheduling-test

# Fix toleration
kubectl patch pod wrong-toleration -n scheduling-test -p '{"spec":{"tolerations":[{"key":"environment","operator":"Equal","value":"production","effect":"NoSchedule"}]}}'
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 13 Cleanup
echo "=== Day 13 Cleanup ==="

kubectl delete namespace scheduling-test

# Remove taints
kubectl taint node cka-cluster-1-worker environment=production:NoSchedule-
kubectl taint node cka-cluster-1-worker2 maintenance=true:NoExecute-

# Remove labels
kubectl label node cka-cluster-1-worker environment-
kubectl label node cka-cluster-1-worker2 environment-
kubectl label node cka-cluster-1-control-plane environment-
kubectl label node cka-cluster-1-worker disk-
kubectl label node cka-cluster-1-worker2 disk-

rm -rf ~/cka-day13

echo "Day 13 cleanup complete"
```

---

### Day 14: Week 2 Review & Advanced Workload Integration
**Time:** 60 minutes  
**Focus:** Combining all Week 2 concepts in complex scenarios

#### Task Summary
- Create complex multi-workload application
- Debug advanced scheduling and resource issues
- Implement comprehensive workload management
- Practice exam-style advanced scenarios

#### Expected Outcome
- Integrate all Week 2 concepts
- Handle complex workload scenarios
- Build confidence for Week 3

#### Setup Script
```bash
#!/bin/bash
# Day 14 Setup
echo "=== Day 14: Advanced Integration Setup ==="

mkdir -p ~/cka-day14 && cd ~/cka-day14

# Create integration namespace
kubectl create namespace workload-integration

# Setup node labels and taints for complex scenario
kubectl label node cka-cluster-1-worker tier=frontend
kubectl label node cka-cluster-1-worker2 tier=backend
kubectl taint node cka-cluster-1-worker2 dedicated=backend:NoSchedule

echo "Setup complete. Ready for advanced integration."
```

#### Integration Task: Complete Microservices Platform (45 min)
```bash
# Create PriorityClasses
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-priority
value: 1000
description: "Critical system components"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: normal-priority
value: 500
description: "Normal application workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: batch-priority
value: 100
description: "Batch processing workloads"
EOF

# Create ResourceQuota and LimitRange
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: workload-quota
  namespace: workload-integration
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "20"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: workload-limits
  namespace: workload-integration
spec:
  limits:
  - default:
      cpu: 200m
      memory: 256Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
EOF

# Frontend Deployment (high availability)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: workload-integration
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      priorityClassName: critical-priority
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: tier
                operator: In
                values: ["frontend"]
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values: ["frontend"]
            topologyKey: kubernetes.io/hostname
      containers:
      - name: frontend
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 150m
            memory: 200Mi
          limits:
            cpu: 300m
            memory: 400Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
EOF

# Backend StatefulSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: backend
  namespace: workload-integration
spec:
  serviceName: backend-service
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      priorityClassName: normal-priority
      tolerations:
      - key: dedicated
        operator: Equal
        value: backend
        effect: NoSchedule
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: tier
                operator: In
                values: ["backend"]
      containers:
      - name: backend
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: appdb
        - name: POSTGRES_USER
          value: appuser
        - name: POSTGRES_PASSWORD
          value: apppass
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF

# Monitoring DaemonSet
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring
  namespace: workload-integration
spec:
  selector:
    matchLabels:
      app: monitoring
  template:
    metadata:
      labels:
        app: monitoring
    spec:
      priorityClassName: critical-priority
      tolerations:
      - operator: Exists
      containers:
      - name: monitor
        image: busybox
        command: ['sh', '-c', 'while true; do echo "$(date): Monitoring $(hostname)"; sleep 60; done']
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      hostNetwork: true
      hostPID: true
EOF

# Batch Processing CronJob
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: data-processing
  namespace: workload-integration
spec:
  schedule: "*/5 * * * *"  # Every 5 minutes for testing
  jobTemplate:
    spec:
      template:
        spec:
          priorityClassName: batch-priority
          containers:
          - name: processor
            image: busybox
            command: ['sh', '-c', 'echo "Processing data at $(date)"; sleep 30; echo "Processing complete"']
            resources:
              requests:
                cpu: 100m
                memory: 128Mi
              limits:
                cpu: 200m
                memory: 256Mi
          restartPolicy: OnFailure
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
EOF

# Services
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: workload-integration
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: workload-integration
spec:
  clusterIP: None
  selector:
    app: backend
  ports:
  - port: 5432
    targetPort: 5432
EOF
```

#### Complex Debug Scenario (15 min)
```bash
echo "=== Complex Workload Debugging ==="

# Introduce multiple issues
# 1. Scale frontend beyond resource quota
kubectl scale deployment frontend --replicas=10 -n workload-integration

# 2. Create conflicting pod affinity
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: conflicted-pod
  namespace: workload-integration
  labels:
    app: frontend
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: tier
            operator: In
            values: ["backend"]
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values: ["frontend"]
        topologyKey: kubernetes.io/hostname
  containers:
  - name: app
    image: nginx
EOF

# 3. Remove toleration from backend pods
kubectl patch statefulset backend -n workload-integration -p '{"spec":{"template":{"spec":{"tolerations":[]}}}}'

# Debug process
echo "--- Checking resource usage ---"
kubectl describe resourcequota workload-quota -n workload-integration
kubectl top pods -n workload-integration

echo "--- Checking scheduling issues ---"
kubectl get pods -n workload-integration -o wide
kubectl describe pod conflicted-pod -n workload-integration

echo "--- Checking StatefulSet issues ---"
kubectl get statefulset backend -n workload-integration
kubectl describe statefulset backend -n workload-integration

# Fix the issues
echo "--- Fixing issues ---"
# Fix resource quota by scaling down
kubectl scale deployment frontend --replicas=3 -n workload-integration

# Delete conflicted pod
kubectl delete pod conflicted-pod -n workload-integration

# Fix backend toleration
kubectl patch statefulset backend -n workload-integration -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"dedicated","operator":"Equal","value":"backend","effect":"NoSchedule"}]}}}}'

# Verify fixes
echo "--- Verifying fixes ---"
kubectl get pods -n workload-integration
kubectl get all -n workload-integration
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 14 Cleanup
echo "=== Day 14 Cleanup ==="

kubectl delete namespace workload-integration
kubectl delete priorityclass critical-priority normal-priority batch-priority

# Remove node labels and taints
kubectl label node cka-cluster-1-worker tier-
kubectl label node cka-cluster-1-worker2 tier-
kubectl taint node cka-cluster-1-worker2 dedicated=backend:NoSchedule-

rm -rf ~/cka-day14

echo "Week 2 complete! Ready for Week 3."
```

---

## Week 2 Summary

**Completed Topics:**
- ✅ Deployments & Rolling Updates
- ✅ StatefulSets & Persistent Workloads
- ✅ DaemonSets & Node Management
- ✅ Jobs & CronJobs
- ✅ Resource Management & Scheduling
- ✅ Taints, Tolerations & Node Affinity
- ✅ Advanced Workload Integration

**Skills Gained:**
- Deployment lifecycle management
- Stateful application handling
- Node-level workload deployment
- Batch processing and scheduling
- Resource constraint management
- Advanced pod scheduling
- Complex multi-workload debugging

**Next Week Preview:**
Week 3 will cover Monitoring, Logging, Troubleshooting, and Cluster Maintenance with focus on operational aspects.
---

## Week 3: Monitoring, Logging & Troubleshooting

### Day 15: Cluster Monitoring & Metrics
**Time:** 60 minutes  
**Focus:** Resource monitoring, metrics collection, and performance analysis

#### Task Summary
- Set up cluster monitoring
- Analyze resource usage patterns
- Debug performance issues
- Implement custom metrics collection

#### Expected Outcome
- Master cluster monitoring concepts
- Debug resource bottlenecks
- Understand metrics and alerting

#### Setup Script
```bash
#!/bin/bash
# Day 15 Setup
echo "=== Day 15: Monitoring Setup ==="

mkdir -p ~/cka-day15 && cd ~/cka-day15

# Create monitoring namespace
kubectl create namespace monitoring-test

# Enable metrics server (if not already enabled)
kubectl top nodes 2>/dev/null || echo "Metrics server may need to be installed"

echo "Setup complete. Ready for monitoring tasks."
```

#### Main Tasks

**Task 15.1: Resource Monitoring Setup (25 min)**
```bash
# Create resource-intensive workloads for monitoring
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-intensive
  namespace: monitoring-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cpu-intensive
  template:
    metadata:
      labels:
        app: cpu-intensive
    spec:
      containers:
      - name: cpu-load
        image: busybox
        command: ['sh', '-c', 'while true; do dd if=/dev/zero of=/dev/null bs=1M count=100; sleep 1; done']
        resources:
          requests:
            cpu: 200m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-intensive
  namespace: monitoring-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-intensive
  template:
    metadata:
      labels:
        app: memory-intensive
    spec:
      containers:
      - name: memory-load
        image: busybox
        command: ['sh', '-c', 'while true; do head -c 100M /dev/zero > /tmp/memory; sleep 30; rm /tmp/memory; sleep 30; done']
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 200m
            memory: 512Mi
EOF

# Create monitoring pod with tools
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: monitoring-tools
  namespace: monitoring-test
spec:
  containers:
  - name: tools
    image: busybox
    command: ['sleep', '3600']
    volumeMounts:
    - name: proc
      mountPath: /host/proc
      readOnly: true
    - name: sys
      mountPath: /host/sys
      readOnly: true
  volumes:
  - name: proc
    hostPath:
      path: /proc
  - name: sys
    hostPath:
      path: /sys
  hostNetwork: true
EOF

# Monitor resource usage
echo "Monitoring cluster resources..."
kubectl top nodes
kubectl top pods -n monitoring-test
kubectl top pods --all-namespaces --sort-by=cpu
```

**Task 15.2: Performance Analysis (20 min)**
```bash
# Create performance test scenarios
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: performance-test
  namespace: monitoring-test
spec:
  parallelism: 3
  completions: 3
  template:
    spec:
      containers:
      - name: perf-test
        image: busybox
        command: ['sh', '-c', 'echo "Starting performance test on $(hostname)"; for i in $(seq 1 60); do echo "Test iteration $i"; sleep 1; done; echo "Performance test completed"']
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 300m
            memory: 128Mi
      restartPolicy: Never
EOF

# Monitor job performance
kubectl get jobs -n monitoring-test -w --timeout=120s &
WATCH_PID=$!

# Collect metrics during job execution
for i in {1..10}; do
  echo "=== Metrics Collection $i ==="
  kubectl top pods -n monitoring-test
  kubectl get pods -n monitoring-test -o wide
  sleep 10
done

kill $WATCH_PID 2>/dev/null

# Analyze resource usage patterns
kubectl describe nodes | grep -A5 "Allocated resources"
kubectl describe pods -n monitoring-test | grep -A10 "Containers:"
```

#### Debug Scenarios

**Debug 15.1: Resource Bottlenecks (10 min)**
```bash
echo "=== Debugging Resource Issues ==="

# Create resource-constrained deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-starved
  namespace: monitoring-test
spec:
  replicas: 5
  selector:
    matchLabels:
      app: resource-starved
  template:
    metadata:
      labels:
        app: resource-starved
    spec:
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            cpu: 1
            memory: 1Gi
          limits:
            cpu: 2
            memory: 2Gi
EOF

# Debug resource allocation
kubectl get deployment resource-starved -n monitoring-test
kubectl describe deployment resource-starved -n monitoring-test
kubectl get events -n monitoring-test --field-selector involvedObject.name=resource-starved

# Check node capacity
kubectl describe nodes | grep -E "(Name:|Capacity:|Allocatable:|Allocated resources:)" -A3

# Identify bottlenecks
echo "--- Resource Analysis ---"
kubectl top nodes
kubectl describe nodes | grep -A10 "Allocated resources"

# Fix by adjusting resource requests
kubectl patch deployment resource-starved -n monitoring-test -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"100m","memory":"128Mi"}}}]}}}}'
```

**Debug 15.2: Performance Degradation (5 min)**
```bash
# Simulate performance issues
kubectl scale deployment cpu-intensive --replicas=5 -n monitoring-test

# Monitor impact
kubectl top nodes
kubectl top pods -n monitoring-test --sort-by=cpu

# Check for throttling
kubectl describe pods -n monitoring-test -l app=cpu-intensive | grep -A5 "State:"

# Analyze and fix
kubectl get events -n monitoring-test --sort-by='.lastTimestamp' | tail -10
kubectl scale deployment cpu-intensive --replicas=2 -n monitoring-test
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 15 Cleanup
echo "=== Day 15 Cleanup ==="

kubectl delete namespace monitoring-test
rm -rf ~/cka-day15

echo "Day 15 cleanup complete"
```

---

### Day 16: Logging & Log Analysis
**Time:** 60 minutes  
**Focus:** Container logs, system logs, and log aggregation

#### Task Summary
- Analyze container and system logs
- Debug application issues using logs
- Implement log collection strategies
- Troubleshoot logging problems

#### Expected Outcome
- Master log analysis techniques
- Debug issues using log data
- Understand logging architecture

#### Setup Script
```bash
#!/bin/bash
# Day 16 Setup
echo "=== Day 16: Logging Setup ==="

mkdir -p ~/cka-day16 && cd ~/cka-day16

# Create logging namespace
kubectl create namespace logging-test

echo "Setup complete. Ready for logging tasks."
```

#### Main Tasks

**Task 16.1: Container Log Analysis (25 min)**
```bash
# Create applications with different logging patterns
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: verbose-logger
  namespace: logging-test
spec:
  containers:
  - name: logger
    image: busybox
    command: ['sh', '-c', 'i=0; while true; do echo "$(date): Log entry $i - INFO: Application running normally"; i=$((i+1)); sleep 2; done']
---
apiVersion: v1
kind: Pod
metadata:
  name: error-logger
  namespace: logging-test
spec:
  containers:
  - name: logger
    image: busybox
    command: ['sh', '-c', 'i=0; while true; do if [ $((i % 5)) -eq 0 ]; then echo "$(date): ERROR: Something went wrong at iteration $i" >&2; else echo "$(date): INFO: Normal operation $i"; fi; i=$((i+1)); sleep 3; done']
---
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-logger
  namespace: logging-test
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'while true; do echo "$(date): APP: Processing request"; sleep 5; done']
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'while true; do echo "$(date): SIDECAR: Monitoring metrics"; sleep 7; done']
EOF

# Wait for pods to start
kubectl wait --for=condition=Ready pod --all -n logging-test --timeout=60s

# Analyze different log patterns
echo "=== Basic Log Analysis ==="
kubectl logs verbose-logger -n logging-test --tail=10
kubectl logs error-logger -n logging-test --tail=10
kubectl logs multi-container-logger -c app -n logging-test --tail=5
kubectl logs multi-container-logger -c sidecar -n logging-test --tail=5

# Follow logs in real-time
echo "=== Real-time Log Monitoring ==="
timeout 30s kubectl logs -f error-logger -n logging-test &
timeout 30s kubectl logs -f verbose-logger -n logging-test --tail=5 &
wait
```

**Task 16.2: Advanced Log Operations (20 min)**
```bash
# Create deployment with log rotation scenario
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: log-generator
  namespace: logging-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: log-generator
  template:
    metadata:
      labels:
        app: log-generator
    spec:
      containers:
      - name: generator
        image: busybox
        command: ['sh', '-c', 'while true; do echo "$(date): Pod $HOSTNAME - Request processed successfully"; sleep 1; done']
EOF

# Log aggregation across pods
echo "=== Log Aggregation ==="
kubectl logs -l app=log-generator -n logging-test --tail=20
kubectl logs -l app=log-generator -n logging-test --since=1m

# Create failing application for error log analysis
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: failing-app
  namespace: logging-test
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'echo "Starting application..."; sleep 10; echo "ERROR: Database connection failed" >&2; exit 1']
  restartPolicy: Always
EOF

# Analyze crash logs
sleep 15
kubectl logs failing-app -n logging-test
kubectl logs failing-app -n logging-test --previous

# Create pod with structured logging
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: structured-logger
  namespace: logging-test
spec:
  containers:
  - name: logger
    image: busybox
    command: ['sh', '-c', 'while true; do echo "{\"timestamp\":\"$(date -Iseconds)\",\"level\":\"INFO\",\"message\":\"Request processed\",\"user_id\":$((RANDOM % 1000))}"; sleep 2; done']
EOF
```

#### Debug Scenarios

**Debug 16.1: Application Troubleshooting via Logs (10 min)**
```bash
echo "=== Debugging Application Issues ==="

# Create problematic application
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: problematic-app
  namespace: logging-test
spec:
  containers:
  - name: app
    image: nginx
    command: ['sh', '-c', 'echo "Starting nginx..."; nginx -g "daemon off;" & sleep 5; echo "ERROR: Configuration file not found" >&2; kill %1; sleep infinity']
EOF

# Debug using logs
kubectl logs problematic-app -n logging-test
kubectl describe pod problematic-app -n logging-test

# Check events and logs together
kubectl get events -n logging-test --field-selector involvedObject.name=problematic-app
kubectl logs problematic-app -n logging-test --timestamps

# Create application with intermittent issues
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: intermittent-app
  namespace: logging-test
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'while true; do if [ $((RANDOM % 10)) -lt 3 ]; then echo "$(date): ERROR: Temporary failure" >&2; sleep 5; else echo "$(date): INFO: Success"; sleep 2; fi; done']
EOF

# Monitor for patterns
timeout 60s kubectl logs -f intermittent-app -n logging-test | grep ERROR &
GREP_PID=$!
sleep 30
kill $GREP_PID 2>/dev/null
```

**Debug 16.2: Log Collection Issues (5 min)**
```bash
# Create pod with log volume issues
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: log-volume-issue
  namespace: logging-test
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'while true; do echo "$(date): Writing to log file" >> /var/log/app.log; echo "$(date): Console output"; sleep 1; done']
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
EOF

# Check different log sources
kubectl logs log-volume-issue -n logging-test --tail=10
kubectl exec log-volume-issue -n logging-test -- cat /var/log/app.log | tail -5
kubectl exec log-volume-issue -n logging-test -- ls -la /var/log/
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 16 Cleanup
echo "=== Day 16 Cleanup ==="

kubectl delete namespace logging-test
rm -rf ~/cka-day16

echo "Day 16 cleanup complete"
```

---

### Day 17: Cluster Troubleshooting & Debugging
**Time:** 60 minutes  
**Focus:** System-level debugging, component health, and cluster issues

#### Task Summary
- Debug cluster component issues
- Troubleshoot networking problems
- Analyze system-level failures
- Fix cluster connectivity issues

#### Expected Outcome
- Master cluster-level debugging
- Understand component interactions
- Fix complex system issues

#### Setup Script
```bash
#!/bin/bash
# Day 17 Setup
echo "=== Day 17: Cluster Troubleshooting Setup ==="

mkdir -p ~/cka-day17 && cd ~/cka-day17

# Create troubleshooting namespace
kubectl create namespace troubleshoot-test

echo "Setup complete. Ready for troubleshooting tasks."
```

#### Main Tasks

**Task 17.1: Component Health Analysis (25 min)**
```bash
# Check cluster component status
echo "=== Cluster Component Analysis ==="
kubectl get componentstatuses
kubectl get nodes -o wide
kubectl cluster-info

# Analyze system pods
kubectl get pods -n kube-system
kubectl describe pods -n kube-system | grep -E "(Name:|Status:|Ready:|Restart Count:)"

# Check API server health
kubectl get --raw /healthz
kubectl get --raw /readyz

# Analyze etcd health (in kind cluster)
docker exec -it cka-cluster-1-control-plane etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health

# Check kubelet status on nodes
docker exec -it cka-cluster-1-control-plane systemctl status kubelet
docker exec -it cka-cluster-1-worker systemctl status kubelet

# Create test workload to verify cluster functionality
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cluster-test
  namespace: troubleshoot-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'echo "Cluster test pod started"; sleep 30; echo "Test completed"']
EOF

kubectl wait --for=condition=Ready pod/cluster-test -n troubleshoot-test --timeout=60s
```

**Task 17.2: Network Troubleshooting (20 min)**
```bash
# Create network test pods
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: network-test-1
  namespace: troubleshoot-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
---
apiVersion: v1
kind: Pod
metadata:
  name: network-test-2
  namespace: troubleshoot-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
---
apiVersion: v1
kind: Service
metadata:
  name: network-service
  namespace: troubleshoot-test
spec:
  selector:
    app: network-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: network-app
  namespace: troubleshoot-test
  labels:
    app: network-app
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
EOF

# Wait for pods to be ready
kubectl wait --for=condition=Ready pod --all -n troubleshoot-test --timeout=60s

# Test pod-to-pod communication
POD1_IP=$(kubectl get pod network-test-1 -n troubleshoot-test -o jsonpath='{.status.podIP}')
POD2_IP=$(kubectl get pod network-test-2 -n troubleshoot-test -o jsonpath='{.status.podIP}')

echo "Testing pod-to-pod communication..."
kubectl exec network-test-1 -n troubleshoot-test -- ping -c 3 $POD2_IP
kubectl exec network-test-2 -n troubleshoot-test -- ping -c 3 $POD1_IP

# Test service connectivity
kubectl exec network-test-1 -n troubleshoot-test -- wget -qO- network-service
kubectl exec network-test-2 -n troubleshoot-test -- nslookup network-service

# Test external connectivity
kubectl exec network-test-1 -n troubleshoot-test -- nslookup google.com
kubectl exec network-test-1 -n troubleshoot-test -- wget -qO- --timeout=5 http://google.com

# Check DNS resolution
kubectl exec network-test-1 -n troubleshoot-test -- nslookup kubernetes.default.svc.cluster.local
kubectl exec network-test-1 -n troubleshoot-test -- cat /etc/resolv.conf
```

#### Debug Scenarios

**Debug 17.1: Simulated Component Failure (10 min)**
```bash
echo "=== Simulating Component Issues ==="

# Create pod with DNS issues
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: dns-issue-pod
  namespace: troubleshoot-test
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers:
    - 1.1.1.1
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
EOF

# Test DNS resolution failure
kubectl exec dns-issue-pod -n troubleshoot-test -- nslookup kubernetes.default.svc.cluster.local

# Debug DNS issues
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=20

# Create pod with image pull issues
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: image-pull-issue
  namespace: troubleshoot-test
spec:
  containers:
  - name: app
    image: nonexistent-registry.com/fake-image:latest
EOF

# Debug image pull failure
kubectl describe pod image-pull-issue -n troubleshoot-test
kubectl get events -n troubleshoot-test --field-selector involvedObject.name=image-pull-issue

# Fix DNS issue
kubectl patch pod dns-issue-pod -n troubleshoot-test -p '{"spec":{"dnsPolicy":"ClusterFirst"}}'
kubectl delete pod dns-issue-pod -n troubleshoot-test

# Create corrected pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: dns-fixed-pod
  namespace: troubleshoot-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
EOF

kubectl exec dns-fixed-pod -n troubleshoot-test -- nslookup kubernetes.default.svc.cluster.local
```

**Debug 17.2: Resource and Scheduling Issues (5 min)**
```bash
# Create pod with scheduling constraints
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: unschedulable-pod
  namespace: troubleshoot-test
spec:
  nodeSelector:
    nonexistent-label: "true"
  containers:
  - name: app
    image: nginx
EOF

# Debug scheduling failure
kubectl describe pod unschedulable-pod -n troubleshoot-test
kubectl get events -n troubleshoot-test --field-selector involvedObject.name=unschedulable-pod

# Check node labels and capacity
kubectl get nodes --show-labels
kubectl describe nodes | grep -A5 "Capacity:"

# Fix scheduling issue
kubectl patch pod unschedulable-pod -n troubleshoot-test -p '{"spec":{"nodeSelector":null}}'
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 17 Cleanup
echo "=== Day 17 Cleanup ==="

kubectl delete namespace troubleshoot-test
rm -rf ~/cka-day17

echo "Day 17 cleanup complete"
```
---

### Day 18: Network Policies & Security
**Time:** 60 minutes  
**Focus:** Network segmentation, security policies, and traffic control

#### Task Summary
- Implement network policies
- Debug network connectivity issues
- Configure traffic segmentation
- Troubleshoot policy conflicts

#### Expected Outcome
- Master network policy concepts
- Debug network security issues
- Understand traffic flow control

#### Setup Script
```bash
#!/bin/bash
# Day 18 Setup
echo "=== Day 18: Network Policies Setup ==="

mkdir -p ~/cka-day18 && cd ~/cka-day18

# Create test namespaces
kubectl create namespace frontend
kubectl create namespace backend
kubectl create namespace database

# Label namespaces for policy targeting
kubectl label namespace frontend tier=frontend
kubectl label namespace backend tier=backend
kubectl label namespace database tier=database

echo "Setup complete. Namespaces created and labeled."
```

#### Main Tasks

**Task 18.1: Basic Network Policy Implementation (25 min)**
```bash
# Create test applications in different namespaces
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend
    spec:
      containers:
      - name: frontend
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: frontend
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-app
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: backend
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: backend
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database-app
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
        tier: database
    spec:
      containers:
      - name: database
        image: postgres:13
        env:
        - name: POSTGRES_PASSWORD
          value: password
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: database
spec:
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
EOF

# Test connectivity before policies
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh -c "
  echo 'Testing frontend connectivity...'
  wget -qO- --timeout=5 frontend-service.frontend.svc.cluster.local || echo 'Frontend connection failed'
  echo 'Testing backend connectivity...'
  wget -qO- --timeout=5 backend-service.backend.svc.cluster.local || echo 'Backend connection failed'
"

# Create network policies
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: database
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-database
  namespace: database
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
EOF
```

**Task 18.2: Advanced Network Policy Scenarios (20 min)**
```bash
# Create egress policies
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-egress-policy
  namespace: frontend
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 80
  - to: []
    ports:
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-egress-policy
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
  - to: []
    ports:
    - protocol: UDP
      port: 53
EOF

# Create policy with pod selector
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: specific-pod-policy
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
      version: v2
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
          role: admin
EOF

# Create test pods with specific labels
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: admin-frontend
  namespace: frontend
  labels:
    app: frontend
    role: admin
spec:
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
---
apiVersion: v1
kind: Pod
metadata:
  name: backend-v2
  namespace: backend
  labels:
    app: backend
    version: v2
spec:
  containers:
  - name: test
    image: nginx
    ports:
    - containerPort: 80
EOF
```

#### Debug Scenarios

**Debug 18.1: Network Policy Troubleshooting (10 min)**
```bash
echo "=== Network Policy Debugging ==="

# Test connectivity after policies
kubectl run test-connectivity --image=busybox --rm -it --restart=Never -- sh -c "
  echo 'Testing database connectivity (should fail)...'
  nc -zv database-service.database.svc.cluster.local 5432 || echo 'Database connection blocked (expected)'
"

# Test from backend namespace
kubectl run test-backend --image=busybox --rm -it --restart=Never -n backend -- sh -c "
  echo 'Testing database connectivity from backend (should work)...'
  nc -zv database-service.database.svc.cluster.local 5432 && echo 'Database connection allowed'
"

# Debug policy conflicts
kubectl describe networkpolicy -n database
kubectl describe networkpolicy -n backend

# Check if policies are being enforced
kubectl get pods -n database -o wide
kubectl get networkpolicies --all-namespaces

# Create debugging pod in database namespace
kubectl run debug-pod --image=busybox --rm -it --restart=Never -n database -- sh -c "
  echo 'Testing outbound connectivity...'
  nc -zv google.com 80 || echo 'Outbound connection blocked'
"
```

**Debug 18.2: Policy Conflict Resolution (5 min)**
```bash
# Create conflicting policies
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: conflicting-policy
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress: []  # Deny all ingress
EOF

# Test connectivity (should fail)
kubectl run test-conflict --image=busybox --rm -it --restart=Never -n frontend -- sh -c "
  wget -qO- --timeout=5 backend-service.backend.svc.cluster.local || echo 'Connection blocked by conflicting policy'
"

# Resolve conflict by updating policy
kubectl patch networkpolicy conflicting-policy -n backend -p '{"spec":{"ingress":[{"from":[{"namespaceSelector":{"matchLabels":{"tier":"frontend"}}}],"ports":[{"protocol":"TCP","port":80}]}]}}'

# Test again (should work)
kubectl run test-resolved --image=busybox --rm -it --restart=Never -n frontend -- sh -c "
  wget -qO- --timeout=5 backend-service.backend.svc.cluster.local && echo 'Connection restored'
"
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 18 Cleanup
echo "=== Day 18 Cleanup ==="

kubectl delete namespace frontend backend database
rm -rf ~/cka-day18

echo "Day 18 cleanup complete"
```

---

### Day 19: Backup & Restore Operations
**Time:** 60 minutes  
**Focus:** etcd backup, cluster state recovery, and data protection

#### Task Summary
- Perform etcd backup and restore
- Backup application data
- Test disaster recovery scenarios
- Implement backup automation

#### Expected Outcome
- Master backup and restore procedures
- Handle disaster recovery scenarios
- Understand data protection strategies

#### Setup Script
```bash
#!/bin/bash
# Day 19 Setup
echo "=== Day 19: Backup & Restore Setup ==="

mkdir -p ~/cka-day19 && cd ~/cka-day19

# Create backup namespace
kubectl create namespace backup-test

# Create some test data to backup
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: important-config
  namespace: backup-test
data:
  app.properties: |
    database.host=prod-db
    database.port=5432
    cache.enabled=true
  version: "1.0.0"
---
apiVersion: v1
kind: Secret
metadata:
  name: important-secret
  namespace: backup-test
type: Opaque
data:
  username: YWRtaW4=  # admin
  password: cGFzc3dvcmQ=  # password
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
  namespace: backup-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: critical-app
  template:
    metadata:
      labels:
        app: critical-app
    spec:
      containers:
      - name: app
        image: nginx
        env:
        - name: CONFIG_VERSION
          valueFrom:
            configMapKeyRef:
              name: important-config
              key: version
EOF

echo "Setup complete. Test data created for backup scenarios."
```

#### Main Tasks

**Task 19.1: etcd Backup Operations (25 min)**
```bash
# Check etcd status
echo "=== etcd Health Check ==="
docker exec -it cka-cluster-1-control-plane etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  endpoint health

# Create etcd backup
echo "=== Creating etcd Backup ==="
BACKUP_FILE="/tmp/etcd-backup-$(date +%Y%m%d-%H%M%S).db"

docker exec -it cka-cluster-1-control-plane etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save $BACKUP_FILE

# Verify backup
docker exec -it cka-cluster-1-control-plane etcdctl \
  --write-out=table snapshot status $BACKUP_FILE

# Copy backup to host
docker cp cka-cluster-1-control-plane:$BACKUP_FILE ./etcd-backup.db

echo "Backup created: ./etcd-backup.db"

# Create additional cluster state for testing
kubectl create namespace test-restore
kubectl create configmap test-data --from-literal=key=value -n test-restore
kubectl create secret generic test-secret --from-literal=password=secret123 -n test-restore

# List current cluster state
echo "=== Current Cluster State ==="
kubectl get namespaces
kubectl get configmaps -n backup-test
kubectl get secrets -n backup-test
kubectl get deployments -n backup-test
```

**Task 19.2: Application Data Backup (20 min)**
```bash
# Create persistent volume for application data
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: backup-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/backup-data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-pvc
  namespace: backup-test
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: data-app
  namespace: backup-test
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'while true; do echo "$(date): Important data entry" >> /data/app.log; sleep 10; done']
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: backup-pvc
EOF

# Wait for pod to generate some data
sleep 30

# Create data backup job
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
  namespace: backup-test
spec:
  template:
    spec:
      containers:
      - name: backup
        image: busybox
        command: ['sh', '-c', 'tar -czf /backup/data-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .; echo "Backup completed"']
        volumeMounts:
        - name: data
          mountPath: /data
          readOnly: true
        - name: backup-storage
          mountPath: /backup
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: backup-pvc
      - name: backup-storage
        hostPath:
          path: /tmp/backups
      restartPolicy: Never
EOF

# Monitor backup job
kubectl wait --for=condition=complete job/backup-job -n backup-test --timeout=60s
kubectl logs job/backup-job -n backup-test

# Verify backup files
docker exec -it cka-cluster-1-control-plane ls -la /tmp/backups/
```

#### Debug Scenarios

**Debug 19.1: Restore Testing (10 min)**
```bash
echo "=== Testing Restore Scenarios ==="

# Simulate data loss by deleting resources
kubectl delete namespace test-restore
kubectl delete configmap important-config -n backup-test
kubectl delete secret important-secret -n backup-test

# Verify deletion
kubectl get namespaces | grep test-restore || echo "test-restore namespace deleted"
kubectl get configmaps -n backup-test | grep important-config || echo "important-config deleted"

# Simulate etcd restore (in production, this would require cluster downtime)
echo "=== Simulating etcd Restore Process ==="
echo "In a real scenario, you would:"
echo "1. Stop all API servers"
echo "2. Stop etcd"
echo "3. Restore from backup using: etcdctl snapshot restore"
echo "4. Update etcd configuration"
echo "5. Restart etcd and API servers"

# For demonstration, recreate the deleted resources manually
kubectl create namespace test-restore
kubectl create configmap test-data --from-literal=key=value -n test-restore

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: important-config
  namespace: backup-test
data:
  app.properties: |
    database.host=prod-db
    database.port=5432
    cache.enabled=true
  version: "1.0.0"
---
apiVersion: v1
kind: Secret
metadata:
  name: important-secret
  namespace: backup-test
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=
EOF

echo "Resources restored successfully"
```

**Debug 19.2: Backup Validation (5 min)**
```bash
# Validate backup integrity
echo "=== Backup Validation ==="

# Check etcd backup
docker exec -it cka-cluster-1-control-plane etcdctl \
  --write-out=table snapshot status /tmp/etcd-backup-*.db

# Verify application data backup
docker exec -it cka-cluster-1-control-plane ls -la /tmp/backups/
docker exec -it cka-cluster-1-control-plane tar -tzf /tmp/backups/data-backup-*.tar.gz

# Test backup restoration process
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: restore-test-job
  namespace: backup-test
spec:
  template:
    spec:
      containers:
      - name: restore-test
        image: busybox
        command: ['sh', '-c', 'cd /restore && tar -xzf /backup/data-backup-*.tar.gz && echo "Restore test completed" && ls -la']
        volumeMounts:
        - name: backup-storage
          mountPath: /backup
          readOnly: true
        - name: restore-location
          mountPath: /restore
      volumes:
      - name: backup-storage
        hostPath:
          path: /tmp/backups
      - name: restore-location
        emptyDir: {}
      restartPolicy: Never
EOF

kubectl wait --for=condition=complete job/restore-test-job -n backup-test --timeout=60s
kubectl logs job/restore-test-job -n backup-test
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 19 Cleanup
echo "=== Day 19 Cleanup ==="

kubectl delete namespace backup-test test-restore
kubectl delete pv backup-pv

# Clean up backup files
docker exec -it cka-cluster-1-control-plane rm -f /tmp/etcd-backup-*.db
docker exec -it cka-cluster-1-control-plane rm -rf /tmp/backups
docker exec -it cka-cluster-1-control-plane rm -rf /tmp/backup-data

rm -f ./etcd-backup.db
rm -rf ~/cka-day19

echo "Day 19 cleanup complete"
```
---

### Day 20: Cluster Maintenance & Upgrades
**Time:** 60 minutes  
**Focus:** Node maintenance, cluster upgrades, and system updates

#### Task Summary
- Perform node maintenance procedures
- Simulate cluster upgrade scenarios
- Handle node cordoning and draining
- Manage system-level maintenance

#### Expected Outcome
- Master cluster maintenance procedures
- Handle node lifecycle management
- Understand upgrade strategies

#### Setup Script
```bash
#!/bin/bash
# Day 20 Setup
echo "=== Day 20: Cluster Maintenance Setup ==="

mkdir -p ~/cka-day20 && cd ~/cka-day20

# Create maintenance namespace
kubectl create namespace maintenance-test

# Deploy test workloads across nodes
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: distributed-app
  namespace: maintenance-test
spec:
  replicas: 6
  selector:
    matchLabels:
      app: distributed-app
  template:
    metadata:
      labels:
        app: distributed-app
    spec:
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: system-monitor
  namespace: maintenance-test
spec:
  selector:
    matchLabels:
      app: system-monitor
  template:
    metadata:
      labels:
        app: system-monitor
    spec:
      containers:
      - name: monitor
        image: busybox
        command: ['sh', '-c', 'while true; do echo "$(date): Monitoring $(hostname)"; sleep 30; done']
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
EOF

echo "Setup complete. Workloads distributed across cluster."
```

#### Main Tasks

**Task 20.1: Node Maintenance Procedures (25 min)**
```bash
# Check current node status and pod distribution
echo "=== Pre-Maintenance Cluster State ==="
kubectl get nodes -o wide
kubectl get pods -n maintenance-test -o wide
kubectl describe nodes | grep -A5 "Non-terminated Pods"

# Cordon a worker node (prevent new pods)
echo "=== Cordoning Node ==="
kubectl cordon cka-cluster-1-worker
kubectl get nodes

# Try to scale deployment (new pods should avoid cordoned node)
kubectl scale deployment distributed-app --replicas=8 -n maintenance-test
sleep 10
kubectl get pods -n maintenance-test -o wide

# Drain the node (move existing pods)
echo "=== Draining Node ==="
kubectl drain cka-cluster-1-worker --ignore-daemonsets --delete-emptydir-data --force

# Check pod redistribution
kubectl get pods -n maintenance-test -o wide
kubectl get nodes

# Simulate maintenance work
echo "=== Simulating Maintenance ==="
echo "Performing maintenance on cka-cluster-1-worker..."
sleep 10
echo "Maintenance completed"

# Uncordon the node
echo "=== Uncordoning Node ==="
kubectl uncordon cka-cluster-1-worker
kubectl get nodes

# Verify node is schedulable again
kubectl scale deployment distributed-app --replicas=10 -n maintenance-test
sleep 15
kubectl get pods -n maintenance-test -o wide
```

**Task 20.2: Cluster Component Management (20 min)**
```bash
# Check current cluster version
echo "=== Cluster Version Information ==="
kubectl version --short
kubectl get nodes -o wide

# Check component versions in kind cluster
docker exec -it cka-cluster-1-control-plane kubeadm version
docker exec -it cka-cluster-1-control-plane kubelet --version

# Simulate pre-upgrade checks
echo "=== Pre-Upgrade Validation ==="
kubectl get pods --all-namespaces | grep -v Running
kubectl get nodes --no-headers | awk '{print $2}' | grep -v Ready || echo "All nodes ready"

# Check system pods health
kubectl get pods -n kube-system
kubectl describe pods -n kube-system | grep -E "(Name:|Status:|Ready:)"

# Create upgrade simulation script
cat > upgrade-simulation.sh << 'EOF'
#!/bin/bash
echo "=== Cluster Upgrade Simulation ==="
echo "In a real upgrade scenario, you would:"
echo "1. Backup etcd"
echo "2. Upgrade control plane components"
echo "3. Upgrade worker nodes one by one"
echo "4. Validate cluster functionality"

echo "Simulating control plane upgrade..."
sleep 5

echo "Simulating worker node upgrades..."
for node in cka-cluster-1-worker cka-cluster-1-worker2; do
    echo "Upgrading $node..."
    echo "  - Cordoning node"
    echo "  - Draining workloads"
    echo "  - Upgrading kubelet and kubeadm"
    echo "  - Uncordoning node"
    sleep 3
done

echo "Upgrade simulation completed"
EOF

chmod +x upgrade-simulation.sh
./upgrade-simulation.sh

# Test cluster functionality post-simulation
kubectl get pods -n maintenance-test
kubectl get nodes
```

#### Debug Scenarios

**Debug 20.1: Stuck Pod During Drain (10 min)**
```bash
echo "=== Debugging Drain Issues ==="

# Create pod with PDB that might block draining
cat <<EOF | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: critical-app-pdb
  namespace: maintenance-test
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: critical-app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
  namespace: maintenance-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: critical-app
  template:
    metadata:
      labels:
        app: critical-app
    spec:
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
      nodeSelector:
        kubernetes.io/hostname: cka-cluster-1-worker2
EOF

# Wait for pods to be scheduled
sleep 15
kubectl get pods -n maintenance-test -o wide | grep critical-app

# Try to drain node with PDB (should have issues)
kubectl drain cka-cluster-1-worker2 --ignore-daemonsets --delete-emptydir-data --timeout=30s || echo "Drain blocked by PDB"

# Check PDB status
kubectl get pdb -n maintenance-test
kubectl describe pdb critical-app-pdb -n maintenance-test

# Resolve by adjusting PDB or using force
kubectl patch pdb critical-app-pdb -n maintenance-test -p '{"spec":{"minAvailable":1}}'

# Retry drain
kubectl drain cka-cluster-1-worker2 --ignore-daemonsets --delete-emptydir-data --force

# Uncordon for cleanup
kubectl uncordon cka-cluster-1-worker2
```

**Debug 20.2: Node Not Ready Issues (5 min)**
```bash
# Simulate node issues by checking kubelet status
echo "=== Node Health Debugging ==="

# Check node conditions
kubectl describe nodes | grep -A10 "Conditions:"

# Check kubelet logs (in kind cluster)
docker exec -it cka-cluster-1-worker journalctl -u kubelet --no-pager --lines=20

# Check system resource usage
kubectl top nodes
kubectl describe nodes | grep -A5 "Allocated resources:"

# Verify node components
docker exec -it cka-cluster-1-worker systemctl status kubelet
docker exec -it cka-cluster-1-worker systemctl status containerd
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 20 Cleanup
echo "=== Day 20 Cleanup ==="

kubectl delete namespace maintenance-test
rm -f upgrade-simulation.sh
rm -rf ~/cka-day20

# Ensure all nodes are uncordoned
kubectl uncordon cka-cluster-1-worker
kubectl uncordon cka-cluster-1-worker2

echo "Day 20 cleanup complete"
```

---

### Day 21: Week 3 Review & Operational Excellence
**Time:** 60 minutes  
**Focus:** Integrating all Week 3 concepts in complex operational scenarios

#### Task Summary
- Create comprehensive monitoring and alerting
- Implement end-to-end troubleshooting scenarios
- Practice complex operational procedures
- Simulate real-world incident response

#### Expected Outcome
- Integrate all Week 3 operational concepts
- Handle complex multi-component issues
- Build confidence for Week 4

#### Setup Script
```bash
#!/bin/bash
# Day 21 Setup
echo "=== Day 21: Operational Excellence Setup ==="

mkdir -p ~/cka-day21 && cd ~/cka-day21

# Create operational namespace
kubectl create namespace ops-integration

# Label nodes for operational testing
kubectl label node cka-cluster-1-worker environment=production
kubectl label node cka-cluster-1-worker2 environment=staging

echo "Setup complete. Ready for operational integration."
```

#### Integration Task: Complete Operational Scenario (45 min)
```bash
# Deploy comprehensive application stack
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
  labels:
    purpose: monitoring
---
# Production Application
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-frontend
  template:
    metadata:
      labels:
        app: web-frontend
        tier: frontend
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: environment
                operator: In
                values: ["production"]
      containers:
      - name: frontend
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
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
---
apiVersion: v1
kind: Service
metadata:
  name: web-frontend-service
  namespace: production
spec:
  selector:
    app: web-frontend
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
---
# Database
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
  namespace: production
spec:
  serviceName: database-service
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: proddb
        - name: POSTGRES_USER
          value: produser
        - name: POSTGRES_PASSWORD
          value: prodpass
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: production
spec:
  clusterIP: None
  selector:
    app: database
  ports:
  - port: 5432
---
# Monitoring DaemonSet
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-monitor
  template:
    metadata:
      labels:
        app: node-monitor
    spec:
      tolerations:
      - operator: Exists
      containers:
      - name: monitor
        image: busybox
        command: ['sh', '-c', 'while true; do echo "$(date): Node $(hostname) - CPU: $(cat /proc/loadavg)"; sleep 30; done']
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      hostNetwork: true
---
# Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: production-network-policy
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          purpose: monitoring
  - from: []
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
---
# Backup CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: production
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:13
            command: ['sh', '-c', 'pg_dump -h database-service -U produser proddb > /backup/backup-$(date +%Y%m%d).sql']
            env:
            - name: PGPASSWORD
              value: prodpass
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            hostPath:
              path: /tmp/db-backups
          restartPolicy: OnFailure
EOF

# Wait for deployments
kubectl wait --for=condition=available deployment --all -n production --timeout=120s

# Create resource quota and limits
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    persistentvolumeclaims: "5"
    pods: "20"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: production-limits
  namespace: production
spec:
  limits:
  - default:
      cpu: 200m
      memory: 256Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
EOF
```

#### Complex Operational Scenario (15 min)
```bash
echo "=== Complex Operational Incident Simulation ==="

# Simulate multiple issues simultaneously
echo "--- Introducing Multiple Issues ---"

# 1. Scale up beyond resource quota
kubectl scale deployment web-frontend --replicas=10 -n production

# 2. Taint production node
kubectl taint node cka-cluster-1-worker maintenance=true:NoSchedule

# 3. Create problematic pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-hog
  namespace: production
spec:
  containers:
  - name: hog
    image: busybox
    command: ['sh', '-c', 'while true; do dd if=/dev/zero of=/dev/null bs=1M count=100; sleep 1; done']
    resources:
      requests:
        cpu: 2
        memory: 2Gi
EOF

# 4. Break network connectivity
kubectl patch networkpolicy production-network-policy -n production -p '{"spec":{"ingress":[]}}'

# Start incident response
echo "--- Incident Response Process ---"

# Step 1: Assess the situation
echo "1. Assessing cluster health..."
kubectl get nodes
kubectl top nodes
kubectl get pods -n production
kubectl describe resourcequota production-quota -n production

# Step 2: Identify issues
echo "2. Identifying issues..."
kubectl get events -n production --sort-by='.lastTimestamp' | tail -10
kubectl describe deployment web-frontend -n production
kubectl describe pod resource-hog -n production

# Step 3: Prioritize and fix critical issues
echo "3. Fixing critical issues..."

# Fix resource quota issue
kubectl scale deployment web-frontend --replicas=3 -n production

# Remove problematic pod
kubectl delete pod resource-hog -n production

# Fix network policy
kubectl patch networkpolicy production-network-policy -n production -p '{"spec":{"ingress":[{"from":[{"namespaceSelector":{"matchLabels":{"purpose":"monitoring"}}}]},{"from":[],"ports":[{"protocol":"TCP","port":80}]}]}}'

# Remove taint
kubectl taint node cka-cluster-1-worker maintenance=true:NoSchedule-

# Step 4: Verify resolution
echo "4. Verifying resolution..."
kubectl get pods -n production
kubectl get nodes
kubectl top pods -n production

# Step 5: Post-incident analysis
echo "5. Post-incident analysis..."
kubectl logs -n production -l app=web-frontend --tail=20
kubectl get events -n production --sort-by='.lastTimestamp' | tail -5

echo "Incident resolved successfully!"
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 21 Cleanup
echo "=== Day 21 Cleanup ==="

kubectl delete namespace ops-integration production monitoring
kubectl delete pv --all

# Remove node labels and taints
kubectl label node cka-cluster-1-worker environment-
kubectl label node cka-cluster-1-worker2 environment-
kubectl taint node cka-cluster-1-worker maintenance- --ignore-not-found

# Clean up backup directories
docker exec -it cka-cluster-1-control-plane rm -rf /tmp/db-backups

rm -rf ~/cka-day21

echo "Week 3 complete! Ready for Week 4."
```

---

## Week 3 Summary

**Completed Topics:**
- ✅ Cluster Monitoring & Metrics
- ✅ Logging & Log Analysis
- ✅ Cluster Troubleshooting & Debugging
- ✅ Network Policies & Security
- ✅ Backup & Restore Operations
- ✅ Cluster Maintenance & Upgrades
- ✅ Operational Excellence Integration

**Skills Gained:**
- Resource monitoring and performance analysis
- Log-based troubleshooting and debugging
- System-level cluster diagnostics
- Network security and policy implementation
- Disaster recovery and data protection
- Cluster maintenance and upgrade procedures
- Complex operational incident response

**Next Week Preview:**
Week 4 will cover Advanced Topics, Mock Exams, and Final Preparation with focus on exam readiness and advanced scenarios.
---

## Week 4: Advanced Topics & Exam Preparation

### Day 22: Advanced Networking & CNI
**Time:** 60 minutes  
**Focus:** Container networking, CNI plugins, and advanced network troubleshooting

#### Task Summary
- Understand CNI plugin architecture
- Debug complex networking issues
- Analyze network traffic flow
- Troubleshoot DNS and service mesh issues

#### Expected Outcome
- Master advanced networking concepts
- Debug complex network problems
- Understand CNI plugin behavior

#### Setup Script
```bash
#!/bin/bash
# Day 22 Setup
echo "=== Day 22: Advanced Networking Setup ==="

mkdir -p ~/cka-day22 && cd ~/cka-day22

# Create networking test namespace
kubectl create namespace network-advanced

echo "Setup complete. Ready for advanced networking tasks."
```

#### Main Tasks

**Task 22.1: CNI and Network Analysis (25 min)**
```bash
# Examine CNI configuration in kind cluster
echo "=== CNI Configuration Analysis ==="
docker exec -it cka-cluster-1-control-plane ls -la /etc/cni/net.d/
docker exec -it cka-cluster-1-control-plane cat /etc/cni/net.d/*

# Check network interfaces on nodes
docker exec -it cka-cluster-1-control-plane ip addr show
docker exec -it cka-cluster-1-worker ip addr show

# Analyze pod networking
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: network-debug-1
  namespace: network-advanced
spec:
  containers:
  - name: debug
    image: nicolaka/netshoot
    command: ['sleep', '3600']
---
apiVersion: v1
kind: Pod
metadata:
  name: network-debug-2
  namespace: network-advanced
spec:
  containers:
  - name: debug
    image: nicolaka/netshoot
    command: ['sleep', '3600']
EOF

# Wait for pods
kubectl wait --for=condition=Ready pod --all -n network-advanced --timeout=60s

# Analyze network configuration
kubectl exec -it network-debug-1 -n network-advanced -- ip addr show
kubectl exec -it network-debug-1 -n network-advanced -- ip route show
kubectl exec -it network-debug-1 -n network-advanced -- cat /etc/resolv.conf

# Test inter-pod communication
POD1_IP=$(kubectl get pod network-debug-1 -n network-advanced -o jsonpath='{.status.podIP}')
POD2_IP=$(kubectl get pod network-debug-2 -n network-advanced -o jsonpath='{.status.podIP}')

kubectl exec -it network-debug-1 -n network-advanced -- ping -c 3 $POD2_IP
kubectl exec -it network-debug-2 -n network-advanced -- traceroute $POD1_IP
```

**Task 22.2: Advanced Service Networking (20 min)**
```bash
# Create complex service scenarios
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-port-app
  namespace: network-advanced
spec:
  replicas: 2
  selector:
    matchLabels:
      app: multi-port-app
  template:
    metadata:
      labels:
        app: multi-port-app
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
  namespace: network-advanced
spec:
  selector:
    app: multi-port-app
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: alt-http
    port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: external-service
  namespace: network-advanced
spec:
  type: ExternalName
  externalName: httpbin.org
  ports:
  - port: 80
---
apiVersion: v1
kind: Endpoints
metadata:
  name: manual-endpoints
  namespace: network-advanced
subsets:
- addresses:
  - ip: 8.8.8.8
  ports:
  - port: 53
    protocol: UDP
---
apiVersion: v1
kind: Service
metadata:
  name: manual-service
  namespace: network-advanced
spec:
  ports:
  - port: 53
    protocol: UDP
EOF

# Test service connectivity
kubectl exec -it network-debug-1 -n network-advanced -- nslookup multi-port-service
kubectl exec -it network-debug-1 -n network-advanced -- wget -qO- multi-port-service:80
kubectl exec -it network-debug-1 -n network-advanced -- nslookup external-service
kubectl exec -it network-debug-1 -n network-advanced -- nslookup google.com manual-service
```

#### Debug Scenarios

**Debug 22.1: Complex Network Issues (10 min)**
```bash
echo "=== Advanced Network Debugging ==="

# Create network policy that blocks traffic
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-all-policy
  namespace: network-advanced
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Test connectivity (should fail)
kubectl exec -it network-debug-1 -n network-advanced -- ping -c 2 $POD2_IP || echo "Ping blocked by network policy"
kubectl exec -it network-debug-1 -n network-advanced -- wget -qO- --timeout=5 multi-port-service || echo "Service access blocked"

# Debug network policy
kubectl describe networkpolicy block-all-policy -n network-advanced

# Analyze traffic flow
kubectl exec -it network-debug-1 -n network-advanced -- netstat -tuln
kubectl exec -it network-debug-1 -n network-advanced -- ss -tuln

# Fix by allowing specific traffic
kubectl patch networkpolicy block-all-policy -n network-advanced -p '{"spec":{"egress":[{"to":[],"ports":[{"protocol":"UDP","port":53}]},{"to":[{"podSelector":{}}]}],"ingress":[{"from":[{"podSelector":{}}]}]}}'

# Verify fix
kubectl exec -it network-debug-1 -n network-advanced -- ping -c 2 $POD2_IP
```

**Debug 22.2: DNS Resolution Issues (5 min)**
```bash
# Create pod with custom DNS
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: custom-dns-pod
  namespace: network-advanced
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers:
    - 1.1.1.1
    searches:
    - custom.local
  containers:
  - name: test
    image: busybox
    command: ['sleep', '3600']
EOF

# Test DNS resolution
kubectl exec -it custom-dns-pod -n network-advanced -- nslookup kubernetes.default.svc.cluster.local || echo "Cluster DNS not accessible"
kubectl exec -it custom-dns-pod -n network-advanced -- nslookup google.com

# Debug DNS configuration
kubectl exec -it custom-dns-pod -n network-advanced -- cat /etc/resolv.conf
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Fix DNS configuration
kubectl patch pod custom-dns-pod -n network-advanced -p '{"spec":{"dnsPolicy":"ClusterFirst"}}'
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 22 Cleanup
echo "=== Day 22 Cleanup ==="

kubectl delete namespace network-advanced
rm -rf ~/cka-day22

echo "Day 22 cleanup complete"
```

---

### Day 23: Custom Resources & Operators
**Time:** 60 minutes  
**Focus:** Custom Resource Definitions, operators, and extending Kubernetes

#### Task Summary
- Create and manage Custom Resource Definitions
- Understand operator patterns
- Debug custom resource issues
- Implement resource validation

#### Expected Outcome
- Master CRD concepts and implementation
- Understand Kubernetes extensibility
- Debug custom resource problems

#### Setup Script
```bash
#!/bin/bash
# Day 23 Setup
echo "=== Day 23: Custom Resources Setup ==="

mkdir -p ~/cka-day23 && cd ~/cka-day23

# Create CRD test namespace
kubectl create namespace crd-test

echo "Setup complete. Ready for custom resource tasks."
```

#### Main Tasks

**Task 23.1: Custom Resource Definition Creation (25 min)**
```bash
# Create basic CRD
cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: webapps.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              replicas:
                type: integer
                minimum: 1
                maximum: 10
              image:
                type: string
              port:
                type: integer
                minimum: 1
                maximum: 65535
            required:
            - replicas
            - image
            - port
          status:
            type: object
            properties:
              availableReplicas:
                type: integer
              conditions:
                type: array
                items:
                  type: object
                  properties:
                    type:
                      type: string
                    status:
                      type: string
                    lastTransitionTime:
                      type: string
                      format: date-time
  scope: Namespaced
  names:
    plural: webapps
    singular: webapp
    kind: WebApp
    shortNames:
    - wa
EOF

# Verify CRD creation
kubectl get crd webapps.example.com
kubectl describe crd webapps.example.com

# Create custom resource instances
cat <<EOF | kubectl apply -f -
apiVersion: example.com/v1
kind: WebApp
metadata:
  name: my-webapp
  namespace: crd-test
spec:
  replicas: 3
  image: nginx:1.20
  port: 80
---
apiVersion: example.com/v1
kind: WebApp
metadata:
  name: api-webapp
  namespace: crd-test
spec:
  replicas: 2
  image: httpd:2.4
  port: 8080
EOF

# List custom resources
kubectl get webapps -n crd-test
kubectl get wa -n crd-test
kubectl describe webapp my-webapp -n crd-test
```

**Task 23.2: Advanced CRD Features (20 min)**
```bash
# Create CRD with validation and status
cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.storage.example.com
spec:
  group: storage.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              type:
                type: string
                enum: ["mysql", "postgres", "mongodb"]
              version:
                type: string
                pattern: '^[0-9]+\.[0-9]+$'
              storage:
                type: string
                pattern: '^[0-9]+Gi$'
              backup:
                type: object
                properties:
                  enabled:
                    type: boolean
                  schedule:
                    type: string
            required:
            - type
            - version
            - storage
          status:
            type: object
            properties:
              phase:
                type: string
                enum: ["Pending", "Running", "Failed"]
              message:
                type: string
    additionalPrinterColumns:
    - name: Type
      type: string
      jsonPath: .spec.type
    - name: Version
      type: string
      jsonPath: .spec.version
    - name: Storage
      type: string
      jsonPath: .spec.storage
    - name: Phase
      type: string
      jsonPath: .status.phase
    - name: Age
      type: date
      jsonPath: .metadata.creationTimestamp
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
    - db
EOF

# Create database instances
cat <<EOF | kubectl apply -f -
apiVersion: storage.example.com/v1
kind: Database
metadata:
  name: prod-mysql
  namespace: crd-test
spec:
  type: mysql
  version: "8.0"
  storage: "10Gi"
  backup:
    enabled: true
    schedule: "0 2 * * *"
---
apiVersion: storage.example.com/v1
kind: Database
metadata:
  name: dev-postgres
  namespace: crd-test
spec:
  type: postgres
  version: "13.0"
  storage: "5Gi"
  backup:
    enabled: false
EOF

# View with custom columns
kubectl get databases -n crd-test
kubectl get db -n crd-test -o wide

# Update status (simulating controller behavior)
kubectl patch database prod-mysql -n crd-test --subresource=status -p '{"status":{"phase":"Running","message":"Database is healthy"}}'
kubectl patch database dev-postgres -n crd-test --subresource=status -p '{"status":{"phase":"Pending","message":"Initializing database"}}'

kubectl get databases -n crd-test
```

#### Debug Scenarios

**Debug 23.1: CRD Validation Issues (10 min)**
```bash
echo "=== CRD Validation Debugging ==="

# Try to create invalid custom resource
cat <<EOF | kubectl apply -f - || echo "Validation failed as expected"
apiVersion: storage.example.com/v1
kind: Database
metadata:
  name: invalid-db
  namespace: crd-test
spec:
  type: oracle  # Invalid enum value
  version: "invalid-version"  # Invalid pattern
  storage: "invalid-storage"  # Invalid pattern
EOF

# Try another invalid resource
cat <<EOF | kubectl apply -f - || echo "Validation failed as expected"
apiVersion: example.com/v1
kind: WebApp
metadata:
  name: invalid-webapp
  namespace: crd-test
spec:
  replicas: 15  # Exceeds maximum
  image: ""     # Empty required field
  port: 70000   # Exceeds maximum
EOF

# Debug validation errors
kubectl get events -n crd-test --field-selector reason=FailedCreate

# Create valid resources
cat <<EOF | kubectl apply -f -
apiVersion: storage.example.com/v1
kind: Database
metadata:
  name: valid-db
  namespace: crd-test
spec:
  type: postgres
  version: "12.0"
  storage: "20Gi"
EOF

kubectl get database valid-db -n crd-test -o yaml
```

**Debug 23.2: CRD Management Issues (5 min)**
```bash
# Check CRD status and conditions
kubectl get crd -o wide
kubectl describe crd webapps.example.com

# Try to delete CRD with existing resources
kubectl delete crd webapps.example.com || echo "CRD deletion blocked by existing resources"

# Check finalizers
kubectl get webapp -n crd-test -o yaml | grep finalizers

# Force cleanup if needed
kubectl delete webapps --all -n crd-test
kubectl delete crd webapps.example.com

# Verify cleanup
kubectl get crd | grep example.com
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 23 Cleanup
echo "=== Day 23 Cleanup ==="

kubectl delete namespace crd-test
kubectl delete crd --all --selector='metadata.name~=example.com'

rm -rf ~/cka-day23

echo "Day 23 cleanup complete"
```

---

### Day 24: Performance Tuning & Optimization
**Time:** 60 minutes  
**Focus:** Cluster performance optimization, resource tuning, and bottleneck analysis

#### Task Summary
- Analyze cluster performance bottlenecks
- Optimize resource allocation
- Tune application performance
- Implement performance monitoring

#### Expected Outcome
- Master performance analysis techniques
- Optimize cluster resource usage
- Identify and resolve bottlenecks

#### Setup Script
```bash
#!/bin/bash
# Day 24 Setup
echo "=== Day 24: Performance Tuning Setup ==="

mkdir -p ~/cka-day24 && cd ~/cka-day24

# Create performance test namespace
kubectl create namespace perf-test

echo "Setup complete. Ready for performance tuning tasks."
```

#### Main Tasks

**Task 24.1: Resource Optimization Analysis (25 min)**
```bash
# Create baseline workloads for performance testing
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-intensive-app
  namespace: perf-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cpu-intensive
  template:
    metadata:
      labels:
        app: cpu-intensive
    spec:
      containers:
      - name: cpu-load
        image: busybox
        command: ['sh', '-c', 'while true; do for i in $(seq 1 1000000); do echo $i > /dev/null; done; sleep 1; done']
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-intensive-app
  namespace: perf-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: memory-intensive
  template:
    metadata:
      labels:
        app: memory-intensive
    spec:
      containers:
      - name: memory-load
        image: busybox
        command: ['sh', '-c', 'while true; do head -c 50M /dev/zero > /tmp/memory; sleep 30; rm /tmp/memory; sleep 30; done']
        resources:
          requests:
            cpu: 50m
            memory: 128Mi
          limits:
            cpu: 100m
            memory: 256Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: io-intensive-app
  namespace: perf-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: io-intensive
  template:
    metadata:
      labels:
        app: io-intensive
    spec:
      containers:
      - name: io-load
        image: busybox
        command: ['sh', '-c', 'while true; do dd if=/dev/zero of=/tmp/testfile bs=1M count=100; sync; rm /tmp/testfile; sleep 10; done']
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
EOF

# Wait for deployments
kubectl wait --for=condition=available deployment --all -n perf-test --timeout=120s

# Baseline performance analysis
echo "=== Baseline Performance Analysis ==="
kubectl top nodes
kubectl top pods -n perf-test
kubectl describe nodes | grep -A10 "Allocated resources"

# Analyze resource utilization patterns
for i in {1..5}; do
  echo "--- Measurement $i ---"
  kubectl top pods -n perf-test --sort-by=cpu
  kubectl top pods -n perf-test --sort-by=memory
  sleep 30
done
```

**Task 24.2: Performance Optimization Implementation (20 min)**
```bash
# Implement Horizontal Pod Autoscaler
cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cpu-intensive-hpa
  namespace: perf-test
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cpu-intensive-app
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF

# Create optimized deployment with better resource allocation
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: optimized-app
  namespace: perf-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: optimized-app
  template:
    metadata:
      labels:
        app: optimized-app
    spec:
      containers:
      - name: app
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values: ["optimized-app"]
              topologyKey: kubernetes.io/hostname
EOF

# Monitor HPA behavior
kubectl get hpa -n perf-test -w --timeout=120s &
HPA_PID=$!

# Generate load to trigger scaling
kubectl run load-generator --image=busybox --rm -it --restart=Never -n perf-test -- sh -c "
  while true; do
    for pod in \$(kubectl get pods -n perf-test -l app=cpu-intensive -o name); do
      kubectl exec -n perf-test \$pod -- sh -c 'for i in \$(seq 1 10000); do echo \$i > /dev/null; done' &
    done
    sleep 10
  done
" &
LOAD_PID=$!

sleep 60
kill $HPA_PID $LOAD_PID 2>/dev/null

# Check scaling results
kubectl get hpa -n perf-test
kubectl get pods -n perf-test -l app=cpu-intensive
```

#### Debug Scenarios

**Debug 24.1: Performance Bottleneck Analysis (10 min)**
```bash
echo "=== Performance Bottleneck Analysis ==="

# Create resource-constrained scenario
kubectl patch deployment cpu-intensive-app -n perf-test -p '{"spec":{"template":{"spec":{"containers":[{"name":"cpu-load","resources":{"limits":{"cpu":"50m","memory":"32Mi"}}}]}}}}'

# Monitor resource constraints
kubectl top pods -n perf-test
kubectl describe pods -n perf-test -l app=cpu-intensive | grep -A5 "Limits:"

# Check for throttling
kubectl describe pods -n perf-test -l app=cpu-intensive | grep -A10 "State:"

# Analyze events for resource issues
kubectl get events -n perf-test --field-selector reason=FailedScheduling
kubectl get events -n perf-test --field-selector reason=Killing

# Fix resource constraints
kubectl patch deployment cpu-intensive-app -n perf-test -p '{"spec":{"template":{"spec":{"containers":[{"name":"cpu-load","resources":{"limits":{"cpu":"200m","memory":"128Mi"}}}]}}}}'

# Verify improvement
sleep 30
kubectl top pods -n perf-test -l app=cpu-intensive
```

**Debug 24.2: Scaling Issues (5 min)**
```bash
# Check HPA status and conditions
kubectl describe hpa cpu-intensive-hpa -n perf-test

# Check metrics server availability
kubectl top nodes
kubectl get pods -n kube-system | grep metrics

# Verify HPA can get metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods | head -20

# Check HPA events
kubectl get events -n perf-test --field-selector involvedObject.name=cpu-intensive-hpa
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 24 Cleanup
echo "=== Day 24 Cleanup ==="

kubectl delete namespace perf-test
rm -rf ~/cka-day24

echo "Day 24 cleanup complete"
```
---

### Day 25: Mock Exam 1 - Core Concepts & Workloads
**Time:** 60 minutes  
**Focus:** Timed exam simulation covering Weeks 1-2 topics

#### Task Summary
- Complete timed exam scenarios
- Practice under exam conditions
- Focus on core Kubernetes concepts
- Simulate real CKA exam pressure

#### Expected Outcome
- Experience exam-like conditions
- Identify knowledge gaps
- Build exam confidence

#### Setup Script
```bash
#!/bin/bash
# Day 25 Setup
echo "=== Day 25: Mock Exam 1 Setup ==="

mkdir -p ~/cka-day25 && cd ~/cka-day25

# Create exam namespace
kubectl create namespace exam-1

# Start timer
echo "MOCK EXAM 1 - 60 MINUTES"
echo "Start time: $(date)"
echo "You have 60 minutes to complete all tasks"
echo "Good luck!"

start_time=$(date +%s)
echo $start_time > start_time.txt
```

#### Mock Exam Tasks (50 minutes)

**Question 1: RBAC Configuration (8 minutes)**
```bash
# Task: Create a user 'developer' with specific permissions
# 1. Create certificate for user 'developer' in group 'dev-team'
# 2. Create Role allowing get,list,create on pods and services in namespace 'development'
# 3. Create RoleBinding connecting user to role
# 4. Create kubeconfig for the user
# 5. Test permissions

echo "=== Question 1: RBAC Configuration ==="
# Your solution here...

# Verification commands:
# kubectl auth can-i get pods --as=developer -n development
# kubectl auth can-i create secrets --as=developer -n development (should fail)
```

**Question 2: Pod Troubleshooting (7 minutes)**
```bash
# Task: Debug and fix the broken pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-pod
  namespace: exam-1
spec:
  containers:
  - name: app
    image: nginx:nonexistent-tag
    ports:
    - containerPort: 80
    env:
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: missing-config
          key: host
    resources:
      requests:
        cpu: 10
        memory: 20Gi
EOF

echo "=== Question 2: Pod Troubleshooting ==="
# Debug and fix all issues with the pod
# Your solution here...
```

**Question 3: Deployment and Service (10 minutes)**
```bash
echo "=== Question 3: Deployment and Service ==="
# Task: Create a deployment and expose it
# 1. Create deployment 'web-app' with 3 replicas using nginx:1.20
# 2. Set resource requests: cpu=100m, memory=128Mi
# 3. Set resource limits: cpu=200m, memory=256Mi
# 4. Add labels: app=web, tier=frontend
# 5. Create ClusterIP service exposing port 80
# 6. Create NodePort service exposing port 30080
# 7. Test connectivity

# Your solution here...
```

**Question 4: Persistent Storage (8 minutes)**
```bash
echo "=== Question 4: Persistent Storage ==="
# Task: Set up persistent storage
# 1. Create PersistentVolume 'exam-pv' with 2Gi capacity, ReadWriteOnce
# 2. Use hostPath: /tmp/exam-data
# 3. Create PersistentVolumeClaim 'exam-pvc' requesting 1Gi
# 4. Create pod using the PVC, mount at /data
# 5. Write test data to verify persistence

# Your solution here...
```

**Question 5: ConfigMap and Secret (7 minutes)**
```bash
echo "=== Question 5: ConfigMap and Secret ==="
# Task: Configuration management
# 1. Create ConfigMap 'app-config' with database.host=localhost, database.port=5432
# 2. Create Secret 'app-secret' with username=admin, password=secret123
# 3. Create pod that uses both as environment variables
# 4. Also mount the ConfigMap as volume at /config

# Your solution here...
```

**Question 6: Network Policy (10 minutes)**
```bash
echo "=== Question 6: Network Policy ==="
# Task: Implement network security
# 1. Create namespace 'frontend' and 'backend'
# 2. Deploy nginx pod in each namespace with label app=web
# 3. Create NetworkPolicy in backend namespace
# 4. Allow ingress only from frontend namespace on port 80
# 5. Allow egress to DNS (port 53)
# 6. Test connectivity

# Your solution here...
```

#### Time Check and Review (10 minutes)
```bash
# Check remaining time
end_time=$(date +%s)
start_time=$(cat start_time.txt)
elapsed=$((end_time - start_time))
remaining=$((3600 - elapsed))

echo "=== Time Check ==="
echo "Elapsed: $((elapsed / 60)) minutes"
echo "Remaining: $((remaining / 60)) minutes"

if [ $remaining -gt 0 ]; then
    echo "Use remaining time to review and verify your solutions"
else
    echo "Time's up! Review your solutions"
fi
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 25 Cleanup
echo "=== Day 25 Cleanup ==="

kubectl delete namespace exam-1 development frontend backend
kubectl delete pv exam-pv 2>/dev/null
rm -rf ~/cka-day25

echo "Mock Exam 1 complete. Review your performance and identify areas for improvement."
```

---

### Day 26: Mock Exam 2 - Operations & Troubleshooting
**Time:** 60 minutes  
**Focus:** Timed exam simulation covering Week 3 topics

#### Task Summary
- Advanced troubleshooting scenarios
- Operational procedures under time pressure
- Complex multi-component debugging
- Cluster maintenance tasks

#### Expected Outcome
- Master operational troubleshooting
- Handle complex scenarios efficiently
- Build advanced exam confidence

#### Setup Script
```bash
#!/bin/bash
# Day 26 Setup
echo "=== Day 26: Mock Exam 2 Setup ==="

mkdir -p ~/cka-day26 && cd ~/cka-day26

kubectl create namespace exam-2

echo "MOCK EXAM 2 - 60 MINUTES"
echo "Start time: $(date)"
start_time=$(date +%s)
echo $start_time > start_time.txt
```

#### Mock Exam Tasks (50 minutes)

**Question 1: Cluster Component Troubleshooting (12 minutes)**
```bash
echo "=== Question 1: Cluster Component Troubleshooting ==="
# Scenario: API server is responding slowly
# Task: Investigate and resolve cluster performance issues
# 1. Check cluster component health
# 2. Analyze resource usage on control plane
# 3. Check etcd health and performance
# 4. Identify bottlenecks and propose solutions
# 5. Verify cluster functionality

# Your investigation and solution here...
```

**Question 2: Node Maintenance (10 minutes)**
```bash
echo "=== Question 2: Node Maintenance ==="
# Task: Perform maintenance on worker node
# 1. Create deployment with 6 replicas across cluster
# 2. Safely drain cka-cluster-1-worker for maintenance
# 3. Verify workloads are rescheduled
# 4. Simulate maintenance completion
# 5. Return node to service
# 6. Verify even distribution of workloads

# Your solution here...
```

**Question 3: Backup and Restore (8 minutes)**
```bash
echo "=== Question 3: Backup and Restore ==="
# Task: Implement backup and recovery
# 1. Create etcd backup
# 2. Create test resources (namespace, configmap, secret)
# 3. Simulate data loss by deleting resources
# 4. Demonstrate restore process (conceptual for kind cluster)
# 5. Verify data recovery

# Your solution here...
```

**Question 4: Network Troubleshooting (10 minutes)**
```bash
echo "=== Question 4: Network Troubleshooting ==="
# Create broken network scenario
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: client-pod
  namespace: exam-2
spec:
  containers:
  - name: client
    image: busybox
    command: ['sleep', '3600']
---
apiVersion: v1
kind: Pod
metadata:
  name: server-pod
  namespace: exam-2
  labels:
    app: server
spec:
  containers:
  - name: server
    image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: server-service
  namespace: exam-2
spec:
  selector:
    app: wrong-label
  ports:
  - port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: exam-2
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Task: Debug and fix network connectivity issues
# 1. Identify why client cannot reach server
# 2. Fix service selector issue
# 3. Fix network policy blocking traffic
# 4. Verify connectivity works

# Your solution here...
```

**Question 5: Resource Management (10 minutes)**
```bash
echo "=== Question 5: Resource Management ==="
# Task: Implement resource governance
# 1. Create ResourceQuota limiting CPU to 2 cores, memory to 4Gi
# 2. Create LimitRange with default limits
# 3. Create deployment that exceeds quota
# 4. Debug and fix resource allocation
# 5. Implement HPA for automatic scaling

# Your solution here...
```

#### Time Check and Review (10 minutes)
```bash
end_time=$(date +%s)
start_time=$(cat start_time.txt)
elapsed=$((end_time - start_time))
remaining=$((3600 - elapsed))

echo "=== Mock Exam 2 Time Check ==="
echo "Elapsed: $((elapsed / 60)) minutes"
echo "Remaining: $((remaining / 60)) minutes"
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 26 Cleanup
echo "=== Day 26 Cleanup ==="

kubectl delete namespace exam-2
kubectl uncordon --all
rm -rf ~/cka-day26

echo "Mock Exam 2 complete."
```

---

### Day 27: Mock Exam 3 - Advanced Scenarios
**Time:** 60 minutes  
**Focus:** Complex multi-component scenarios and advanced topics

#### Task Summary
- Advanced Kubernetes scenarios
- Multi-step complex problems
- Integration of all concepts
- Exam-level difficulty

#### Expected Outcome
- Handle complex integrated scenarios
- Demonstrate mastery of all topics
- Final exam readiness validation

#### Setup Script
```bash
#!/bin/bash
# Day 27 Setup
echo "=== Day 27: Mock Exam 3 Setup ==="

mkdir -p ~/cka-day27 && cd ~/cka-day27
kubectl create namespace exam-3

echo "MOCK EXAM 3 - ADVANCED SCENARIOS - 60 MINUTES"
echo "Start time: $(date)"
start_time=$(date +%s)
echo $start_time > start_time.txt
```

#### Advanced Mock Exam (50 minutes)

**Scenario 1: Multi-Tier Application Deployment (15 minutes)**
```bash
echo "=== Scenario 1: Multi-Tier Application ==="
# Task: Deploy complete application stack
# 1. Create 3 namespaces: frontend, backend, database
# 2. Deploy StatefulSet postgres in database namespace
# 3. Deploy backend API deployment (3 replicas) in backend namespace
# 4. Deploy frontend web deployment (5 replicas) in frontend namespace
# 5. Create appropriate services for each tier
# 6. Implement network policies for security
# 7. Configure resource quotas and limits
# 8. Set up monitoring and logging
# 9. Test end-to-end connectivity

# Your comprehensive solution here...
```

**Scenario 2: Cluster Security Hardening (12 minutes)**
```bash
echo "=== Scenario 2: Security Hardening ==="
# Task: Implement comprehensive security
# 1. Create service account with minimal permissions
# 2. Implement pod security contexts
# 3. Create network policies for micro-segmentation
# 4. Set up RBAC for different user roles
# 5. Configure admission controllers simulation
# 6. Implement secrets management
# 7. Test security boundaries

# Your security implementation here...
```

**Scenario 3: Disaster Recovery Simulation (13 minutes)**
```bash
echo "=== Scenario 3: Disaster Recovery ==="
# Task: Complete disaster recovery procedure
# 1. Create production workloads with persistent data
# 2. Implement backup procedures
# 3. Simulate cluster failure
# 4. Perform recovery procedures
# 5. Validate data integrity
# 6. Test application functionality
# 7. Document recovery process

# Your disaster recovery solution here...
```

**Scenario 4: Performance Optimization (10 minutes)**
```bash
echo "=== Scenario 4: Performance Crisis ==="
# Task: Resolve performance emergency
# 1. Analyze cluster performance bottlenecks
# 2. Identify resource-starved applications
# 3. Implement horizontal pod autoscaling
# 4. Optimize resource allocation
# 5. Configure node affinity for performance
# 6. Monitor and validate improvements

# Your performance optimization here...
```

#### Final Review (10 minutes)
```bash
end_time=$(date +%s)
start_time=$(cat start_time.txt)
elapsed=$((end_time - start_time))

echo "=== Final Mock Exam Complete ==="
echo "Total time: $((elapsed / 60)) minutes"
echo "Congratulations on completing the advanced scenarios!"
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 27 Cleanup
echo "=== Day 27 Cleanup ==="

kubectl delete namespace exam-3 frontend backend database
rm -rf ~/cka-day27

echo "Advanced Mock Exam complete. You're ready for the real CKA!"
```

---

### Day 28: Exam Strategy & Time Management
**Time:** 60 minutes  
**Focus:** Exam techniques, time management, and final preparation

#### Task Summary
- Learn exam-specific strategies
- Practice time management techniques
- Review common pitfalls
- Final knowledge consolidation

#### Expected Outcome
- Master exam techniques
- Optimize time management
- Build final confidence

#### Exam Strategy Guide
```bash
#!/bin/bash
# Day 28: Exam Strategy Session

echo "=== CKA Exam Strategy & Tips ==="

cat > exam-strategy.md << 'EOF'
# CKA Exam Strategy Guide

## Time Management (Critical!)
- **Total Time**: 2 hours (120 minutes)
- **Questions**: ~15-20 questions
- **Average per question**: 6-8 minutes
- **Strategy**: Spend max 10 minutes per question, move on if stuck

## Question Prioritization
1. **Quick wins first** (2-3 minutes): kubectl commands, simple deployments
2. **Medium complexity** (5-8 minutes): RBAC, services, troubleshooting
3. **Complex scenarios last** (10-15 minutes): Multi-step problems

## Essential Commands to Memorize
```bash
# Quick resource creation
kubectl run pod-name --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment dep-name --image=nginx --replicas=3 --dry-run=client -o yaml > dep.yaml
kubectl expose deployment dep-name --port=80 --target-port=8080 --type=ClusterIP

# Fast troubleshooting
kubectl describe pod pod-name
kubectl logs pod-name -c container-name --previous
kubectl get events --sort-by='.lastTimestamp'
kubectl top nodes
kubectl top pods

# Quick edits
kubectl edit deployment dep-name
kubectl patch deployment dep-name -p '{"spec":{"replicas":5}}'
kubectl scale deployment dep-name --replicas=3

# RBAC shortcuts
kubectl create role role-name --verb=get,list --resource=pods
kubectl create rolebinding binding-name --role=role-name --user=user-name
kubectl auth can-i get pods --as=user-name

# Network debugging
kubectl exec -it pod-name -- nslookup service-name
kubectl exec -it pod-name -- wget -qO- service-name:port
```

## Common Pitfalls to Avoid
1. **Don't spend too long on one question**
2. **Always verify your solutions**
3. **Use --dry-run=client -o yaml for complex resources**
4. **Remember to apply your YAML files**
5. **Check namespaces carefully**
6. **Use kubectl explain for syntax help**

## Exam Environment Tips
- **Bookmarks**: Kubernetes.io documentation is allowed
- **Terminal**: Practice with vim/nano for YAML editing
- **Copy-paste**: Use carefully, check indentation
- **Multiple terminals**: Use tabs effectively

## Final Checklist
- [ ] Can create pods, deployments, services quickly
- [ ] Can troubleshoot failed pods and services
- [ ] Can implement RBAC and network policies
- [ ] Can perform backup/restore operations
- [ ] Can manage persistent volumes and claims
- [ ] Can configure monitoring and logging
- [ ] Can perform cluster maintenance tasks

## Stress Management
- Take deep breaths between questions
- Skip difficult questions and return later
- Focus on partial credit - some points better than none
- Stay calm and methodical
EOF

echo "Exam strategy guide created: exam-strategy.md"
```

#### Practice Session: Speed Drills (40 minutes)
```bash
echo "=== Speed Drill Practice ==="

# Drill 1: Quick Pod Creation (2 minutes)
echo "Drill 1: Create pod with nginx image, expose port 80, add label app=web"
time_start=$(date +%s)
# Your solution here (aim for under 2 minutes)
time_end=$(date +%s)
echo "Time taken: $((time_end - time_start)) seconds"

# Drill 2: Service Troubleshooting (3 minutes)
echo "Drill 2: Debug why service cannot reach pods"
kubectl create deployment broken-app --image=nginx --replicas=2
kubectl expose deployment broken-app --port=80 --target-port=8080
# Debug and fix the issue (port mismatch)

# Drill 3: RBAC Setup (4 minutes)
echo "Drill 3: Create user with read-only access to pods in specific namespace"
# Complete RBAC setup including certificate, role, and binding

# Drill 4: Resource Management (3 minutes)
echo "Drill 4: Create deployment with resource limits and HPA"
# Create deployment with proper resource configuration

# Continue with more drills...
```

#### Final Knowledge Check (20 minutes)
```bash
echo "=== Final Knowledge Verification ==="

# Quick fire questions - answer within 30 seconds each
echo "1. Command to drain a node for maintenance?"
echo "2. How to create a network policy denying all ingress?"
echo "3. Command to backup etcd?"
echo "4. How to check which user can perform an action?"
echo "5. Command to see resource usage of pods?"

# Verify answers and review any gaps
```

---

### Day 29: Final Review & Weak Areas
**Time:** 60 minutes  
**Focus:** Address knowledge gaps and final preparation

#### Task Summary
- Review all previous mock exams
- Focus on identified weak areas
- Practice difficult scenarios
- Final confidence building

#### Expected Outcome
- Address all knowledge gaps
- Strengthen weak areas
- Final readiness confirmation

#### Comprehensive Review Session
```bash
#!/bin/bash
# Day 29: Final Review

echo "=== Final Review Session ==="

# Review checklist based on CKA curriculum
cat > final-checklist.md << 'EOF'
# CKA Final Review Checklist

## Cluster Architecture (25%)
- [ ] Manage role-based access control (RBAC)
- [ ] Use Kubeadm to install a basic cluster
- [ ] Manage a highly-available Kubernetes cluster
- [ ] Provision underlying infrastructure to deploy a Kubernetes cluster
- [ ] Perform a version upgrade on a Kubernetes cluster using Kubeadm
- [ ] Implement etcd backup and restore

## Workloads & Scheduling (15%)
- [ ] Understand deployments and how to perform rolling update and rollbacks
- [ ] Use ConfigMaps and Secrets to configure applications
- [ ] Know how to scale applications
- [ ] Understand the primitives used to create robust, self-healing, application deployments
- [ ] Understand how resource limits can affect Pod scheduling
- [ ] Awareness of manifest management and common templating tools

## Services & Networking (20%)
- [ ] Understand host networking configuration on the cluster nodes
- [ ] Understand connectivity between Pods
- [ ] Understand ClusterIP, NodePort, LoadBalancer service types and endpoints
- [ ] Know how to use Ingress controllers and Ingress resources
- [ ] Know how to configure and use CoreDNS
- [ ] Choose an appropriate container network interface plugin

## Storage (10%)
- [ ] Understand storage classes, persistent volumes
- [ ] Understand volume mode, access modes and reclaim policies for volumes
- [ ] Understand persistent volume claims primitive
- [ ] Know how to configure applications with persistent storage

## Troubleshooting (30%)
- [ ] Evaluate cluster and node logging
- [ ] Understand how to monitor applications
- [ ] Manage container stdout & stderr logs
- [ ] Troubleshoot application failure
- [ ] Troubleshoot cluster component failure
- [ ] Troubleshoot networking
EOF

echo "Review checklist created. Go through each item and practice weak areas."
```

#### Targeted Practice (45 minutes)
```bash
# Focus on your weakest areas from previous mock exams
echo "=== Targeted Practice Session ==="

# Example: If networking was weak, practice these scenarios
echo "Network Troubleshooting Practice:"
# 1. Pod cannot reach service
# 2. DNS resolution failing
# 3. Network policy blocking traffic
# 4. Service selector mismatch

# Example: If RBAC was weak, practice these scenarios
echo "RBAC Practice:"
# 1. Create user with specific permissions
# 2. Debug permission denied errors
# 3. Service account configuration
# 4. ClusterRole vs Role differences

# Continue with other weak areas...
```

#### Final Confidence Builder (15 minutes)
```bash
echo "=== Final Confidence Session ==="
echo "You have completed:"
echo "✅ 30 days of intensive CKA preparation"
echo "✅ 3 comprehensive mock exams"
echo "✅ 100+ hands-on scenarios"
echo "✅ Advanced troubleshooting practice"
echo "✅ Real-world operational experience"
echo ""
echo "You are ready for the CKA exam!"
```

---

### Day 30: Exam Day Preparation & Final Tips
**Time:** 60 minutes  
**Focus:** Final exam preparation and last-minute tips

#### Task Summary
- Final system check and preparation
- Last-minute review of key concepts
- Exam day logistics and mindset
- Confidence building and motivation

#### Expected Outcome
- Complete exam readiness
- Calm and confident mindset
- Clear exam day strategy

#### Final Preparation Session
```bash
#!/bin/bash
# Day 30: Exam Day Preparation

echo "=== CKA Exam Day Preparation ==="
echo "Congratulations! You've completed 30 days of intensive CKA preparation!"

cat > exam-day-guide.md << 'EOF'
# CKA Exam Day Guide

## Pre-Exam Checklist (Day Before)
- [ ] Confirm exam date, time, and timezone
- [ ] Test your computer and internet connection
- [ ] Clear your workspace (only water and ID allowed)
- [ ] Get good night's sleep (8+ hours)
- [ ] Prepare healthy snacks for after exam

## Exam Day Morning
- [ ] Light breakfast (avoid heavy meals)
- [ ] Arrive 30 minutes early for check-in
- [ ] Have government-issued ID ready
- [ ] Ensure quiet, private room
- [ ] Close all applications except browser

## During the Exam
- [ ] Read each question carefully twice
- [ ] Use kubectl explain for syntax help
- [ ] Verify your solutions before moving on
- [ ] Skip difficult questions and return later
- [ ] Watch the clock but don't panic
- [ ] Use bookmarks for quick documentation access

## Key Commands for Exam Day
```bash
# Quick reference - practice these until automatic
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment web --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml
kubectl expose deployment web --port=80 --target-port=8080 --type=ClusterIP
kubectl create service nodeport web --tcp=80:8080 --node-port=30080

# Troubleshooting essentials
kubectl describe pod <pod-name>
kubectl logs <pod-name> -c <container-name> --previous
kubectl get events --sort-by='.lastTimestamp'
kubectl top nodes && kubectl top pods

# RBAC quick setup
kubectl create role <role-name> --verb=get,list,create --resource=pods,services
kubectl create rolebinding <binding-name> --role=<role-name> --user=<user-name>
kubectl auth can-i <verb> <resource> --as=<user-name> -n <namespace>

# Network debugging
kubectl exec -it <pod-name> -- nslookup <service-name>
kubectl exec -it <pod-name> -- wget -qO- <service-name>:<port>
kubectl get networkpolicy -A
```

## Mindset and Strategy
- **Stay calm**: You've practiced extensively
- **Be methodical**: Follow your practiced approach
- **Manage time**: Don't get stuck on one question
- **Partial credit**: Some points are better than none
- **Trust your preparation**: You know this material

## Common Exam Scenarios
1. **Pod not starting**: Check image, resources, node capacity
2. **Service not working**: Verify selectors, endpoints, ports
3. **RBAC issues**: Check roles, bindings, and permissions
4. **Network problems**: Test connectivity, check policies
5. **Storage issues**: Verify PV/PVC binding and mount paths

## Final Reminders
- You've completed 30 days of intensive preparation
- You've solved 100+ real-world scenarios
- You've practiced under exam conditions
- You understand both theory and practical application
- You're ready to pass the CKA exam!

## After the Exam
- Results typically available within 24 hours
- Certificate valid for 3 years
- Celebrate your achievement!
EOF

echo "Exam day guide created: exam-day-guide.md"
```

#### Final System Verification
```bash
echo "=== Final System Check ==="

# Verify all key skills one last time
echo "Testing core competencies..."

# 1. Quick pod creation
kubectl run test-pod --image=nginx --rm -it --restart=Never -- echo "Pod creation: ✅"

# 2. Service creation and testing
kubectl create deployment final-test --image=nginx --replicas=2
kubectl expose deployment final-test --port=80
kubectl get svc final-test && echo "Service creation: ✅"

# 3. RBAC verification
kubectl auth can-i get pods && echo "RBAC understanding: ✅"

# 4. Resource management
kubectl top nodes >/dev/null 2>&1 && echo "Resource monitoring: ✅"

# 5. Troubleshooting tools
kubectl get events --sort-by='.lastTimestamp' | head -5 >/dev/null && echo "Troubleshooting: ✅"

# Cleanup
kubectl delete deployment final-test
kubectl delete service final-test

echo ""
echo "🎉 CONGRATULATIONS! 🎉"
echo "You have successfully completed the 30-Day CKA Master Preparation Guide!"
echo ""
echo "📊 Your Journey:"
echo "   ✅ 30 days of intensive training"
echo "   ✅ 4 weeks of progressive learning"
echo "   ✅ 100+ hands-on scenarios"
echo "   ✅ 3 comprehensive mock exams"
echo "   ✅ Advanced troubleshooting skills"
echo "   ✅ Real-world operational experience"
echo ""
echo "🚀 You are now ready to:"
echo "   • Pass the CKA exam with confidence"
echo "   • Manage production Kubernetes clusters"
echo "   • Troubleshoot complex issues"
echo "   • Implement best practices"
echo "   • Lead Kubernetes initiatives"
echo ""
echo "💪 Final Words:"
echo "   Trust your preparation. You've put in the work."
echo "   Stay calm during the exam. You know this material."
echo "   Remember: You're not just taking an exam, you're demonstrating mastery."
echo ""
echo "🏆 Good luck on your CKA exam!"
echo "   You've got this! 💪"
```

#### Cleanup Script
```bash
#!/bin/bash
# Day 30 Final Cleanup
echo "=== Final Cleanup ==="

# Keep the guides for exam day reference
echo "Keeping exam-day-guide.md and exam-strategy.md for reference"
echo "All other temporary resources cleaned up"

echo ""
echo "🎓 30-Day CKA Master Preparation Guide Complete!"
echo "📚 Study materials preserved in ~/dev/k8s_cka/"
echo "🚀 You're ready for the CKA exam!"
```

---

## 🏆 30-Day Journey Complete!

### 📈 **What You've Accomplished:**

**Week 1: Foundation Mastery**
- Cluster architecture and certificates
- RBAC and security contexts
- Pod lifecycle and troubleshooting
- Services and networking
- Persistent storage
- Configuration management

**Week 2: Workload Expertise**
- Deployments and rolling updates
- StatefulSets and persistent workloads
- DaemonSets and node management
- Jobs and CronJobs
- Resource management and scheduling
- Advanced scheduling with taints and affinity

**Week 3: Operational Excellence**
- Cluster monitoring and metrics
- Logging and log analysis
- System troubleshooting and debugging
- Network policies and security
- Backup and restore operations
- Cluster maintenance and upgrades

**Week 4: Advanced Mastery**
- Advanced networking and CNI
- Custom resources and operators
- Performance tuning and optimization
- Three comprehensive mock exams
- Exam strategy and time management
- Final preparation and confidence building

### 🎯 **Skills Gained:**
- ✅ **Cluster Administration**: Complete cluster lifecycle management
- ✅ **Workload Management**: All Kubernetes workload types and patterns
- ✅ **Troubleshooting**: Advanced debugging and problem resolution
- ✅ **Security**: RBAC, network policies, and security best practices
- ✅ **Operations**: Monitoring, logging, backup, and maintenance
- ✅ **Performance**: Optimization and resource management
- ✅ **Exam Readiness**: Strategy, time management, and confidence

### 🚀 **You're Now Ready To:**
- Pass the CKA exam with confidence
- Manage production Kubernetes clusters
- Lead Kubernetes initiatives in your organization
- Troubleshoot complex multi-component issues
- Implement Kubernetes best practices
- Mentor others in Kubernetes administration

### 📊 **By the Numbers:**
- **30 days** of intensive preparation
- **100+ scenarios** practiced
- **50+ debugging exercises** completed
- **3 mock exams** under real conditions
- **All CKA domains** thoroughly covered
- **Real-world experience** gained

**🏆 Congratulations on completing this comprehensive journey! You're now a Kubernetes expert ready to excel in the CKA exam and beyond!**
