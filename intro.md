---
title: 백엔드 엔지니어 김대현
author: hatemogi
date: 2022년 7월 18일
keywords: [intro FP programmer]
description: 안녕하세요, 함수형 프로그래밍과 사이드 프로젝트에 관심이 많은, 백엔드 개발자 김대현입니다.
---

## 소개

안녕하세요. 백엔드 개발자 김대현입니다! 👋

이제까지, 카카오(다음), NHN, 라인플러스에서 일했고, 현재는 [컨스택츠](https://constacts.com)라는 작은 스타트업에서 Haskell이라는 함수형 프로그래밍 언어로 백엔드 시스템을 구축하고 있습니다.

제주도🏝 바닷가에서 한적하게 쉬며 커피☕️ 마시는 것을 좋아합니다.

[Medium](https://hatemogi.medium.com)에 개발 관련한 글을 적기도 하고, [YouTube](https://youtube.com/c/hatemogi101)에도 개발 관련 영상을 올리고 있어요.

제 관심 분야를 적으면, 앞으로 공유할 글들에 대한 방향성을 가늠하시기 좋을 것 같습니다.

---

## 함수형 프로그래밍

제 관심 분야 중 가장 먼저 꼽고 싶은 것은, 함수형 프로그래밍입니다. 현재 대부분의 주요 프로그래밍 언어는 "명령형 프로그래밍" 스타일입니다만, 함수형 프로그래밍의 장점들이 꽤 녹아들고 있는 것 같습니다.

### 함수형 프로그래밍 언어 | (1) Clojure

['해커와 화가'](https://link.coupang.com/a/s8JaL)라는 책을 읽고, LISP라는 **함수형 프로그래밍** 언어에 관심을 갖게 되었습니다. 그러다 JVM이 널리 쓰이는 현업 환경에서 쓰기 좋은 [클로저(Clojure)](https://clojure.org)를 접하게 되었고, 그 매력적이고 강력한 언어에 빠져들었습니다. 이제껏 배운 언어 중, 리스프 계열 언어들이 가장 우아하다 생각합니다만, 현업 환경의 다수의 개발자들에게 리스프의 모양새는 꽤나 (충격적)이기 때문에, 규모 있는 회사에서 적용해 쓰기에는 부담이 있어 아쉬웠지요.

```clojure
(defroutes 라우터
  (GET "/" [] 핸들러)
  (POST "/echo-name" [name]
    (str "안녕하세요, " name "님!"))
  (GET "/index.html" _
    (html [:main
           [:section
            [:h1 "안녕하세요"]
            [:div "클로저 웹서비스 데모"]]]))
  (route/not-found "찾을 수 없습니다"))
```

(clojure + compojure)를 이용해 HTTP 서비스를 구성한 예제입니다. 리스프 계통 언어에 익숙하신 분들에게는 아주 자연스러운 코드일 텐데요, 대부분의 개발자들은, 다른 언어에서보다 많아 보이는 괄호 쌍()으로 인해 거부감을 느끼는 것 같습니다. 익숙해지면, 저 간결한 괄호식들이 참 우아해 보인다는 걸, 믿으실지 모르겠습니다.

### 함수형 프로그래밍 언어 | (2) Scala

그러다가, LINE 광고개발본부에 입사했는데, 이미 본부 내 몇몇 팀에서 [스파크(Spark)](https://spark.apache.org/)를 이용하며 [스칼라(Scala)](https://www.scala-lang.org/) 코드베이스로 개발을 하고 있었습니다. 이에 용기를 얻어, 제가 진행하게 된 신규 프로젝트를 스칼라로 하겠다 보고드렸고, 공식적으로 스칼라 함수형 프로그래밍으로 현업 서비스를 개발해 일본과 대만에 오픈했습니다.

게다가 스칼라로 함수형 프로그래밍을 하려는 개발자 분들이 여럿 저희 팀에 합류해 주셔서, 별다른 외압(?) 없이 스칼라 함수형 프로그래밍을 잘할 수 있게 되어 감사했습니다. 아무리 함수형 프로그래밍이 좋다한들, 충원이 되지 않으면 무슨 소용이 있겠습니까?

```scala
trait Semigroup[A] {
  def combine(x: A, y: A): A
}

trait Monoid[A] extends Semigroup[A] {
  def empty: A
}

implicit val intAdditionMonoid: Monoid[Int] = new Monoid[Int] {
  def empty: Int = 0
  def combine(x: Int, y: Int): Int = x + y
}

def combineAll[A: Monoid](as: List[A]): A =
  as.foldLeft(Monoid[A].empty)(Monoid[A].combine)

combineAll(List(1, 2, 3)) // res3: Int = 6
```

스칼라 코드의 모양을 소개하기 위해, [Cats라는 라이브러리의 Monoid 설명서](https://typelevel.org/cats/typeclasses/monoid.html
)에 나와있는 예제를 가져와봤습니다. 그래도 스칼라는, 일반적인 명령형 프로그래밍 언어와 겉모습이 비슷하기에, 그리고 스파크라는 프레임워크 덕분에, 업무 환경에 도입해 쓰기에 부담이 적은 것 같습니다.

### 라인개발실록 인터뷰

<iframe width="560" height="315" src="https://www.youtube.com/embed/H6JxxWL6bJI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

당시 저희 팀에서 함수형 프로그래밍을 하고 있단 소식에, 인터뷰까지 진행하게 되었습니다. 진행자 민우님이 잘 이끌어 주셔서 (제게는) 재미있는 영상이 남았습니다. 언젠가 좀 더 본격적으로 함수형 프로그래밍을 소개하는 영상을 남기고 싶네요.

## 함수형 프로그래밍 언어 | (3) Haskell

클로저와 스칼라는 함수형 프로그래밍 언어로 분류할 수 있습니다. 한편, 함수형 프로그래밍의 끝판에는 "순수" 함수형 프로그래밍 언어인 [하스켈(haskell)](https://www.haskell.org/)이 있습니다. 어떻게 제게 이런 행운이 흘러드는지, 하스켈마저도 업무용으로 쓸 수 있게 되었습니다.

2022년 소개를 적는 현재, 컨스택츠라는 스타트업에서 신규 백엔드 시스템을 하스켈로 구축하고 있습니다. 아마도 국내에서 유일하게 하스켈을 실무에 활용하는 회사가 아닐까 합니다. 그래서 저희는, 농담 섞어서, 국내 하스켈 개발자 Top 10 중 3명이 근무 중인 회사라고 허세를 부리고 다닙니다. **국내에 실무 하스켈 개발자가 열 명이 안될 거**라는 매우 합리적인 추측 때문에 가능한 농담이죠.


```haskell
quickSort :: Ord a => [a] -> [a]
quickSort [] = []
quickSort (x:xs) =
  quickSort smaller ++ [x] ++ quickSort larger
  where
    (smaller, larger) = partition (<= x) xs

--- >>> take 11 $ quickSort [1..30000000]
-- [1,2,3,4,5,6,7,8,9,10]
```

퀵소트 알고리즘을 구현한 하스켈 코드를 가져와봤습니다. 첫줄에 타입 선언이 있고, 이어서, 빈 리스트와 그렇지 않은 리스트에 대한 함수 본문이 나와있습니다. 퀵소트는 주어진 리스트에서 피벗 요소를 기준으로 작은 요소들과 큰 요소들의 리스트로 나눠서 재귀(recursion)로 구현할 수 있는데요, 지금 말로 설명한 부분이, 코드에 그대로 직관적으로 반영되어 멋진 것 같습니다.

하스켈은 엄격한 정적 타입 시스템을 갖춘 순수 함수형 프로그래밍 언어입니다. 순수 함수형 언어는, 함수 내에서 부수효과를 일으킬 수 없기에, 무언가 효과를 일으키기 위해서는 효과자체를 문맥에 담아 표현하고, 그 문맥을 다루기 편하게 하기 위해, 수학적 이론을 바탕으로 한 모나드(Monad)를 적극 활용합니다.

하스켈에 대해서도 차차 소개할 수 있게되기를 기대해봅니다.

---

## 사이드 프로젝트

다음으로 꼽을만한 관심 분야는, 때때로 진행하는 사이드 프로젝트입니다. 결과물이 공개적으로 잘 드러나는 프로젝트를 하려고, 프론트엔드 개발도 기웃거릴 때가 있습니다. 아무래도 본업은 백엔드 개발자이기 때문에, 프론트엔드 개발자 분들이 보시기에는, 어설픈 작업물일 가능성이 높습니다만, 그래도 재밌게 개발하고 있습니다. 틈틈히 연습해두니까, 백엔드 개발자로서, 간혹 필요한 웹화면을 만들기에 좋습니다. 구축한 시스템의 웹 관리 페이지를 만들 때도 유용합니다.

### 프론트엔드 프로그래밍 | (1) Elm

프론트엔드 개발에 좋은, [Elm](https://elm-lang.org)이라는 함수형 프로그래밍 언어가 있습니다. 하스켈과 마찬가지로 순수 함수형 프로그래밍 언어이고, 언어 기능이 간략해서 배우기 쉽고, 웹에 특화돼 있어서, 곧바로 웹 개발을 하기에 좋습니다. 아쉽게도, 쓰는 사람이 많지는 않기 때문에, 학습 자료를 찾아보기에는 아쉬운 점이 많은 것 같습니다.

```Elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url, route = urlToRoute url }, Cmd.none )

        UpdateProjectFilter f ->
            ( { model | projectFilter = f }, Cmd.none )
```

제 개인 홈에 이용한 Elm코드의 일부를 가져와 보았습니다. 하스켈과 비슷하게 타입 선언을 먼저 두고, 커링도 활용하며, 패턴 매칭으로 메시지를 받아서 처리하는 코드입니다. 저같은 아마츄어가 프론트엔드 개발을 하려할 때, 꽤 든든한 힘을 입어 개발할 수 있어서 좋은데요, 다른 분들의 관심은 적은 언어라는 아쉬움이 있네요. 개인 단독 프로젝트를 진행할 때 이따금 사용할 것 같습니다.

### 프론트엔드 프로그래밍 | (2) TypeScript

아마도, 제가 프론트엔드 개발을 조금 더 기웃거린다면, [타입스크립트(TypeScript)](https://www.typescriptlang.org)를 많이 활용할 것 같습니다. 이제 정적 타입 언어가 더 친숙해지기도 했고, 타입스크립트를 활용하는 사람은, 제가 사용하는 마이너 언어들에 비해 대단히 많기 때문에, 많은 분들과 소통하기에는 타입스크립트가 가장 적절하지 않나 생각하고 있습니다.

```typescript
function reorderFace(from: (n: number) => number): FaceFunc {
  return (face: Face) => {
    const target = face.slice()
    face.forEach((x, n) => target[from(n)] = x)
    return target
  }
}

const clockwiseF = (x: number) => (7 * x + 6) % 10
const counterclockwiseF = (x: number) => (3 * x + 2) % 10
const halfTurnF = (x: number) => 8 - x

const clockwise = reorderFace(clockwiseF)
const counterclockwise = reorderFace(counterclockwiseF)
const halfTurn = reorderFace(halfTurnF)
```

최근 작업 중인, 사이드 프로젝트의 코드 일부를 가져와 보았습니다. 자바스크립트(JavaScript)와 거의 같은데, 중간중간 타입을 선언하는 점이 큰 차이점입니다. 제가 쓰는 글에서 코드로 무언가를 설명해야 할 때, 타입스크립트를 주로 써봐야겠다고 생각하고 있습니다.

## 반갑습니다

이상, 함수형 프로그래밍과 사이드 프로젝트라는 두가지 관심사를 말씀드리면서, 장황한 소개를 적어보았습니다. 글로나마 다른 개발자분들과 서로 좋은 긍정적 힘 주고받으며 지내면 좋겠습니다.언젠가 오프라인에서 만나면 더 반가울 것 같습니다.



---

<a href="https://link.coupang.com/a/s8JaL" target="_blank" referrerpolicy="unsafe-url"><img src="https://image12.coupangcdn.com/image/affiliate/banner/346869365af4b3303e6792037b306c68@2x.jpg" alt="해커와 화가, 한빛미디어" width="120" height="240"></a>

위 링크를 통해 "해커와 화가"를 구매하시면, 이에 따른 일정액의 수수료를 제가 받게됩니다. 감사합니다.
