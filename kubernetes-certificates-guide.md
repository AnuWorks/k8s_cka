# Kubernetes Certificates Mastery Guide
**Cluster:** cka-cluster-1 (Kind cluster with 1 control-plane + 2 workers)  
**API Server:** https://127.0.0.1:49582  
**Duration:** 30-40 minutes

---

## Part 1: Theory & Cluster Overview (10 minutes)

### Your Cluster Setup
- **Control Plane:** cka-cluster-1-control-plane
- **Workers:** cka-cluster-1-worker, cka-cluster-1-worker2
- **API Endpoint:** 127.0.0.1:49582
- **Available Namespaces:** default, dev, kube-system, kube-public, kube-node-lease, local-path-storage

### Certificate Architecture in Your Kind Cluster
```
┌─────────────────┐    ┌──────────────────────────┐    ┌─────────────────────┐
│   kubectl       │    │   API Server             │    │   kubelet           │
│   (Your Mac)    │    │   (control-plane)        │    │   (worker nodes)    │
│                 │    │                          │    │                     │
│ Client Cert ────┼────┤ Server Cert (localhost)  │    │ Client Cert ────────┤
│ CA Bundle       │    │ Client CA Validation     │    │ CA Bundle           │
└─────────────────┘    │ Kubelet CA Validation    │    └─────────────────────┘
                       └──────────────────────────┘
                               │
                       ┌──────────────────────────┐
                       │   etcd                   │
                       │   (control-plane)        │
                       │ Server Cert              │
                       │ Client Cert              │
                       └──────────────────────────┘
```

### Certificate Types in Your Cluster
1. **CA Certificates** - Root of trust for cka-cluster-1
2. **API Server Certificate** - Serves HTTPS on 127.0.0.1:49582
3. **Client Certificates** - Your kubectl authentication
4. **Node Certificates** - kubelet on worker nodes
5. **Service Account Tokens** - Pod authentication

---

## Part 2: Hands-On Tasks (20 minutes)

### Task 1: Examine Your Cluster's Certificates (5 min)

```bash
# Check your cluster's API server certificate
echo | openssl s_client -connect 127.0.0.1:49582 2>/dev/null | openssl x509 -text -noout | grep -A5 "Subject:"

# Check your client certificate from kubeconfig
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d | openssl x509 -text -noout | grep -A3 "Subject:"

# Get cluster CA certificate
kubectl get configmap -n kube-system kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' > ca.crt

# Examine CA certificate
openssl x509 -in ca.crt -text -noout | grep -A5 "Subject:"
```

**Expected Output Analysis:**
- API Server Subject: Should include localhost, 127.0.0.1
- Client Subject: Should show your user identity
- CA Subject: Root certificate authority for cka-cluster-1

### Task 2: Access Kind Container Certificates (5 min)

```bash
# List all certificates in your kind control-plane
docker exec -it cka-cluster-1-control-plane ls -la /etc/kubernetes/pki/

# Check API server certificate expiry
docker exec -it cka-cluster-1-control-plane openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates

# Check CA certificate expiry
docker exec -it cka-cluster-1-control-plane openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -dates

# Get CA private key (only possible in kind/dev environments)
docker exec -it cka-cluster-1-control-plane cat /etc/kubernetes/pki/ca.key > ca.key
docker exec -it cka-cluster-1-control-plane cat /etc/kubernetes/pki/ca.crt > ca.crt
```

### Task 3: Create Custom User Certificate (8 min)

```bash
# 1. Generate private key for new developer user
openssl genrsa -out developer.key 2048

# 2. Create certificate signing request
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer/O=development"

# 3. Sign certificate with cluster CA (using kind's CA)
openssl x509 -req -in developer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out developer.crt -days 365

# 4. Verify the certificate
openssl x509 -in developer.crt -text -noout | grep -A3 "Subject:"

# 5. Create kubeconfig for developer
kubectl config set-cluster cka-cluster-1 --server=https://127.0.0.1:49582 --certificate-authority=ca.crt --kubeconfig=developer.kubeconfig

kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key --kubeconfig=developer.kubeconfig

kubectl config set-context developer-context --cluster=cka-cluster-1 --user=developer --kubeconfig=developer.kubeconfig

kubectl config use-context developer-context --kubeconfig=developer.kubeconfig

# 6. Test new certificate (should fail - no RBAC permissions)
kubectl --kubeconfig=developer.kubeconfig get pods
```

### Task 4: Service Account Tokens in Your Cluster (2 min)

```bash
# Create service account in dev namespace
kubectl create serviceaccount my-app -n dev

# Generate token for service account (K8s 1.24+)
kubectl create token my-app -n dev

# Create pod using service account in dev namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: dev
spec:
  serviceAccountName: my-app
  containers:
  - name: test
    image: nginx
    command: ['sleep', '3600']
EOF

# Check mounted token in pod
kubectl exec -n dev test-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | head -c 50
```

---

## Part 3: Advanced Certificate Operations (10 minutes)

### Certificate Locations in Your Kind Cluster
```bash
# View all certificate files
docker exec -it cka-cluster-1-control-plane find /etc/kubernetes/pki/ -name "*.crt" -o -name "*.key" | sort

# Expected structure:
# /etc/kubernetes/pki/
# ├── ca.crt, ca.key                 # Cluster CA
# ├── apiserver.crt, apiserver.key   # API server (serves 127.0.0.1:49582)
# ├── apiserver-kubelet-client.crt   # API server → kubelet communication
# ├── front-proxy-ca.crt             # Front proxy CA
# ├── etcd/
# │   ├── ca.crt, ca.key            # etcd CA
# │   ├── server.crt, server.key    # etcd server
# │   └── peer.crt, peer.key        # etcd peer communication
```

