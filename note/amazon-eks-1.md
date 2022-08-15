---
title: AWS 쿠버네티스 관리형 서비스, EKS 시작하기 (1)
author: hatemogi
date: 2022년 8월 8일
keywords: [aws eks kubernetes k8s]
description: AWS의 쿠버네티스 관리형 서비스 EKS에 대해 살펴보고, 간단히 서비스를 배포해보겠습니다.
---

## 쿠버네티스 -- Kubernetes

[지난 글](https://note.hatemogi.com/docker-spring.html)에서 만든 나만의 도커 애플리케이션을, 서비스 용도로 운영하려면, 어딘가에 컨테이너를 실행해야할 텐데요, Amazon EKS라는 쿠버네티스 환경에 실행해보려 합니다.

쿠버네티스는 프러덕션 용도로 쓸 수 있는 컨테이너들을 총체적으로 관리하는 툴입니다. 원래 구글에서 운영하던 컨테이너 운영 관리 플랫폼이었는데, 후에 오픈소스 프로젝트로 공개하고, 여러 회사들이 참여하면서, 이제는 마치 클라우드 환경의 산업 표준처럼 자리잡은 것 같습니다. 구글의 GCP 클라우드는 물론이고, 아마존 AWS 환경에서도 EKS라는 이름의 서비스를 통해 쿠버네티스 환경을 활용할 수 있습니다.

쿠버네티스를 활용하면, 프러덕션 환경에서 서비스를 운영할 때 필요로 하는 복잡한 일들을, 쉽게 진행할 수 있습니다. 서비스를 업데이트할 때, 기존 서비스가 운영되는 상황에서 새 버전의 서비스를 교체하며 업데이트하는 **롤링 업데이트**나, 서비스 부하 상황에 따라 시스템 자원을 늘리거나 줄이는 **오토스케일링**, 시스템 부하를 골고루 나눠주는 **로드 밸런싱**같은 기능들을 쿠버네티스를 통해서 통합 관리할 수 있습니다.

### 기본 용어

* 쿠버네티스 -- <https://kubernetes.io/>

다양하게 중요한 기능을 제공하니만큼, 워낙 알아야 할 내용도 많습니다. 자세히 공부하고 알아야 할 것들이 많지만, 일단은 요약판으로 몇가지 용어만 거칠게 알고 넘어가보겠습니다.

용어                     설명
---                      ----
파드(Pod)                쿠베 환경에서 만들고 관리할 수 있는 배포 최소 단위. 하나 이상의 컨테이너 묶음.
노드(Node)               파드들이 실행되는 환경. 물리머신 또는 가상머신. 한 클러스터에 여러 노드 운영
서비스(Service)          여러 (동일 구성) 파드를 묶어서 대표역할
레플리카세트(ReplicaSet) 정상적인 동일(복제) 파드들을 실행하도록 유지.
디플로이먼트(Deployment) 파드(pod)나 레플리카세트(ReplicaSet)를 어떤 상태로 둘지 선언해 두는 것.

## Amazon EKS

Amazon EKS는 AWS가 관리 운영해주는 쿠버네티스(Kubernetes) 서비스입니다. 내가 직접 쿠버네티스 환경을 구축하지 않고도, 쿠버네티스 환경이 제공하는 강력한 기능들을 간편하게 이용할 수 있습니다.

AWS의 EKS 시작하기 문서에 보면, 아래 두가지 방식으로 설명이 나와 있습니다.

* eksctl 써서 시작하기 - <https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html>
* AWS 관리 콘솔로 시작하기 - <https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html>

여기서는 `eksctl`이라는 CLI 툴을 써서 진행하였습니다. aws CLI툴로 자격증명(credential)도 잘 설정해 놓고 나면, eksctl에서도 해당 권한으로 EKS관련 작업을 진행할 수 있습니다.

### awscli, eksctl, kubectl 설치

홈브루(homebrew)를 사용 중이라면, 아래 명령어로 쉽게 설치할 수 있습니다.

```bash
$ brew install awscli eksctl kubectl
```

aws CLI 툴을 쓰고 있었다면, 이미 설정한 상태이겠지만, 아직 하지 않았다면, `aws configure` 명령어를 이용해서, 자격증명(credential)정보를 입력하고 진행합시다.

### 첫 EKS 클러스터 만들기

```bash
$ eksctl create cluster --name my-cluster --region ap-northeast-2 --fargate
2022-08-08 11:18:33 [ℹ]  eksctl version 0.107.0-dev+b204c3ce.2022-07-29T12:46:37Z
2022-08-08 11:18:33 [ℹ]  using region ap-northeast-2
2022-08-08 11:18:33 [ℹ]  setting availability zones to [ap-northeast-2c ap-northeast-2b ap-northeast-2a]
...
2022-08-08 11:36:26 [✔]  all EKS cluster resources for "my-cluster" have been created
2022-08-08 11:36:27 [ℹ]  kubectl command should work with "/Users/dante/.kube/config", try 'kubectl get nodes'
2022-08-08 11:36:27 [✔]  EKS cluster "my-cluster" in "ap-northeast-2" region is ready
$
```

제 AWS계정에서 서울리전에 연습용 쿠버네티스 클러스터를 만들어보았습니다. 상황에 따라 다르겠지만, 약 20분 정도 기다리니, `my-cluster`가 만들어졌습니다.

### EKS 클러스터 노드 조회

```bash
$ kubectl get nodes -o wide
NAME                                                         STATUS   ROLES    AGE   VERSION               INTERNAL-IP       EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
fargate-ip-192-168-130-228.ap-northeast-2.compute.internal   Ready    <none>   19m   v1.22.6-eks-14c7a48   192.168.130.228   <none>        Amazon Linux 2   4.14.281-212.502.amzn2.x86_64   containerd://1.4.13
fargate-ip-192-168-96-24.ap-northeast-2.compute.internal     Ready    <none>   19m   v1.22.6-eks-14c7a48   192.168.96.24     <none>        Amazon Linux 2   4.14.281-212.502.amzn2.x86_64   containerd://1.4.13
```

### EKS 클러스터 삭제 방법

이하 모든 예제를 다 다루고나면 아래의 명령어로, 클러스터를 꼭 삭제하도록 합니다.

```bash
$ eksctl delete cluster --name my-cluster --region ap-northeast-2
```

### IAM 권한 설정

> IAM root 이용자 말고, 이번 연습 용도로 별도의 계정을 생성해서 (예를 들면 eks_test같은 이름으로), 진행합시다.

### 연결역할 생성

* <https://docs.aws.amazon.com/eks/latest/userguide/connector_IAM_role.html>

```bash
$ eksctl create iamidentitymapping \
    --cluster my-cluster \
    --region=ap-northeast-2 \
    --arn arn:aws:iam::{ACCEESS_ID}:role/my-console-viewer-role \
    --group eks-console-dashboard-full-access-group \
    --no-duplicate-arns
```

### 연결 이용자 생성

```bash
$ eksctl create iamidentitymapping \
    --cluster my-cluster \
    --region=ap-northeast-2 \
    --arn arn:aws:iam::{ACCESS_ID}:user/eks-user \
    --group eks-console-dashboard-restricted-access-group \
    --no-duplicate-arns
```

## 예제 애플리케이션 배포

* Sample application deployment -- <https://docs.aws.amazon.com/eks/latest/userguide/sample-deployment.html>

### EKS 이름 공간 생성

```bash
$ kubectl create namespace eks-sample-app
namespace/eks-sample-app created
```

### Fargate 프로필 생성

```bash
$ eksctl create fargateprofile \
  --cluster my-cluster \
  --name my-fargate-profile \
  --namespace eks-sample-app
```

### 샘플 디플로이먼트 적용

#### eks-sample-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eks-sample-linux-deployment
  namespace: eks-sample-app
  labels:
    app: eks-sample-linux-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: eks-sample-linux-app
  template:
    metadata:
      labels:
        app: eks-sample-linux-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                - amd64
                - arm64
      containers:
      - name: nginx
        image: public.ecr.aws/nginx/nginx:1.21
        ports:
        - name: http
          containerPort: 80
        imagePullPolicy: IfNotPresent
      nodeSelector:
        kubernetes.io/os: linux
```

```bash
$ kubectl apply -f eks-sample-deployment.yaml
deployment.apps/eks-sample-linux-deployment created
```

### 샘플 서비스 적용

#### eks-sample-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: eks-sample-linux-service
  namespace: eks-sample-app
  labels:
    app: eks-sample-linux-app
spec:
  selector:
    app: eks-sample-linux-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```


```bash
$ kubectl apply -f eks-sample-deployment.yaml
deployment.apps/eks-sample-linux-deployment created
```

### 현재 리소스 상태 확인

```bash
$ kubectl get all -n eks-sample-app
```

### 서비스 상세 조회

```bash
$ kubectl -n eks-sample-app describe service eks-sample-linux-service
```

### 특정 파드(pod)에 연결해보자

```bash
$ kubectl exec -it eks-sample-linux-deployment-65b7669776-lrtww -n eks-sample-app -- /bin/bash
root@eks-sample-linux-deployment-65b7669776-lrtww:/# curl http://eks-sample-linux-service
```


### EKS 클러스터 삭제

```bash
$ eksctl delete cluster --name my-cluster --region ap-northeast-2
```

쿠버네티스 클러스터 이용요금이 지속적으로 부과되지 않도록, 반드시 연습이 끝난 클러스터를 삭제하도록 합시다.


## 다음 시간에는

다음 편에서는, 쿠버네티스 클러스터에 기동한 서비스에 부하를 분산시키는 방법과 오토스케일링에 대해 알아보겠습니다.
