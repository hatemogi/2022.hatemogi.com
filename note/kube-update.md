---
title: 쿠버네티스 서비스 롤링 업데이트
author: hatemogi
date: 2022년 8월 30일
keywords: [kubernetes update kustomization]
description: 쿠버네티스에서 운영중인 서비스를 중단없이 업데이트하는 방법을 알아보겠습니다.
---

## 클러스터 생성

```bash
$ eksctl create cluster --name rolling --region ap-northeast-2 --version 1.23 --without-nodegroup --fargate
```

`rolling`이라는 클러스터를 서울리전에 만들었습니다.

배포(deployment)를 만들 때, 도커 이미지명과 함께, 이미지 풀 정책을 지정할 수 있습니다.

풀 정책          ImagePullPolicy
--------------   -----------------
IfNotPresent     로컬에 이미지가 없을 때만 받아온다.
Always           kubelet이 컨테이너를 실행할 때마다 이미지를 받아온다. 이미지 다이제스트가 정확히 일치하지 않는 (로컬 캐시에 없는) 이미지를 받아온다.
Never            반드시 로컬에 이미지가 있어야 하는 상황을 가정. 로컬에 해당 이미지가 없으면 컨테이너 실행 실패 처리.

Always로 지정해도, 캐싱처리되기 때문에, 대부분의 경우는 Always로 충분하겠습니다.

### 이미지 버전 지정하기

> You should avoid using the :latest tag when deploying containers in production as it is harder to track which version of the image is running and more difficult to roll back properly.
>
> Instead, specify a meaningful tag such as v1.42.0.

도커 이미지를 저장할 때는 latest같은 태그대신에 구체적인 버전을 명시하는 것이 좋습니다.

## 롤링 업데이트 예제 (1)

<https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>

### nginx 배포

#### 배포 -- deployment.yaml

```bash
$ kubectl apply -f deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

`nginx-deployment`라는 이름으로 `nginx:1.14.2`이미지 컨테이너 레플리카를 3개 만들겠다는 배포입니다.


항목                       값                 의미
----                       ----               ----
metadata.name              nginx-deployment   deployment의 이름
spec.replicas              3                  Pod를 3개 띄우고자 한다
spec.selector.matchLabels  nginx              이 배포가 관리하는 Pod들을 찾는 방법



#### nginx 배포 상태 확인

```bash
$  kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           5h24m
```

#### nginx 배포 상세 확인

```bash
kubectl describe deployments nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Tue, 30 Aug 2022 11:53:38 +0900
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx:1.16.1
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-ff6655784 (3/3 replicas created)
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  44m                  deployment-controller  Scaled up replica set nginx-deployment-9456bbbf9 to 1
```

주요 항목    내용
---------    -----
Replicas     3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType RollingUpdate


#### nginx 배포된 Pod들 확인

```bash
$ kubectl get pods -l app=nginx

NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-9456bbbf9-2qq7z   1/1     Running   0          5m28s
nginx-deployment-9456bbbf9-bz5r9   1/1     Running   0          7m24s
nginx-deployment-9456bbbf9-nz7x8   1/1     Running   0          6m26s
```

#### 특정 Pod 상세 확인

```bash
$ kubectl describe pods nginx-deployment-9456bbbf9-2qq7z
Name:                 nginx-deployment-9456bbbf9-2qq7z
Namespace:            default
Priority:             2000001000
Priority Class Name:  system-node-critical
Node:                 fargate-ip-192-168-184-112.ap-northeast-2.compute.internal/192.168.184.112
Start Time:           Tue, 30 Aug 2022 17:10:43 +0900
Labels:               app=nginx
                      eks.amazonaws.com/fargate-profile=fp-default
                      pod-template-hash=9456bbbf9
Annotations:          CapacityProvisioned: 0.25vCPU 0.5GB
                      Logging: LoggingDisabled: LOGGING_CONFIGMAP_NOT_FOUND
                      kubernetes.io/psp: eks.privileged
