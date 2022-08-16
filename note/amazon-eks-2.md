---
title: AWS 쿠버네티스 관리형 서비스, EKS 시작하기 (2)
author: hatemogi
date: 2022년 8월 15일
keywords: [aws eks kubernetes k8s]
description: AWS의 쿠버네티스 관리형 서비스 EKS에 대해 살펴보고, 간단히 서비스를 배포해서 자동 스케일링까지 해보겠습니다.
---

지난 번, [AWS 쿠버네티스 관리형 서비스, EKS 시작하기 (1)](https://note.hatemogi.com/amazon-eks-1.html)에서는 AWS EKS 환경에 새로운 쿠버네티스 클러스터를 만들고, 예제 서비스와 디플로이먼트를 등록해보았습니다. 이어서 오토스케일링과 도커 이미지 저장소 활용법을 알아볼게요.

## 오토스케일러 -- Autoscaler

수직적 파드 오토스케일러(Vertical Pod Autoscaler)와 수평적 파드 오토스케일러(Horizontal Pod Autoscaler) 두가지 방식이 있습니다. 수직적 오토 스케일러는, 파드에 할당된 CPU이용량과 메모리 제한을 더 늘리거나 줄이는 방식으로 스케일링하고, 수평적 오토스케일러는, 파드 숫자를 늘리거나 줄여서 대응하는 방식입니다.

종류               대응                                    예
----               ----                                    ----
수직 오토스케일러  파드 CPU 이용제한, 메모리 제한을 조절.  예를 들어 512M 메모리 -> 2G
수평 오토스케일러  파드 대수를 늘림.                       파드 3대 -> 파드 5대

이 글에서는 수평 오토스케일러에 대해서 알아보겠습니다.

* <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/>
* <https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html>

### 메트릭 서버 설치

먼저, 운영하는 쿠버네티스 클러스터에 '메트릭 서버'를 설치해야 합니다.

* 클러스터에 메트릭 서버 설치 -- <https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html>

```bash
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
```

### 메트릭 서버 확인

```bash
$ kubectl get deployment metrics-server -n kube-system
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           6m26s
```

kube-system 이름 공간에 metrics-server가 정상 기동 중임을 확인할 수 있습니다.


### 샘플 애플리케이션 배포

이번에는 시스템 부하를 주고 스케일링을 확인하기 좋도록, 아파치 웹서버를 클러스터에 배포해보겠습니다.

```bash
$ kubectl apply -f https://k8s.io/examples/application/php-apache.yaml
```

php-apache라는 이름으로 서비스와 디플로이먼트가 준비됩니다.

### 수평 오토 스케일러 설정

```bash
$ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

위 오토스케일 명령을 실행하면, php-apache 디플로이먼트의 CPU 사용량 50%를 기준으로 1개부터 10개까지 자동 조절되며 운영됩니다.

### 오토 스케일러 확인

```bash
$ kubectl get hpa
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   0%/50%    1         10        1          51s
```

### 임의로 부하 발생 실험

```bash
kubectl run -i \
    --tty load-generator \
    --rm --image=busybox \
    --restart=Never \
    -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

위 명령어로, 단순한 파드를 하나 띄워서, 지속적으로 HTTP요청을 발생시킵니다.

#### 1단계 -- 레플리카 3 (부하 상황)

```bash
NAME                                             REFERENCE               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/php-apache   Deployment/php-apache   113%/50%   1         10        3          3m45s
```

잠시후 부하가 113%로 치솟으며, 레플리카가 3으로 늘었습니다.


#### 2단계 -- 레플리카 3 (부하 중단)

```bash
NAME                                             REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/php-apache   Deployment/php-apache   0%/50%    1         10        3          4m25s
```

부하를 중단시키면, CPU 활용량이 0%로 다시 내려갑니다. 레플리카 수는 아직 3개인 상태입니다.

#### 3단계 -- 레플리카 1 (부하 중단 약 5분 후)

```bash
NAME                                             REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/php-apache   Deployment/php-apache   0%/50%    1         10        1          9m36s
```

시간 주기를 같고, 최소 설정 파드 수 만큼 다시 줄어듭니다.


## Amazon ECR -- 도커 레지스트리

이어서, AWS환경에서 도커이미지 저장소를 생성하고 이용하는 방법입니다.

#### ECR 저장소 만들기

```bash
aws ecr create-repository --region ap-northeast-2 --repository-name hatemogi
```

원하는 리젼에 저장소 이름을 지정해서 만듭니다. AWS 콘솔 UI에서 만들어도 좋습니다.

#### ECR 저장소에 로그인

```bash
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 936632101060.dkr.ecr.ap-northeast-2.amazonaws.com
```

저장소에 이미지를 푸시할 수 있도록, 로그인 해둡니다.

#### 푸시할 도커 이미지 태그

```bash
docker tag hatemogi:v0.1.1 936632101060.dkr.ecr.ap-northeast-2.amazonaws.com/hatemogi:v0.1.1
```

로컬에 있는 목표 이미지를, 프라이빗 저장소에 올리기 좋게 태그합니다.

#### 프라이빗 ECR에 푸시

```bash
docker push 936632101060.dkr.ecr.ap-northeast-2.amazonaws.com/hatemogi:v0.1.1
```

위 명령어로, 내 개인 저장소에 이미지가 푸쉬합니다.

