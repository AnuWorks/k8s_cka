# Kind

## Create cluster
kind create cluster --name cka-cluster-1 --config config.yaml

# K8S

## Expose a service
kubectl expose deploy myapp-deploy \
  --name=myapp-svc \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP

## Check rollout history 
kubectl rollout history deployment nginx-deploy

## Update image of deployment
kubectl set image deploy/nginx-deploy nginx-container=nginx:1.23.4

## Annotate a deployment with cause code
kubectl annotate deploy/nginx-deploy \
  kubernetes.io/change-cause="PATCH: nginx 1.23.3 → 1.23.4" \
  --overwrite

## Rollback deployment
kubectl rollout undo deploy nginx-deploy --to-revision=1

## Default DNS resolver on pod
cat /etc/resolv.conf

## Scaling commands
### use against files with name scaling
kubectl autoscale deployment php-apache --cpu=50 --min=1 --max=10

kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

kubectl get hpa php-apache --watch

kubectl autoscale deployment php-apache --cpu=50 --min=1 --max=10