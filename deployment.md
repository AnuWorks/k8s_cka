# Parallel Run
k8s_cka git:(master) kubectl get po -o wide
NAME             READY   STATUS    RESTARTS      AGE   IP           NODE                         NOMINATED NODE   READINESS GATES
nginx-rs-87kqj   1/1     Running   1 (23s ago)   19h   10.244.0.4   cka-cluster1-control-plane   <none>           <none>
nginx-rs-fjgzb   1/1     Running   1 (23s ago)   19h   10.244.0.3   cka-cluster1-control-plane   <none>           <none>
nginx-rs-xw2t5   1/1     Running   1 (23s ago)   19h   10.244.0.6   cka-cluster1-control-plane   <none>           <none>
redis-pod        1/1     Running   1 (23s ago)   19h   10.244.0.8   cka-cluster1-control-plane   <none>           <none>
➜  k8s_cka git:(master) kubectl get rs        
NAME       DESIRED   CURRENT   READY   AGE
nginx-rs   3         3         3       19h
➜  k8s_cka git:(master) kubectl delete rs nginx-rs
replicaset.apps "nginx-rs" deleted from default namespace
➜  k8s_cka git:(master) kubectl get rs            
No resources found in default namespace.
➜  k8s_cka git:(master) kubectl get po -o wide    
NAME        READY   STATUS    RESTARTS      AGE   IP           NODE                         NOMINATED NODE   READINESS GATES
redis-pod   1/1     Running   1 (51s ago)   19h   10.244.0.8   cka-cluster1-control-plane   <none>           <none>
➜  k8s_cka git:(master) kubectl delete po redis-pod            
pod "redis-pod" deleted from default namespace
➜  k8s_cka git:(master) kubectl get po -o wide     
No resources found in default namespace.
➜  k8s_cka git:(master) clear
➜  k8s_cka git:(master) kubectl config get-contexts
CURRENT   NAME                CLUSTER             AUTHINFO            NAMESPACE
*         kind-cka-cluster1   kind-cka-cluster1   kind-cka-cluster1   
          kind-cka-cluster2   kind-cka-cluster2   kind-cka-cluster2   kind-cka-cluster1
➜  k8s_cka git:(master) git status
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
➜  k8s_cka git:(master) git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        deleted:    rc.yaml

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        rs.yaml

no changes added to commit (use "git add" and/or "git commit -a")
➜  k8s_cka git:(master) ✗ git add .
➜  k8s_cka git:(master) ✗ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        renamed:    rc.yaml -> rs.yaml

➜  k8s_cka git:(master) ✗ git commit  -m "Update ReplicateController to ReplicaSet"          
[master bc2d6e8] Update ReplicateController to ReplicaSet
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename rc.yaml => rs.yaml (100%)
➜  k8s_cka git:(master) git push origin master
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Delta compression using up to 10 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 262 bytes | 262.00 KiB/s, done.
Total 2 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To github.com:AnuWorks/k8s_cka.git
   d785299..bc2d6e8  master -> master
