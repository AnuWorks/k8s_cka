# Kubernetes Certificates Mastery - 30-40 Min Learning Path

## Learning Structure
Theory (10 min) → Hands-on Tasks (20 min) → Advanced Concepts (10 min)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## Part 1: Core Theory (10 minutes)

### What Are K8s Certificates?
Kubernetes uses certificates for mutual TLS authentication between all components. Every component needs to prove its identity.

### Certificate Architecture Diagram
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   kubectl       │    │   API Server     │    │   kubelet       │
│                 │    │                  │    │                 │
│ Client Cert ────┼────┤ Server Cert      │    │ Client Cert ────┤
│ CA Bundle       │    │ Client CA        │    │ CA Bundle       │
└─────────────────┘    │ Kubelet CA       │    └─────────────────┘
                       └──────────────────┘
                               │
                       ┌──────────────────┐
                       │   etcd           │
                       │ Server Cert      │
                       │ Client Cert      │
                       └──────────────────┘


### Key Certificate Types
1. CA Certificates - Root of trust
2. Server Certificates - API server, etcd, kubelet
3. Client Certificates - kubectl, kubelet → API server
4. Service Account Tokens - Pod authentication

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## Part 2: Hands-On Tasks (20 minutes)

### Task 1: Examine Your Cluster's Certificates (5 min)

bash
# Check API server certificate
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d | openssl x509 -text -noout

# Check your client certificate
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d | openssl x509 -text -noout


What to look for:
- Issuer (CA)
- Subject (who the cert belongs to)
- Validity dates
- Key usage

### Task 2: Create a Custom Certificate for a User (8 min)

bash
# 1. Generate private key
openssl genrsa -out developer.key 2048

# 2. Create certificate signing request
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer/O=development"

# 3. Sign with cluster CA (get CA from your cluster)
kubectl get configmap -n kube-system cluster-info -o jsonpath='{.data.ca\.crt}' > ca.crt
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt

# 4. Create CertificateSigningRequest in K8s
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: developer-csr
spec:
  request: $(cat developer.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# 5. Approve the CSR
kubectl certificate approve developer-csr

# 6. Get the signed certificate
kubectl get csr developer-csr -o jsonpath='{.status.certificate}' | base64 -d > developer.crt


### Task 3: Create kubeconfig with New Certificate (4 min)

bash
# Create new kubeconfig
kubectl config set-cluster my-cluster --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=ca.crt --kubeconfig=developer.kubeconfig

kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key --kubeconfig=developer.kubeconfig

kubectl config set-context developer-context --cluster=my-cluster --user=developer --kubeconfig=developer.kubeconfig

kubectl config use-context developer-context --kubeconfig=developer.kubeconfig

# Test (should fail - no permissions yet)
kubectl --kubeconfig=developer.kubeconfig get pods


### Task 4: Service Account Tokens (3 min)

bash
# Create service account
kubectl create serviceaccount my-app

# Get the token (K8s 1.24+)
kubectl create token my-app

# Create a pod that uses this SA
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  serviceAccountName: my-app
  containers:
  - name: test
    image: nginx
    command: ['sleep', '3600']
EOF

# Check mounted token in pod
kubectl exec test-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## Part 3: Advanced Concepts (10 minutes)

### Certificate Rotation
bash
# Check certificate expiry
kubeadm certs check-expiration

# Renew certificates (if using kubeadm)
kubeadm certs renew all


### Certificate Locations (Standard K8s)
/etc/kubernetes/pki/
├── ca.crt, ca.key                 # Cluster CA
├── apiserver.crt, apiserver.key   # API server
├── apiserver-kubelet-client.crt   # API server → kubelet
├── front-proxy-ca.crt             # Front proxy CA
├── etcd/
│   ├── ca.crt, ca.key            # etcd CA
│   ├── server.crt, server.key    # etcd server
│   └── peer.crt, peer.key        # etcd peer


### Security Best Practices
1. Rotate certificates regularly (before expiry)
2. Use separate CAs for different components
3. Limit certificate validity (1 year max)
4. Monitor certificate expiry
5. Use RBAC with certificates

### Common Certificate Issues & Debugging
bash
# Check if certificate is valid
openssl x509 -in cert.crt -text -noout

# Verify certificate chain
openssl verify -CAfile ca.crt cert.crt

# Check certificate expiry
openssl x509 -in cert.crt -noout -dates

# Debug TLS connection
openssl s_client -connect api-server:6443 -servername kubernetes


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## Quick Reference Commands
bash
# View cluster certificates
kubectl config view --raw

# Check CSRs
kubectl get csr

# Create token for SA
kubectl create token <service-account>

# Check certificate expiry (kubeadm)
kubeadm certs check-expiration