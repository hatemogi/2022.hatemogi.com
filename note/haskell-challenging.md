---
title: 프로 하스켈러 4개월차 | 하스켈의 단점
author: hatemogi
date: 2022년 8월 22일
keywords: [haskell]
description: 하스켈로 월급받는 개발자가 된지 벌써 4개월이 지났습니다. 그동안 하스켈의 좋은 점만을 극찬해보았는데요, 이번에는 하스켈의 단점을 언급해볼게요.
---

하스켈로 백엔드 개발을 하며, 월급을 받는다는 의미로 "프로 하스켈러"가 되었다는 글을 몇 편 올렸습니다. 그동안 하스켈의 좋은 점들을 많이 나열했으니, 이번 한 편 정도는 단점도 적어보겠습니다.

* [프로 하스켈러 1일차 - GHCup](https://medium.com/happyprogrammer-in-jeju/프로-하스켈러-1일차-d04fe4f10ec0)
* [프로 하스켈러 2일차 - 이상적 프로그래밍 언어](https://medium.com/happyprogrammer-in-jeju/프로-하스켈러-2일차-db0f1e81e349)
* [프로 하스켈러 3일차 - Functor, and ...](https://medium.com/happyprogrammer-in-jeju/프로-하스켈러-3일차-176837a0133e)
* [프로 하스켈러 4일차 - Monad Transformers](https://medium.com/happyprogrammer-in-jeju/프로-하스켈러-4일차-bbe96f0e5746)
* [프로 하스켈러 6주차 - Scotty Web Framework](https://medium.com/happyprogrammer-in-jeju/프로-하스켈러-6주차-9c0180bf13d3)
* [프로 하스켈러 8주차 - 함수형 프로그래밍과 명령형 프로그래밍](<https://medium.com/happyprogrammer-in-jeju/프로-하스켈러-8주차-98c55fd616e9)

범용 프로그래밍 언어(General purpose programming language)의 특징을 갖춘 언어들은 언어의 기능 자체로는 서로 할 수 있는 일이 기본적으로 동일합니다만, 결국 그 언어를 활용해서 무언가를 만들 때 필요한 각종 편의 기능과 이용자 규모에 따른 라이브러리의 규모 측면에서 차이가 도드라지기도 합니다.

그동안 하스켈로 일하며 느낀 단점들을 간단히 적어보겠습니다.

## 빈약한 표준 라이브러리

표준 라이브러리가 base 패키지로 있고, 그 규모가 좀 빈약합니다. 표준 라이브러리를 최소한으로 두고, 갖가지 추가 패키지들을 가져다 쓰는 방식인데요, 이게 최소한의 모듈들만 가져다 쓴다는 측면에서 장점이 될 수도 있겠습니다만, 뭔가 좀 쓰려면 추가 패키지를 찾아서 의존성을 추가해야 하는 불편한 면도 있습니다. 언어 표준 라이브러리의 규모가 너무 빈약하다 보고 있습니다. base 패키지에 더 많은 라이브러리가 기본 포함되어 있으면 좋겠네요.

표준 라이브러리가 빈약하다 보니, 같은 기능을 구현한 3자 라이브러리가 겹치는 경우도 더러 눈에 띕니다. 다양한 옵션이 있어 좋다고 볼 수도 있겠지만, 쓰는 사람에게 너무 많은 선택권이 있는 건 그 자체로 단점이 될 수 있습니다.

### String, Text, ByteString

빈약한 표준 라이브러리와 이어지는 문제이기도 한데, 프로그래밍 시에 가장 기본적인 원소라고도 볼 수 있는 문자열이 종류가 여럿입니다. 언어 기본으로는 String이라는 타입을 쓰는데, 이게 [Char]를 쓰는 거라 성능 측면에서 이를 싫어하는 개발자들이 ByteString이나 Text등을 쓰기 때문에, 다른 라이브러리를 쓸 때마다 이 것들을 서로 변환해가며 써야 할 때가 많습니다.

이론적으로는 문자열이 그저 유니코드 캐릭터의 리스트라는 점이 우아합니다만, 현실도 좀 챙깁시다.

## 써드파티 라이브러리도 빈약하다

사용자층이 얇다 보니, 게다가 현업 환경에서 활용하는 사람이 많지 않다 보니, 꼭 있어야 할 법한 3자 라이브러리도 부족합니다. 예를 들어, 저희는 GCP 클라우드 환경을 쓰는데, GCP에서 AWS의 S3 역할을 하는 파일 업로드 시에 사전 서명하는 라이브러리가 마땅치 않아서 이걸 직접 구현한다거나, APNS 푸시를 보내는 라이브러리가 없어서 직접 만든다거나 하는 일을 하게 됩니다.

예전에는, 이럴 때 '오픈소스 라이브러리'를 만들어 공개할 기회로 보기도 했습니다만, 당장 결과물을 만들어 내야 하는 현업 개발자 입장에서, 내가 작성해야 할 코드량이 늘어나는 것은 결코 달가운 일이 아니라고 보게 됐습니다.

프로 개발자로서, 내가 작성하는 코드의 양은 최소화하고, 결과물이 하는 일은 최대화해야 합니다. 그러려면, 남들이 잘 만들어 놓은 코드를 활용해야 하는데, 남들이 잘 만들어 놓은 코드의 양이 적습니다.

## 뭐 하나 하려면 모나드 덧칠

하스켈은 순수 함수형 프로그래밍 언어입니다. 명령형 언어에서 간단히 처리할만한 부수 효과를 일으키기 위해서는 각종 모나드를 활용해야 하며, 이 모나드를 켜켜이 쌓아서 변환해 가며 처리하기도 합니다. 수학적 고결함을 추구하는 것도 좋지만, 이게 이렇게까지 모나드를 떡칠해가며 써야하는가 현타가 올 때도 있습니다.


## 너무 많은 언어 확장 기능

하스켈의 산업 표준 컴파일러는 GHC 컴파일러입니다. GHC가 표준적으로 널리 쓰이고, 이 컴파일러에 있는 언어 확장이 다양합니다. 심지어, 그 확장들을 사람들이 활발히 씁니다. 쓰고자 하는 사람은 언어에 다양하고 강력한 기능이 있어서 좋을 수도 있겠습니다만, 배우는 입장에서는 너무 많은 기능들을 알아야 하고 확장 옵션을 키고 끄고 해 가며 신경 써야 하는 점 자체로 인지부하가 발생합니다. 당장은 좀 모르고 넘어가고 싶은데, 그럴 수가 없습니다.

## 요약

- 표준 라이브러리가 빈약하다.
- 써드파티 라이브러리도 빈약하다. 이걸 다 만들고 있는 게 맞나?
- 뭐하나 하려면 모나드 덧칠이다. 모나드를 모르고 하스켈 개발할 수 없다.
- GHC 언어 확장이 매우 많고, 게다가 활발히 쓰인다.

이 정도 단점들을 꼽아봤습니다. 다음 글부터는 다시 장점 위주로 적어보겠습니다. 이 정도면 깔만큼 깐 거 같아요. ㅎ

