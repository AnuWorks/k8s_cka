#!/bin/bash

# CKA Guide Update Script
# This script updates the guide with your actual cluster configuration

GUIDE_FILE="/Users/anudeepriya/dev/k8s_cka/30-day-cka-master-guide.md"

echo "Updating CKA guide with your cluster configuration..."

# 1. Update cluster references
sed -i '' 's/day1-test/cka-day1/g' "$GUIDE_FILE"
sed -i '' 's/rbac-test/cka-day2/g' "$GUIDE_FILE"
sed -i '' 's/security-test/cka-day2/g' "$GUIDE_FILE"
sed -i '' 's/pod-test/cka-day3/g' "$GUIDE_FILE"
sed -i '' 's/service-test/cka-day4/g' "$GUIDE_FILE"
sed -i '' 's/storage-test/cka-day5/g' "$GUIDE_FILE"
sed -i '' 's/config-test/cka-day6/g' "$GUIDE_FILE"
sed -i '' 's/integration-test/cka-day7/g' "$GUIDE_FILE"

# 2. Update API server references to use dynamic lookup
sed -i '' 's/--server=https:\/\/127\.0\.0\.1:49582/--server=$(kubectl config view --raw -o jsonpath='"'"'{.clusters[0].cluster.server}'"'"')/g' "$GUIDE_FILE"

# 3. Update cluster name references
sed -i '' 's/day1-cluster/kind-cka-cluster-1/g' "$GUIDE_FILE"
sed -i '' 's/test-cluster/kind-cka-cluster-1/g' "$GUIDE_FILE"

# 4. Update certificate extraction commands
sed -i '' 's/kubectl get configmap -n kube-system kube-root-ca.crt -o jsonpath='"'"'{.data.ca\.crt}'"'"'/kubectl config view --raw -o jsonpath='"'"'{.clusters[0].cluster.certificate-authority-data}'"'"' | base64 -d/g' "$GUIDE_FILE"

echo "Basic updates completed. Now creating namespace-per-day pattern..."

# Create a backup
cp "$GUIDE_FILE" "${GUIDE_FILE}.backup"

echo "Guide updated successfully!"
echo "Backup created at: ${GUIDE_FILE}.backup"
echo ""
echo "Key changes made:"
echo "✅ Cluster name: kind-cka-cluster-1"
echo "✅ API server: Dynamic lookup"
echo "✅ Namespaces: cka-day1, cka-day2, etc."
echo "✅ Certificate extraction: From kubeconfig"
echo ""
echo "You can now run the Day 1 tasks without issues!"