Status:               Running
IP:                   192.168.184.112
IPs:
  IP:           192.168.184.112
Controlled By:  ReplicaSet/nginx-deployment-9456bbbf9
Containers:
  nginx:
    Container ID:   containerd://9ff19d565d9d718302b8bd45d37a234ff1eb920cdf2fcdf3627710ad15ed6f60
    Image:          nginx:1.14.2
    Image ID:       docker.io/library/nginx@sha256:f7988fb6c02e0ce69257d9bd9cf37ae20a60f1df7563c3a2a6abe24160306b8d
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 30 Aug 2022 17:10:52 +0900
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mvrl6 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-mvrl6:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason           Age    From               Message
  ----     ------           ----   ----               -------
  Warning  LoggingDisabled  10m    fargate-scheduler  Disabled logging because aws-logging configmap was not found. configmap "aws-logging" not found
  Normal   Scheduled        9m22s  fargate-scheduler  Successfully assigned default/nginx-deployment-9456bbbf9-2qq7z to fargate-ip-192-168-184-112.ap-northeast-2.compute.internal
  Normal   Pulling          9m22s  kubelet            Pulling image "nginx:1.14.2"
  Normal   Pulled           9m14s  kubelet            Successfully pulled image "nginx:1.14.2" in 7.582622606s
  Normal   Created          9m14s  kubelet            Created container nginx
  Normal   Started          9m14s  kubelet            Started container nginx
```

주요 항목  내용
---------  -----
Image      nginx:1.14.2

#### nginx 이미지 업데이트

``` bash
$ kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
deployment.apps/nginx-deployment image updated
```

#### 업데이트 요청 후 파드 상태 확인


1. 기존 버전 패드 3개가 유지된 상태에서, 새 버전의 파드가 하나 생성되어 `Pending`상태

```bash
$ kubectl get pods -l app=nginx
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-9456bbbf9-2qq7z   1/1     Running   0          13m
nginx-deployment-9456bbbf9-bz5r9   1/1     Running   0          15m
nginx-deployment-9456bbbf9-nz7x8   1/1     Running   0          14m
nginx-deployment-ff6655784-4vqrb   0/1     Pending   0          45s
```


2. Pending상태였던 새 버전 파드가 Running상태로 바뀌고, 기존 버전 Pod가 하나 사라지고, 새버전 파드가 하나더 생기면서 `Pending` 상태. 즉, 2개가 기존 버전, 1개가 새버전인 상태.

```bash
$ kubectl get pods -l app=nginx
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-9456bbbf9-2qq7z   1/1     Running   0          13m
nginx-deployment-9456bbbf9-nz7x8   1/1     Running   0          14m
nginx-deployment-ff6655784-4vqrb   1/1     Running   0          63s
nginx-deployment-ff6655784-cfqk6   0/1     Pending   0          2s
```


3. 차례로 같은 과정이 반복되어, 이제 마지막 세번째 신규 파드가 `ContainerCreating`상태.

```bash
$ kubectl get pods -l app=nginx
NAME                               READY   STATUS              RESTARTS   AGE
nginx-deployment-9456bbbf9-2qq7z   1/1     Running             0          15m
nginx-deployment-ff6655784-46q6b   0/1     ContainerCreating   0          62s
nginx-deployment-ff6655784-4vqrb   1/1     Running             0          3m4s
nginx-deployment-ff6655784-cfqk6   1/1     Running             0          2m3s
```


4. 세번째 파드까지 `Running` 상태가 되면, 기존 버전의 파드들은 모두 종료된 상태.

```bash
$ kubectl get pods -l app=nginx
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-ff6655784-46q6b   1/1     Running   0          65s
nginx-deployment-ff6655784-4vqrb   1/1     Running   0          3m7s
nginx-deployment-ff6655784-cfqk6   1/1     Running   0          2m6s
```

#### 업데이트된 파드 확인

```bash
$ kubectl describe pods nginx-deployment-ff6655784-46q6b
Name:                 nginx-deployment-ff6655784-46q6b
Namespace:            default
Priority:             2000001000
Priority Class Name:  system-node-critical
Node:                 fargate-ip-192-168-176-170.ap-northeast-2.compute.internal/192.168.176.170
Start Time:           Tue, 30 Aug 2022 17:25:20 +0900
Labels:               app=nginx
                      eks.amazonaws.com/fargate-profile=fp-default
                      pod-template-hash=ff6655784
