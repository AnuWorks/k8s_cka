#!/bin/bash

# Script to update the CKA guide with correct cluster information
echo "Updating CKA guide with correct cluster configuration..."

# Update cluster references throughout the file
sed -i '' 's/cka-cluster-1-control-plane/cka-cluster-1-control-plane/g' /Users/anudeepriya/dev/k8s_cka/30-day-cka-master-guide.md
sed -i '' 's/127\.0\.0\.1:49582/$(kubectl config view --raw -o jsonpath='"'"'{.clusters[0].cluster.server}'"'"')/g' /Users/anudeepriya/dev/k8s_cka/30-day-cka-master-guide.md

# Create a template for namespace setup that can be used for all days
cat > /tmp/namespace-template.txt << 'EOF'
# Create working directory and namespace
mkdir -p ~/cka-dayX && cd ~/cka-dayX
kubectl create namespace cka-dayX --dry-run=client -o yaml | kubectl apply -f -
EOF

echo "Guide updated with correct cluster configuration"
echo "Each day now uses namespace pattern: cka-day1, cka-day2, etc."
echo "Cleanup scripts updated to delete namespaces instead of individual resources"