➜  k8s_cka git:(master) git status
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
➜  k8s_cka git:(master) kubectl apply -f deployment.yaml 
deployment.apps/nginx-deploy created
➜  k8s_cka git:(master) ✗ kubectl get po -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP            NODE                         NOMINATED NODE   READINESS GATES
nginx-deploy-569c86c9fd-f8fqd   1/1     Running   0          6s    10.244.0.11   cka-cluster1-control-plane   <none>           <none>
nginx-deploy-569c86c9fd-ndjq8   1/1     Running   0          6s    10.244.0.9    cka-cluster1-control-plane   <none>           <none>
nginx-deploy-569c86c9fd-swbqw   1/1     Running   0          6s    10.244.0.10   cka-cluster1-control-plane   <none>           <none>
➜  k8s_cka git:(master) ✗ kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/nginx-deploy-569c86c9fd-f8fqd   1/1     Running   0          25s
pod/nginx-deploy-569c86c9fd-ndjq8   1/1     Running   0          25s
pod/nginx-deploy-569c86c9fd-swbqw   1/1     Running   0          25s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   21h

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy   3/3     3            3           25s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-569c86c9fd   3         3         3       25s
➜  k8s_cka git:(master) ✗ kubectl set image deploy/nginx-deployment nginx=nginx:1.19.1    
Error from server (NotFound): deployments.apps "nginx-deployment" not found
➜  k8s_cka git:(master) ✗ kubectl set image deploy/nginx-deploy nginx=nginx:1.19.1    
error: unable to find container named "nginx"
➜  k8s_cka git:(master) ✗ kubectl get deploy    
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deploy   3/3     3            3           2m21s
➜  k8s_cka git:(master) ✗ kubectl set image deploy/nginx-deploy nginx=nginx:1.19.1
error: unable to find container named "nginx"
➜  k8s_cka git:(master) ✗ kubectl set image deploy/nginx-deploy nginx-container=nginx:1.19.1
deployment.apps/nginx-deploy image updated
➜  k8s_cka git:(master) ✗ kubectl get po 
NAME                            READY   STATUS              RESTARTS   AGE
nginx-deploy-569c86c9fd-swbqw   1/1     Running             0          2m49s
nginx-deploy-5cc4ff5d57-2v9bv   1/1     Running             0          3s
nginx-deploy-5cc4ff5d57-hsztz   0/1     ContainerCreating   0          1s
nginx-deploy-5cc4ff5d57-tltvf   1/1     Running             0          9s
➜  k8s_cka git:(master) ✗ kubectl describe deploy nginx-deploy
Name:                   nginx-deploy
Namespace:              default
CreationTimestamp:      Tue, 30 Dec 2025 12:11:36 +0000
Labels:                 app=nginx
                        environment=development
                        type=webserver
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=nginx,environment=development,type=webserver
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
           environment=development
           type=webserver
  Containers:
   nginx-container:
    Image:         nginx:1.19.1
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deploy-569c86c9fd (0/0 replicas created)
NewReplicaSet:   nginx-deploy-5cc4ff5d57 (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m31s  deployment-controller  Scaled up replica set nginx-deploy-569c86c9fd from 0 to 3
  Normal  ScalingReplicaSet  51s    deployment-controller  Scaled up replica set nginx-deploy-5cc4ff5d57 from 0 to 1
  Normal  ScalingReplicaSet  45s    deployment-controller  Scaled down replica set nginx-deploy-569c86c9fd from 3 to 2
  Normal  ScalingReplicaSet  45s    deployment-controller  Scaled up replica set nginx-deploy-5cc4ff5d57 from 1 to 2
  Normal  ScalingReplicaSet  43s    deployment-controller  Scaled down replica set nginx-deploy-569c86c9fd from 2 to 1
  Normal  ScalingReplicaSet  43s    deployment-controller  Scaled up replica set nginx-deploy-5cc4ff5d57 from 2 to 3
  Normal  ScalingReplicaSet  41s    deployment-controller  Scaled down replica set nginx-deploy-569c86c9fd from 1 to 0
➜  k8s_cka git:(master) ✗ kubectl rollout history deploy/nginx-deploy
deployment.apps/nginx-deploy 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

➜  k8s_cka git:(master) ✗ kubectl rollout undo deploy/nginx-deploy --to-revision=1
deployment.apps/nginx-deploy rolled back
➜  k8s_cka git:(master) ✗ kubectl get po                                          
NAME                            READY   STATUS              RESTARTS   AGE
nginx-deploy-569c86c9fd-4sdz7   0/1     ContainerCreating   0          1s
nginx-deploy-569c86c9fd-c6jkw   1/1     Running             0          5s
nginx-deploy-569c86c9fd-kjxs2   1/1     Running             0          3s
nginx-deploy-5cc4ff5d57-2v9bv   1/1     Running             0          93s
nginx-deploy-5cc4ff5d57-hsztz   0/1     Completed           0          91s
➜  k8s_cka git:(master) ✗ 

## Task
k8s_cka git:(master) ✗ kubectl apply -f deployment.yaml 
deployment.apps/nginx-deploy created
➜  k8s_cka git:(master) ✗ kubectl get all                 
NAME                                READY   STATUS              RESTARTS   AGE
pod/nginx-deploy-5cfbb5fb55-8922j   0/1     ContainerCreating   0          3s
pod/nginx-deploy-5cfbb5fb55-chm7q   0/1     ContainerCreating   0          3s
pod/nginx-deploy-5cfbb5fb55-zd6fg   0/1     ContainerCreating   0          3s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   22h

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deploy   0/3     3            0           3s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deploy-5cfbb5fb55   3         3         0       3s
➜  k8s_cka git:(master) ✗ kubectl get po -o wide          
NAME                            READY   STATUS    RESTARTS   AGE   IP            NODE                         NOMINATED NODE   READINESS GATES
nginx-deploy-5cfbb5fb55-8922j   1/1     Running   0          10s   10.244.0.24   cka-cluster1-control-plane   <none>           <none>
nginx-deploy-5cfbb5fb55-chm7q   1/1     Running   0          10s   10.244.0.26   cka-cluster1-control-plane   <none>           <none>
nginx-deploy-5cfbb5fb55-zd6fg   1/1     Running   0          10s   10.244.0.25   cka-cluster1-control-plane   <none>           <none>
➜  k8s_cka git:(master) ✗ kubectl set image deploy/nginx-deploy nginx=nginx:1.23.4
error: unable to find container named "nginx"
➜  k8s_cka git:(master) ✗ kubectl set image deploy/nginx-deploy nginx-container=nginx:1.23.4
deployment.apps/nginx-deploy image updated
➜  k8s_cka git:(master) ✗ kubectl get po        
NAME                            READY   STATUS    RESTARTS   AGE
nginx-deploy-7c77855c87-6nqpm   1/1     Running   0          2s
nginx-deploy-7c77855c87-g4qgd   1/1     Running   0          9s
nginx-deploy-7c77855c87-ggrjw   1/1     Running   0          3s
➜  k8s_cka git:(master) ✗ kubectl describe deploy nginx-deploy
Name:                   nginx-deploy
Namespace:              default
CreationTimestamp:      Tue, 30 Dec 2025 12:24:03 +0000
Labels:                 app=nginx
                        environment=development
                        type=webserver
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=nginx,environment=development,type=webserver
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
           environment=development
           tier=backend
           type=webserver
  Containers:
   nginx-container:
    Image:         nginx:1.23.4
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deploy-5cfbb5fb55 (0/0 replicas created)
NewReplicaSet:   nginx-deploy-7c77855c87 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  77s   deployment-controller  Scaled up replica set nginx-deploy-5cfbb5fb55 from 0 to 3
  Normal  ScalingReplicaSet  19s   deployment-controller  Scaled up replica set nginx-deploy-7c77855c87 from 0 to 1
  Normal  ScalingReplicaSet  13s   deployment-controller  Scaled down replica set nginx-deploy-5cfbb5fb55 from 3 to 2
  Normal  ScalingReplicaSet  13s   deployment-controller  Scaled up replica set nginx-deploy-7c77855c87 from 1 to 2
  Normal  ScalingReplicaSet  12s   deployment-controller  Scaled down replica set nginx-deploy-5cfbb5fb55 from 2 to 1
  Normal  ScalingReplicaSet  12s   deployment-controller  Scaled up replica set nginx-deploy-7c77855c87 from 2 to 3
  Normal  ScalingReplicaSet  11s   deployment-controller  Scaled down replica set nginx-deploy-5cfbb5fb55 from 1 to 0
➜  k8s_cka git:(master) ✗ kubectl rollout history deploy/nginx-deploy
deployment.apps/nginx-deploy 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

➜  k8s_cka git:(master) ✗ kubectl set image deploy/nginx-deploy nginx-container=nginx:1.23.4 --record="Update patch to 1.23.4"      
error: invalid argument "Update patch to 1.23.4" for "--record" flag: strconv.ParseBool: parsing "Update patch to 1.23.4": invalid syntax
See 'kubectl set image --help' for usage.
➜  k8s_cka git:(master) ✗ kubectl annotate deploy/nginx-deploy \
  kubernetes.io/change-cause="Pick up patch version: nginx 1.23.4" \
  --overwrite

deployment.apps/nginx-deploy annotated
➜  k8s_cka git:(master) ✗ kubectl rollout history deploy/nginx-deploy                                                         
deployment.apps/nginx-deploy 
REVISION  CHANGE-CAUSE
1         <none>
2         Pick up patch version: nginx 1.23.4

➜  k8s_cka git:(master) ✗ kubectl scale --replicas=5 deploy/nginx-deploy
deployment.apps/nginx-deploy scaled
➜  k8s_cka git:(master) ✗ kubectl get po
NAME                            READY   STATUS    RESTARTS   AGE
nginx-deploy-7c77855c87-6nqpm   1/1     Running   0          4m13s
nginx-deploy-7c77855c87-g4qgd   1/1     Running   0          4m20s
nginx-deploy-7c77855c87-ggrjw   1/1     Running   0          4m14s
nginx-deploy-7c77855c87-h6r6p   1/1     Running   0          6s
nginx-deploy-7c77855c87-l5ls7   1/1     Running   0          6s
➜  k8s_cka git:(master) ✗ kubectl rollout history deploy/nginx-deploy
deployment.apps/nginx-deploy 
REVISION  CHANGE-CAUSE
1         <none>
2         Pick up patch version: nginx 1.23.4

➜  k8s_cka git:(master) ✗ kubectl rollout undo deploy/nginx-deploy --to-revision=1
deployment.apps/nginx-deploy rolled back
➜  k8s_cka git:(master) ✗ kubectl get po                                          
NAME                            READY   STATUS    RESTARTS   AGE
nginx-deploy-5cfbb5fb55-7tjlc   1/1     Running   0          4s
nginx-deploy-5cfbb5fb55-btdb9   1/1     Running   0          3s
nginx-deploy-5cfbb5fb55-pw4rv   1/1     Running   0          3s
nginx-deploy-5cfbb5fb55-stk65   1/1     Running   0          4s
nginx-deploy-5cfbb5fb55-whspj   1/1     Running   0          4s
➜  k8s_cka git:(master) ✗ kubectl describe deploy nginx-deploy
Name:                   nginx-deploy
Namespace:              default
CreationTimestamp:      Tue, 30 Dec 2025 12:24:03 +0000
Labels:                 app=nginx
                        environment=development
                        type=webserver
Annotations:            deployment.kubernetes.io/revision: 3
Selector:               app=nginx,environment=development,type=webserver
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
           environment=development
           tier=backend
           type=webserver
  Containers:
   nginx-container:
    Image:         nginx:1.23.0
    Port:          80/TCP
    Host Port:     0/TCP
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  nginx-deploy-7c77855c87 (0/0 replicas created)
NewReplicaSet:   nginx-deploy-5cfbb5fb55 (5/5 replicas created)
Events:
  Type    Reason             Age                From                   Message
  ----    ------             ----               ----                   -------
  Normal  ScalingReplicaSet  6m49s              deployment-controller  Scaled up replica set nginx-deploy-5cfbb5fb55 from 0 to 3
  Normal  ScalingReplicaSet  5m51s              deployment-controller  Scaled up replica set nginx-deploy-7c77855c87 from 0 to 1
  Normal  ScalingReplicaSet  5m45s              deployment-controller  Scaled down replica set nginx-deploy-5cfbb5fb55 from 3 to 2
  Normal  ScalingReplicaSet  5m45s              deployment-controller  Scaled up replica set nginx-deploy-7c77855c87 from 1 to 2
  Normal  ScalingReplicaSet  5m44s              deployment-controller  Scaled down replica set nginx-deploy-5cfbb5fb55 from 2 to 1
  Normal  ScalingReplicaSet  5m44s              deployment-controller  Scaled up replica set nginx-deploy-7c77855c87 from 2 to 3
  Normal  ScalingReplicaSet  5m43s              deployment-controller  Scaled down replica set nginx-deploy-5cfbb5fb55 from 1 to 0
  Normal  ScalingReplicaSet  97s                deployment-controller  Scaled up replica set nginx-deploy-7c77855c87 from 3 to 5
  Normal  ScalingReplicaSet  16s                deployment-controller  Scaled up replica set nginx-deploy-5cfbb5fb55 from 0 to 2
  Normal  ScalingReplicaSet  14s (x8 over 16s)  deployment-controller  (combined from similar events): Scaled down replica set nginx-deploy-7c77855c87 from 1 to 0
➜  k8s_cka git:(master) ✗ 