### Certificate Validation Commands
```bash
# Verify certificate chain
openssl verify -CAfile ca.crt developer.crt

# Check certificate details
openssl x509 -in developer.crt -text -noout

# Test TLS connection to API server
openssl s_client -connect 127.0.0.1:49582 -servername kubernetes -CAfile ca.crt

# Check certificate expiry for all cluster components
docker exec -it cka-cluster-1-control-plane bash -c "
for cert in /etc/kubernetes/pki/*.crt; do
  echo \"=== \$(basename \$cert) ===\"
  openssl x509 -in \$cert -noout -dates
done"
```

### RBAC Setup for Developer User
```bash
# Create role for developer in dev namespace
kubectl create role developer-role --verb=get,list,watch --resource=pods,services -n dev

# Bind role to developer user
kubectl create rolebinding developer-binding --role=developer-role --user=developer -n dev

# Test developer access (should work now)
kubectl --kubeconfig=developer.kubeconfig get pods -n dev
kubectl --kubeconfig=developer.kubeconfig get pods -n default  # Should fail
```

### Certificate Rotation Simulation
```bash
# Create new certificate with shorter validity (1 day)
openssl x509 -req -in developer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out developer-short.crt -days 1

# Update kubeconfig with new certificate
kubectl config set-credentials developer --client-certificate=developer-short.crt --client-key=developer.key --kubeconfig=developer.kubeconfig

# Test access
kubectl --kubeconfig=developer.kubeconfig get pods -n dev
```

---

## Part 4: Troubleshooting & Monitoring

### Common Certificate Issues
```bash
# 1. Certificate expired
openssl x509 -in cert.crt -noout -checkend 86400  # Check if expires in 24h

# 2. Wrong certificate for hostname
openssl x509 -in apiserver.crt -noout -text | grep -A5 "Subject Alternative Name"

# 3. Certificate chain validation
openssl verify -CAfile ca.crt -untrusted intermediate.crt end-entity.crt

# 4. Check certificate usage
openssl x509 -in cert.crt -noout -text | grep -A5 "Key Usage"
```

### Monitoring Certificate Expiry
```bash
# Create script to check all certificates
cat > check-certs.sh << 'EOF'
#!/bin/bash
echo "=== Cluster Certificate Expiry Check ==="
docker exec -it cka-cluster-1-control-plane bash -c "
for cert in /etc/kubernetes/pki/*.crt /etc/kubernetes/pki/etcd/*.crt; do
  if [[ -f \$cert ]]; then
    echo \"Certificate: \$(basename \$cert)\"
    openssl x509 -in \$cert -noout -dates | grep 'notAfter'
    echo \"---\"
  fi
done"
EOF

chmod +x check-certs.sh
./check-certs.sh
```

---

## Quick Reference Commands

### Essential Certificate Commands
```bash
# View cluster info
kubectl cluster-info

# Get CA certificate
kubectl get configmap -n kube-system kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' > ca.crt

# Check certificate expiry
openssl x509 -in cert.crt -noout -dates

# Verify certificate
openssl verify -CAfile ca.crt cert.crt

# Create CSR
openssl req -new -key private.key -out request.csr -subj "/CN=username/O=group"

# Sign certificate
openssl x509 -req -in request.csr -CA ca.crt -CAkey ca.key -out cert.crt -days 365

# Test TLS connection
openssl s_client -connect 127.0.0.1:49582 -servername kubernetes
```

### Kind-Specific Commands
```bash
# Access kind container
docker exec -it cka-cluster-1-control-plane bash

# List all certificates
docker exec -it cka-cluster-1-control-plane ls -la /etc/kubernetes/pki/

# Copy certificate from container
docker cp cka-cluster-1-control-plane:/etc/kubernetes/pki/ca.crt ./ca.crt
```

---

## Security Best Practices

1. **Certificate Validity Period**
   - CA certificates: 10 years
   - Server certificates: 1 year
   - Client certificates: 1 year or less

2. **Key Management**
   - Keep private keys secure
   - Use strong key sizes (2048+ bits for RSA)
   - Rotate certificates before expiry

3. **Access Control**
   - Limit certificate access
   - Use RBAC with certificates
   - Monitor certificate usage

4. **Monitoring**
   - Set up certificate expiry alerts
   - Regular certificate audits
   - Automated renewal processes

---

## Next Steps for CKA Preparation

1. **Practice certificate troubleshooting scenarios**
2. **Set up certificate monitoring with Prometheus**
3. **Implement automated certificate rotation**
4. **Study certificate-related CKA exam topics**
5. **Practice with cert-manager for automatic certificate management**

---

## Files Created in This Session
- `ca.crt` - Cluster CA certificate
- `ca.key` - Cluster CA private key (kind only)
- `developer.key` - Developer private key
- `developer.csr` - Developer certificate signing request
- `developer.crt` - Developer signed certificate
- `developer.kubeconfig` - Developer kubeconfig file
- `check-certs.sh` - Certificate monitoring script

**Completion Time: 30-40 minutes**  
**Cluster Used: cka-cluster-1 (Kind)**  
**Status: Ready for CKA certificate management questions!**