Annotations:          CapacityProvisioned: 0.25vCPU 0.5GB
                      Logging: LoggingDisabled: LOGGING_CONFIGMAP_NOT_FOUND
                      kubernetes.io/psp: eks.privileged
Status:               Running
IP:                   192.168.176.170
IPs:
  IP:           192.168.176.170
Controlled By:  ReplicaSet/nginx-deployment-ff6655784
Containers:
  nginx:
    Container ID:   containerd://0a7443a87250457095679281f0c8bd1ca495ff9f1bfb84524fb16d20a7151e53
    Image:          nginx:1.16.1
    Image ID:       docker.io/library/nginx@sha256:d20aa6d1cae56fd17cd458f4807e0de462caf2336f0b70b5eeb69fcaaf30dd9c
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 30 Aug 2022 17:25:30 +0900
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-542mb (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-542mb:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason           Age    From               Message
  ----     ------           ----   ----               -------
  Warning  LoggingDisabled  9m9s   fargate-scheduler  Disabled logging because aws-logging configmap was not found. configmap "aws-logging" not found
  Normal   Scheduled        8m17s  fargate-scheduler  Successfully assigned default/nginx-deployment-ff6655784-46q6b to fargate-ip-192-168-176-170.ap-northeast-2.compute.internal
  Normal   Pulling          8m17s  kubelet            Pulling image "nginx:1.16.1"
  Normal   Pulled           8m9s   kubelet            Successfully pulled image "nginx:1.16.1" in 8.052819924s
  Normal   Created          8m8s   kubelet            Created container nginx
  Normal   Started          8m8s   kubelet            Started container nginx
```

주요 항목  내용
---------  -----
Image      nginx:1.16.1

#### 롤링 업데이트 커맨드 요약

```bash
$ kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
```

`kubectl set image` 명령어로 배포된 Deployment의 이미지 버전을 바꾸면, 쿠버네티스가 롤링 업데이트를 진행한다.


### 추가로 활용할만한 명령어

```bash
$ kubectl edit deployment/nginx-deployment
```

`kubectl edit` 명령어로, 현재 배포된 deployment를 편집할 수 있다. `kubectl set image` 같은 명령어를 이용해서, deployment.yaml 파일과 다른 상태라 하더라도 현 배포상태에서 추가로 편집할 수 있다.

## 그래서, 자동 배포 업데이트를 한다면...

### 1. 도커이미지 빌드시, 버전을 구체적으로 태그한다

```yaml
- name: SHA_SHORT 환경 변수 설정
  run: |-
    echo "SHA_SHORT=$(git rev-parse --short HEAD)" >> $GITHUB_ENV

- name: 도커 이미지 이름 설정
  run: |-
    echo "IMAGE=repository-url.io/openapi:${{ env.SHA_SHORT }}" >> $GITHUB_ENV

- name: Mutation 도커 이미지 빌드
  run: docker build --target openapi -t ${{ env.IMAGE }} .
```

### 2. 해당 도커 이미지를 저장소에 푸시한다.

```yaml
- name: 도커 이미지 푸시
  run: docker push ${{ env.IMAGE }}
```

### 3. 쿠버네티스에 롤링 업데이트를 요청한다.

```yaml
- name: 쿠버네티스 이미지 업데이트
  run: kubectl set image deployment/배포이름 openapi=${{ env.IMAGE}}
```

## 요약

쿠버네티스의 Deployment에 있는 이미지를 변경 요청하면, 롤링 업데이트를 진행하게 된다. 새버전을 배포하려면, 이미지 저장소에, 새버전의 이미지를 푸시한 다음, 이미지 변경 요청을 하자.





