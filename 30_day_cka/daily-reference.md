# CKA Daily Practice Quick Reference

## Your Cluster Configuration
- **Cluster Name:** kind-cka-cluster-1
- **API Server:** https://127.0.0.1:49582
- **Nodes:** 
  - cka-cluster-1-control-plane (control-plane)
  - cka-cluster-1-worker (worker)
  - cka-cluster-1-worker2 (worker)
- **Kubernetes Version:** v1.35.0

## Daily Namespace Pattern
Each day uses its own namespace for isolation:
- Day 1: `cka-day1`
- Day 2: `cka-day2`
- Day 3: `cka-day3`
- ... and so on

## Quick Commands for Each Day

### Setup Pattern (for any day)
```bash
# Create working directory and namespace
mkdir -p ~/cka-dayX && cd ~/cka-dayX
kubectl create namespace cka-dayX --dry-run=client -o yaml | kubectl apply -f -
```

### Cleanup Pattern (for any day)
```bash
# Clean up everything for the day
kubectl delete namespace cka-dayX
rm -rf ~/cka-dayX
```

### Get Cluster Info
```bash
# Your actual cluster details
kubectl config get-contexts
kubectl config view --minify
kubectl get nodes -o wide

# Dynamic API server lookup
CLUSTER_SERVER=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.server}')
echo $CLUSTER_SERVER
```

### Certificate Operations
```bash
# Extract CA certificate from your cluster
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt

# Get CA key from kind cluster
docker exec -it cka-cluster-1-control-plane cat /etc/kubernetes/pki/ca.key > ca.key
```

## Useful Aliases
Add these to your ~/.bashrc or ~/.zshrc:
```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
```

## Daily Progress Tracking
- [ ] Day 1: Cluster Architecture & Certificates
- [ ] Day 2: RBAC & Security Contexts
- [ ] Day 3: Pod Lifecycle & Troubleshooting
- [ ] Day 4: Services & Networking
- [ ] Day 5: Persistent Volumes & Storage
- [ ] Day 6: ConfigMaps & Secrets
- [ ] Day 7: Week 1 Integration Review
- [ ] ... (continue for all 30 days)

## Emergency Commands
```bash
# If something goes wrong, clean up all CKA namespaces
kubectl get ns | grep cka-day | awk '{print $1}' | xargs kubectl delete ns

# Reset to clean state
kubectl config use-context kind-cka-cluster-1
kubectl config set-context --current --namespace=default
```

## Tips for Success
1. **Always use the correct namespace** for each day
2. **Clean up after each day** to avoid resource conflicts
3. **Take notes** on what you learn each day
4. **Practice commands** until they become muscle memory
5. **Time yourself** on complex scenarios to build exam speed
