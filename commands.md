# Expose a service
kubectl expose deploy myapp-deploy \
  --name=myapp-svc \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP

# Check rollout history 
kubectl rollout history deployment nginx-deploy

# Update image of deployment
kubectl set image deploy/nginx-deploy nginx-container=nginx:1.23.4

# Annotate a deployment with cause code
kubectl annotate deploy/nginx-deploy \
  kubernetes.io/change-cause="PATCH: nginx 1.23.3 → 1.23.4" \
  --overwrite

# Rollback deployment
kubectl rollout undo deploy nginx-deploy --to-revision=1