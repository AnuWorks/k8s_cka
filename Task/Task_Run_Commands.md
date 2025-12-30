## Commands ran for task
 kubectl apply -f deployment.yaml 
deployment.apps/nginx-deploy created
➜  k8s_cka git:(master) ✗ kubectl delete deploy nginx-deploy
deployment.apps "nginx-deploy" deleted from default namespace
➜  k8s_cka git:(master) ✗ kubectl apply -f Task/myapp-deployment.yaml
error: the path "Task/myapp-deployment.yaml" does not exist
➜  k8s_cka git:(master) ✗ k apply -f Task/myapp-deployment.yaml
error: the path "Task/myapp-deployment.yaml" does not exist
➜  k8s_cka git:(master) ✗ k apply -f /Task/myapp-deployment.yaml
error: the path "/Task/myapp-deployment.yaml" does not exist
➜  k8s_cka git:(master) ✗ kubectl apply -f Task/myapp-deploy.yaml    
deployment.apps/myapp-deploy created
➜  k8s_cka git:(master) ✗ clear
➜  k8s_cka git:(master) ✗ kubectl scale --replicas=2 deploy myapp-deploy         
deployment.apps/myapp-deploy scaled
➜  k8s_cka git:(master) ✗ k apply -f Task/busybox-pod.yaml 
Error from server (BadRequest): error when creating "Task/busybox-pod.yaml": pod in version "v1" cannot be handled as a Pod: no kind "pod" is registered for version "v1" in scheme "pkg/api/legacyscheme/scheme.go:30"
➜  k8s_cka git:(master) ✗ k apply -f Task/busybox-pod.yaml
pod/busybox-pod created
➜  k8s_cka git:(master) ✗ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   172m
➜  k8s_cka git:(master) ✗ wget busybox:1.35
busybox:1.35: Unsupported scheme.
➜  k8s_cka git:(master) ✗ wget busybox     
Prepended http:// to 'busybox'
--2025-12-30 15:57:01--  http://busybox/
Resolving busybox (busybox)... failed: nodename nor servname provided, or not known.
wget: unable to resolve host address ‘busybox’
➜  k8s_cka git:(master) ✗ wget busybox kubernetes.io/hostname
Prepended http:// to 'busybox'
--2025-12-30 15:57:20--  http://busybox/
Resolving busybox (busybox)... failed: nodename nor servname provided, or not known.
wget: unable to resolve host address ‘busybox’
Prepended http:// to 'kubernetes.io/hostname'
--2025-12-30 15:57:20--  http://kubernetes.io/hostname
Resolving kubernetes.io (kubernetes.io)... 15.197.167.90, 3.33.186.135
Connecting to kubernetes.io (kubernetes.io)|15.197.167.90|:80... connected.
HTTP request sent, awaiting response... 301 Moved Permanently
Location: https://kubernetes.io/hostname [following]
--2025-12-30 15:57:20--  https://kubernetes.io/hostname
Connecting to kubernetes.io (kubernetes.io)|15.197.167.90|:443... connected.
HTTP request sent, awaiting response... 404 Not Found
2025-12-30 15:57:20 ERROR 404: Not Found.

➜  k8s_cka git:(master) ✗ clar                                     
zsh: command not found: clar
➜  k8s_cka git:(master) ✗ 
➜  k8s_cka git:(master) ✗ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   173m
➜  k8s_cka git:(master) ✗ k get po         
NAME                            READY   STATUS    RESTARTS   AGE
busybox-pod                     1/1     Running   0          107s
myapp-deploy-57874fd789-f2dbg   1/1     Running   0          3m17s
myapp-deploy-57874fd789-sh872   1/1     Running   0          3m46s
➜  k8s_cka git:(master) ✗ wget busybox-pod kubernetes.io/10.96.0.1
Prepended http:// to 'busybox-pod'
--2025-12-30 15:58:33--  http://busybox-pod/
Resolving busybox-pod (busybox-pod)... failed: nodename nor servname provided, or not known.
wget: unable to resolve host address ‘busybox-pod’
Prepended http:// to 'kubernetes.io/10.96.0.1'
URL transformed to HTTPS due to an HSTS policy
--2025-12-30 15:58:33--  https://kubernetes.io/10.96.0.1
Resolving kubernetes.io (kubernetes.io)... 3.33.186.135, 15.197.167.90
Connecting to kubernetes.io (kubernetes.io)|3.33.186.135|:443... connected.
HTTP request sent, awaiting response... 404 Not Found
2025-12-30 15:58:33 ERROR 404: Not Found.

➜  k8s_cka git:(master) ✗ 
➜  k8s_cka git:(master) ✗ kubectl expose deploy myapp-deploy \
  --name=myapp-svc \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP

service/myapp-svc exposed
➜  k8s_cka git:(master) ✗ k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   175m
myapp-svc    ClusterIP   10.96.176.209   <none>        80/TCP    5s
➜  k8s_cka git:(master) ✗ kubectl exec -it busybox-pod -- sh

/ # wget -O- http://myapp-svc
Connecting to myapp-svc (10.96.176.209:80)
writing to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
-                    100% |*******************************************************************************************|   615  0:00:00 ETA
written to stdout
/ # wget -O- http://myapp-svc:80
Connecting to myapp-svc:80 (10.96.176.209:80)
writing to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
-                    100% |*******************************************************************************************|   615  0:00:00 ETA
written to stdout
/ # wget -O- http://myapp-svc:80
Connecting to myapp-svc:80 (10.96.176.209:80)
writing to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
-                    100% |*******************************************************************************************|   615  0:00:00 ETA
written to stdout
/ # wget -O- http://myapp-svc:80
Connecting to myapp-svc:80 (10.96.176.209:80)
writing to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
-                    100% |*******************************************************************************************|   615  0:00:00 ETA
written to stdout
/ # wget -O- http://myapp-svc:80
Connecting to myapp-svc:80 (10.96.176.209:80)
writing to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
-                    100% |*******************************************************************************************|   615  0:00:00 ETA
written to stdout
/ # wget -O- http://<CLUSTER-IP>:80
sh: can't open CLUSTER-IP: no such file
/ # wget -O- http://myapp-svc:80
Connecting to myapp-svc:80 (10.96.176.209:80)
writing to stdout
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
-                    100% |*******************************************************************************************|   615  0:00:00 ETA
written to stdout
/ # exit
➜  k8s_cka git:(master) ✗ kubectl expose deploy myapp-deploy \
  --name=myapp-svc \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP
