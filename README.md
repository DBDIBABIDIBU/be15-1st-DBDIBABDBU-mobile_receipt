<div align="center">

![header](https://capsule-render.vercel.app/api?type=venom&color=0:4374D9,100:A566FF&height=200&section=header&text=Welcome%20To%20Billon&fontSize=70)

<h1>😈 저희 BILLon이 환경오염에 맞서 싸우는 빌런이 되겠습니다! 🛡️</h1>
<h3>- 모바일 영수증으로 세상을 슬기롭게 -</h3>

</div>
<div align="center">
<a href="https://share.descript.com/view/bOhnBZC4LmI">
  <img src="https://img.shields.io/badge/Descript-프로젝트_소개_영상-blue" alt="프로젝트 소개 영상 보기">
</a>
</div>

### 🔍 목차

<table>
  <tr>
    <td>
      <details open>
        <summary><b>1. Hello World! 👋</b></summary>
        <ul>
          <li><a href="#team">Team DB디바비디부 🪄</a></li>
          <li><a href="#project">Our Project 📹</a></li>
        </ul>
      </details>
    </td>
  </tr>
  <tr>
    <td>
      <details open>
        <summary><b>2. Project Result 🗂️</b></summary>
        <ul>
          <li><a href="#wbs">WBS 📝</a></li>
          <li><a href="#gantt">Gantt Chart 📊</a></li>
          <li><a href="#requirements">요구사항 명세서 📣</a></li>
          <li><a href="#table-spec">테이블 명세서 📋</a></li>
          <li><a href="#usecase">Usecase 👤</a></li>
          <li><a href="#erd">ERD 📌</a></li>
          <li><a href="#process-flow">핵심 로직 플로우차트 🎖️</a></li>
          <li><a href="#test-cases">테스트 케이스 🧪</a>
            <ul>
              <li>일반 테스트</li>
              <li>영수증 관련 테스트</li>
            </ul>
          </li>
        </ul>
      </details>
    </td>
  </tr>
  <tr>
    <td>
      <details open>
        <summary><b>3. Our Playground 🗂️</b></summary>
        <ul>
          <li><a href="#Our-Playground">Notion Page Link 📓</a></li>
        </ul>
      </details>
    </td>
  </tr>
</table>

<br>

## <span id="team">🪄 Team DB디바비디부</span>

<div align="center">

|                                **김태인**                                |                                **박성용**                                |                                **박양하**                                |
| :----------------------------------------------------------------------: | :----------------------------------------------------------------------: | :----------------------------------------------------------------------: |
| <img src="./assets/profile_pic/태인프로필.jpg" width="180" height="180"> | <img src="./assets/profile_pic/성용프로필.jpg" width="180" height="180"> | <img src="./assets/profile_pic/양하프로필.png" width="180" height="180"> |
|                [@Taein5415](https://github.com/Taein5415)                |              [@develup-psy](https://github.com/develup-psy)              |                  [@64etuor](https://github.com/64etuor)                  |
|                                 **PSY**                                  |                               **C-Dragon**                               |                             **에임핵 냥꾼**                              |

|                                **장건희**                                |                                **장현영**                                |                                **하채린**                                |
| :----------------------------------------------------------------------: | :----------------------------------------------------------------------: | :----------------------------------------------------------------------: |
| <img src="./assets/profile_pic/건희프로필.png" width="180" height="180"> | <img src="./assets/profile_pic/현영프로필.png" width="180" height="180"> | <img src="./assets/profile_pic/채린프로필.jpg" width="180" height="180"> |
|                 [@jang9465](https://github.com/jang9465)                 |                 [@memory-h](https://github.com/memory-h)                 |                   [@didiha](https://github.com/didiha)                   |
|                               **쁘띠건희**                               |                                 **장PM**                                 |                             **안방 갱스터**                              |

</div>

<br>

## <span id="project">📹 Our Project</span>

### <span id="tech-stack">💻 기술 스택</span>

<div align="center">
  <img src="https://img.shields.io/badge/mariaDB-003545?style=for-the-badge&logo=mariaDB&logoColor=white">
  <img src="https://img.shields.io/badge/linux-FCC624?style=for-the-badge&logo=linux&logoColor=black">
  <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white">
  <img src="https://img.shields.io/badge/git-F05032?style=for-the-badge&logo=git&logoColor=white">
</div>

<br>
<h5>프로젝트 목적</h5>
본 프로젝트는 종이 영수증이 환경 오염의 주요 원인임을 인식하고, 이를 해결하기 위해 모바일 영수증 통합 관리 시스템을 구축하고자 합니다. 소비자와 판매자가 모두 편리하게 이용할 수 있는 이 시스템은 다양한 기능을 제공하여 종이 영수증 사용을 최소화하고, 환경 보호에 기여하는 것을 목표로 합니다.
  <br><br>
 주요 기능으로는 모바일 영수증 발행 및 통합 관리, 간편한 리뷰 작성, 포인트 적립 및 리워드 시스템, 영수증 조회, 소비 패턴 분석, 매장별 데이터 분석 등이 있으며, 이를 통해 사용자들은 보다 스마트하고 친환경적인 소비를 실현할 수 있습니다.
 <br><br>
<details>
    <summary><b>🔍프로젝트 기획안 자세히 보기</b></summary>
    <div markdown="1">
<h1>1. 개요</h1>

## 1-1. 배경

<center>
<img src="./assets/proposal/p1.png" alt="p1" style="width: 80%; height: auto;">
</center>
현재 종이 영수증은 환경 오염의 주요 원인 중 하나로, 매년 수십억 장이 발행되며 엄청난 양의 종이 낭비와 탄소 배출을 초래하고 있습니다. 대부분의 종이 영수증은 BPA(비스페놀 A) 등의 유해 화학물질을 포함하고 있어 재활용이 불가능하며, 결국 환경 오염으로 이어집니다.

대한민국 정부도 이러한 문제를 인식하여 2020년 민간 업체들과 협업하여 종이 영수증을 전자 영수증으로 관리하는 통합 플렛폼을 구축하는 프로젝트를 진행하였으나, 민간 업체들과의 통합이 진행되지 않아 개별적으로 서비스를 제공하는 형태로 자리잡았으며, 이는 소비자들로 하여금 여러가지 제휴사에 대한 어플을 각각 다운받아야 하는 번거로움을 야기하였습니다.

이로 인해 소비자들은 아직도 종이 영수증과 SMS 알림에 익숙한 형태를 보이고 있습니다.

<center>
<img src="./assets/proposal/p2.png" alt="p2" style="width: 80%; height: auto;">
</center>

## 1-2. 문제점 및 해결방안

### 1-2-1. 소비자 관점에서의 문제점 및 해결방안

| 문제점                                                 | 해결 방안                                                                                  |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| **여러 개의 영수증 앱을 설치해야 하는 불편함**         | 개별 업체 별 앱이 아닌 **통합 플랫폼 제공**으로 하나의 앱에서 다양한 제휴사 영수증을 관리  |
| **QR 코드 스캔 방식의 번거로움**                       | QR 코드 대신 **전화번호 입력 방식** 도입으로 간편하게 영수증 수령 가능                     |
| **소비자가 자신의 소비 패턴을 한눈에 파악하기 어려움** | **소비 데이터 분석 기능**을 제공하여 월 별 소비 패턴 및 소비 총량을 시각화된 리포트로 제공 |

### 1-2-2. 판매자 관점에서의 문제점 및 해결방안

또한 현재 **교환·환불 시 영수증을 반드시 지참 해야 하는 관행**이 여전히 남아 있으며, **전자 문서 법 상 모바일 영수증도 법적 효력을 가지지만 법적인 강제성이 없어 판매자들이 이를 인정하지 않는 문제**가 발생하고 있습니다.

> 전자문서법 요약
>
> ##### 목적
>
> 전자문서와 전자거래의 법적 효력을 인정하고, 그 안전성 및 신뢰성 확보를 목적으로 합니다.
>
> ##### 핵심 내용
>
> 1. **전자문서 효력**
>    - 전자문서는 **종이 문서와 동일한 법적 효력**을 가집니다.
> 2. **서면 요건**
>    - 전자문서는 특정 조건을 만족하면 서면으로 인정됩니다.
>    - 단, 다른 법령에 특별한 규정이 있거나 성질상 전자적 형태가 허용되지 않는 경우 제외.
> 3. **보관 기간**
>    - 전자문서는 **5년간 보관** 후 파기해야 합니다.
> 4. **전자거래**
>    - 전자적 방식으로 이루어지는 재화 및 용역 거래입니다.

이러한 문제로 인해 소비자들은 여전히 종이 영수증을 요구 받으며, 모바일 영수증의 활성화가 어려운 상황입니다. 따라서 판매자의 참여를 유도하기 위해 다음과 같은 솔루션을 제공합니다.

| 문제점                                                          | 해결 방안                                                                                            |
| --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **소상공인들은 기존 POS 시스템과 연동 부담이 큼**               | **간편한 API 및 웹 기반 솔루션** 제공으로 부담 최소화 및 손쉬운 도입 가능                            |
| **모바일 영수증을 인정하지 않는 판매자가 많음**                 | **판매자에게 법적 근거 및 모바일 영수증 활용 가이드 제공**, 소비자 편의성 증대를 통한 매출 증대 유도 |
| **판매자가 매출 및 영수증 데이터를 효과적으로 관리하기 어려움** | **매출 및 영수증 데이터 분석 기능** 제공하여 월별 총 판매 금액, 일별 평균 판매량 등의 데이터 제공    |

환경 오염 문제 해결을 위한 친환경 모바일 영수증 시스템을 구축함으로써 불필요한 종이 사용을 줄이고, 환경 보호에 실질적으로 기여하는 동시에, 기존 모바일 영수증 시스템의 한계를 극복하여 소비자와 가맹점 모두에게 최적화된 사용자 중심의 친환경 솔루션을 제공하는 저희는 다음과 같은 기능을 제공합니다.
<br>

# 2. 주요 기능 소개

## 2-1. 모바일 영수증 발행 및 통합 관리

| <img src="./assets/proposal/p3.png" style="width: 200px; height: auto;"> | "단 하나의 앱으로 모든 영수증 통합 관리"<br><br>회원 결제 시 전화번호 입력만으로 모바일 영수증이 자동 발급되도록 구현하며 개별 가맹점 또는 카드사별 앱을 따로 설치할 필요 없이 하나의 플랫폼에서 모든 영수증을 확인하고<br>관리할 수 있는 기능을 제공합니다. 영수증은 자동 저장되며, 검색 필터 및 카테고리별 정리 기능을 제공하여 관리의<br>편의성을 극대화합니다. |
| ------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

<br>

## 2-2. 모바일 영수증을 통한 리뷰 작성

| "영수증 촬영 및 첨부 없이 간편하게 리뷰 작성"<br><br>기존의 리뷰 작성 방식에서는 영수증을 촬영하고 첨부하는 번거로운 과정이 필요했지만, 본 서비스는 모바일 영수증을 기반으로 간편하게 리뷰를 작성할 수 있도록 지원합니다. 가맹점은 작성된 리뷰에 직접 답변할 수 있으며, 신뢰도 높은 리뷰는 상단에 노출되는 기능을 제공합니다. | <img src="./assets/proposal/p4.png" style="width: 600px; height: auto;"> |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | ------------------------------------------------------------------------ |

<br>

## 2-3. 포인트 적립 및 리워드 시스템

| <img src="./assets/proposal/p5.png" style="width: 200px; height: auto;"> | "환경도 지키고, 지갑도 지키는 스마트한 소비"<br><br>모바일 영수증을 선택한 사용자에겐 자동으로 환경 보호 포인트 적립 혜택을 제공하며 적립된 포인트는 에코백, 일반쓰레기 봉투, 상품권, 기프트 카드 등의 물품 교환으로 사용이 가능합니다. |
| ------------------------------------------------------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

<br><br>

## 2-4. 영수증 조회

| "필요한 영수증을 쉽고 빠르게 검색 및 관리"<br><br>발행된 영수증을 날짜, 금액, 결제 수단, 가맹점 등 다양한 기준으로 필터링하여 조회할 수 있는 기능을 제공하며 이를 통해 회원은 특정 소비 영역의 지출 내역을 직관적으로 확인할 수 있습니다. | <img src="./assets/proposal/p6.png" style="width: 200px; height: auto;"> |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | ------------------------------------------------------------------------ |

<br>

## 2-5. 소비 패턴 분석을 통한 맞춤형 지출 관리

| <img src="./assets/proposal/p7.png" style="width: 250px; height: auto;"> | "개인별 소비 패턴을 한눈에 분석 및 관리"<br><br>회원의 소비 패턴을 분석하여 월별 소비 추이, 동일 연령대 평균 지출 대비 분석, 카테고리별 소비 비중에 대한 정보를 제공합니다. 이를 통해 회원은 시각적으로 한번에 소비 증가율 또는 절감율을 파악할 수 있습니다. |
| ------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |

<br>

## 2-6. 매장별 데이터 분석 및 가맹점 지원

| "영수증 데이터를 활용한 스마트한 매장 운영"<br><br>가맹점은 영수증 데이터를 바탕으로 기간별 매출 및 판매량 분석 기능을 제공하여 매장 운영 최적화에 대한 지원을 제공합니다. 또한 소비 패턴 데이터를 기반으로 인기 상품 및 기간별 판매 데이터를 분석하여 재고 관리와 프로모션 운영에 대한 솔루션을 제공하여 효율적인 매장 운영을 가능케 합니다. | <img src="./assets/proposal/p8.png" style="width: 300px; height: auto;"> |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | ------------------------------------------------------------------------ |

   </div>
</details>

<br><br>

<h1 id="project-result">🗂️ 프로젝트 산출물</h1>

<h3 id="wbs">📝 WBS (Work Breakdown Structure)</h3>
<details>
    <summary><b>WBS 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/wbs.png" alt="WBS" style="width: 80%; height: auto;">
        <br>
        <a href="https://www.notion.so/WBS-1972fdb1414880e5927bfca57c78818e" target="_blank">
            <b>🔗 WBS 상세 문서 보기</b>
        </a>
    </div>
</details>

<h3 id="gantt">📊 Gantt Chart</h3>
<details>
    <summary><b>Gantt Chart 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/gantt.png" alt="Gantt Chart" style="width: 80%; height: auto;">
    </div>
</details>

<h3 id="requirements">📣 요구사항 명세서</h3>
<details>
    <summary><b>요구사항 명세서 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/요구사항명세서.png" alt="요구사항 명세서" style="width: 80%; height: auto;">
    </div>
</details>

<h3 id="table-spec">📋 테이블 명세서</h3>
<details>
    <summary><b>테이블 명세서 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/table_spec.png" alt="테이블 명세서" style="width: 80%; height: auto;">
    </div>
</details>

<h3 id="usecase">👤 Usecase</h3>
<details>
    <summary>Usecase 자세히 보기</summary>
    <div markdown="1">
        <img src="./assets/usecase.png" alt="usecase" style="max-width: 100%; height: auto;">    
    </div>
</details>

<h3 id="erd">📌 ERD</h3>
<details>
    <summary>ERD Cloud 자세히 보기</summary>
    <div markdown="1">
        <img src="./assets/erdcloud.png" alt="ERD Diagram" style="max-width: 100%; height: auto;">
    </div>
</details>

```mermaid
erDiagram

    authority {
        INT authority_id PK
        VARCHAR authority_name
    }

    category {
        BIGINT category_id PK
        VARCHAR category_name
        TIMESTAMP created_at
        TIMESTAMP modified_at
        TIMESTAMP deleted_at
    }

    user {
        VARCHAR user_id PK
        INT authority_id FK
        VARCHAR password
        VARCHAR contact_number
        VARCHAR email
        INT age
        VARCHAR gender
        VARCHAR profile_image_url
        VARCHAR is_alarm_enabled
        VARCHAR is_consent_provided
        VARCHAR account_status
        INT reported_count
        TIMESTAMP created_at
        TIMESTAMP modified_at
        TIMESTAMP deleted_at
        FLOAT remaining_point
    }

    store {
        BIGINT store_id PK
        VARCHAR user_id FK
        BIGINT category_id FK
        VARCHAR business_registration_number
        VARCHAR business_operation_certificate_url
        VARCHAR store_name
        VARCHAR contact_number
        VARCHAR address
        VARCHAR address_detail
        VARCHAR business_hours
        FLOAT average_rating
        TIMESTAMP created_at
        TIMESTAMP modified_at
        TIMESTAMP deleted_at
    }

    notification_type {
        BIGINT notification_type_id PK
        VARCHAR notification_message
    }

    report_type {
        BIGINT report_type_id PK
        VARCHAR name
        TIMESTAMP created_at
        TIMESTAMP modified_at
        TIMESTAMP deleted_at
    }

    card_company {
        BIGINT card_company_id PK
        VARCHAR card_company_name
        TIMESTAMP created_at
        TIMESTAMP modified_at
        TIMESTAMP deleted_at
    }

    receipt {
        BIGINT receipt_id PK
        VARCHAR user_id FK
        BIGINT store_id FK
        BIGINT card_company_id FK
        VARCHAR receipt_body
        INT amount
        VARCHAR payment_method
        VARCHAR transaction_status
        VARCHAR is_canceled
        TIMESTAMP created_at
        TIMESTAMP deleted_at
    }

    review {
        BIGINT review_id PK
        VARCHAR user_id FK
        BIGINT store_id FK
        VARCHAR content
        INT rating
        TIMESTAMP created_at
        TIMESTAMP modified_at
        TIMESTAMP deleted_at
    }

    comment {
        BIGINT comment_id PK
        VARCHAR user_id FK
        BIGINT review_id FK
        VARCHAR content
        TIMESTAMP created_at
        TIMESTAMP modified_at
        TIMESTAMP deleted_at
    }

    review_like {
        BIGINT like_id PK
        BIGINT review_id FK
        VARCHAR user_id FK
        TIMESTAMP created_at
    }

    review_image {
        BIGINT review_image_id PK
        BIGINT review_id FK
        VARCHAR review_image_url
    }

    point {
        BIGINT point_id PK
        VARCHAR user_id FK
        BIGINT reference_point_id FK
        BIGINT receipt_id FK
        VARCHAR transaction_type
        INT point
        TIMESTAMP created_at
        VARCHAR is_canceled
    }

    point_exchange_history {
        BIGINT point_exchange_id PK
        VARCHAR user_id FK
        BIGINT point_product_id FK
        INT quantity
        TIMESTAMP created_at
    }

    favorite {
        BIGINT favorite_id PK
        VARCHAR user_id FK
        BIGINT store_id FK
        TIMESTAMP created_at
        TIMESTAMP deleted_at
    }

    store_image {
        BIGINT store_image_id PK
        BIGINT store_id FK
        VARCHAR store_image_url
    }

    login_history {
        BIGINT login_history_id PK
        VARCHAR user_id FK
        TIMESTAMP login_at
        VARCHAR ip_address
        VARCHAR device_type
    }

    report {
        BIGINT report_id PK
        BIGINT report_type_id FK
        VARCHAR user_id FK
        BIGINT comment_id FK
        BIGINT review_id FK
        VARCHAR report_comment
        TIMESTAMP created_at
    }

    penalty_history {
        BIGINT penalty_history_id PK
        VARCHAR user_id FK
        VARCHAR admin_id FK
        VARCHAR penalty_reason
        TIMESTAMP start_penalty_at
        TIMESTAMP end_penalty_at
    }

    notification_history {
        BIGINT notification_history_id PK
        BIGINT notification_type_id FK
        VARCHAR user_id FK
        TIMESTAMP read_at
        TIMESTAMP created_at
    }

    authority ||--|{ user : has
    category ||--|{ store : has
    user ||--|{ store : owns
    user ||--|{ receipt : makes
    user ||--|{ review : writes
    user ||--|{ comment : writes
    user ||--|{ review_like : likes
    user ||--|{ point : earns
    user ||--|{ point_exchange_history : exchanges
    user ||--|{ favorite : marks
    user ||--|{ login_history : logs
    user ||--|{ report : reports
    user ||--|{ penalty_history : penalized
    user ||--|{ notification_history : receives
    store ||--|{ review : has
    store ||--|{ favorite : liked
    store ||--|{ store_image : has
    store ||--|{ receipt : generates
    review ||--|{ comment : has
    review ||--|{ review_like : liked
    review ||--|{ review_image : has
    review ||--|{ report : reported
    comment ||--|{ report : reported
    receipt ||--|{ point : generates
    receipt ||--|{ card_company : paid_with
    report_type ||--|{ report : classified
    notification_type ||--|{ notification_history : has

```

<i><center><u>mermaid로 표현한 ERD</u></center></i>

<h3 id="process-flow">🎖️ 핵심 로직 플로우차트</h3>

<h4>1. 영수증 발행 프로세스</h4>
프로시저 세부 다이어그램은 <code>./src/mobile-receipt/point/</code> 경로의 다어어그램 참조
<br><br>

```mermaid
flowchart TD
    A[시작: SP_ISSUE_RECEIPT] --> B[입력값 검증]
    B --> C[사용자 검증<br/>SP_VALIDATE_USER]

    C --> D[중복 거래 검증<br/>SP_VALIDATE_DUPLICATE_RECEIPT]
    D --> E{중복 거래?}
    E -->|Yes| F[에러: 중복 거래]
    E -->|No| G[START TRANSACTION]

    G --> H[영수증 발행<br/>RECEIPT 테이블]
    H --> I[포인트 적립<br/>SP_POINT_EARN]
    I --> J[COMMIT]
    J --> K[종료]

    %% 에러 처리
    F --> L[에러 발생]
    H -->|실패| M[ROLLBACK]
    I -->|실패| M
    M --> L

```

<h4>2. 영수증 취소 프로세스</h4>
프로시저 세부 다이어그램은 <code>./src/mobile-receipt/point/</code> 경로의 다어어그램 참조
<br><br>

```mermaid
flowchart TD
    A[시작: SP_CANCEL_RECEIPT] --> B[원본 영수증 검증<br/>SP_VALIDATE_RECEIPT]
    B --> C[사용자 검증<br/>SP_VALIDATE_USER]

    C --> D[원본 포인트 내역 조회]
    D --> E{포인트 내역 존재?}
    E -->|No| F[에러: 포인트 내역 없음]
    E -->|Yes| G[START TRANSACTION]

    G --> H[원본 영수증 취소 처리<br/>RECEIPT 테이블]
    H --> I[포인트 취소<br/>SP_POINT_CANCEL]
    I --> J[COMMIT]
    J --> K[종료]

    %% 에러 처리
    F --> L[에러 발생]
    H -->|실패| M[ROLLBACK]
    I -->|실패| M
    M --> L

```

<br>

<h3 id="test-cases">🧪 테스트 케이스</h3>

<h4>일반 테스트</h4>
<details>
    <summary><b>고객 유형 분석 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/etc/고객유형분석.gif" alt="고객 유형 분석 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>매장 매출 분석 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/etc/매장매출분석.gif" alt="매장 매출 분석 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>베스트 리뷰 선정 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/etc/베스트리뷰선정.gif" alt="베스트 리뷰 선정 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>베스트 리뷰 알림 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/etc/베스트리뷰알림.gif" alt="베스트 리뷰 알림 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>시간대별 분석 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/etc/시간대별분석.gif" alt="시간대별 분석 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>영수증 발행 알림 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/etc/영수증발행알림.gif" alt="영수증 발행 알림 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>요일별 분석 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/etc/요일별분석.gif" alt="요일별 분석 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<h4>영수증 관련 테스트</h4>
<details>
    <summary><b>초기 데이터 확인 및 프로시저 등록 확인 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/01_초기데이터 확인, 프로시저 등록 확인.gif" alt="초기 데이터 확인 및 프로시저 등록 확인 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>영수증 발행 및 포인트 적립 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/02_영수증 발행, 포인트 적립.gif" alt="영수증 발행 및 포인트 적립 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>포인트 물품 교환(사용) 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/03_포인트 물품 교환(사용).gif" alt="포인트 물품 교환(사용) 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>영수증 취소 및 포인트 적립 취소 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/04_영수증 취소, 포인트 적립 취소.gif" alt="영수증 취소 및 포인트 적립 취소 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>에러 테스트 - 잔여 포인트 초과 물품 구매 시도 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/05_에러_잔여 포인트 초과 물품 구매 시도.gif" alt="에러 테스트 - 잔여 포인트 초과 물품 구매 시도 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>에러 테스트 - 재고 초과 수량 구매 시도 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/06_에러_재고 초과 수량 구매 시도.gif" alt="에러 테스트 - 재고 초과 수량 구매 시도 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>에러 테스트 - 이미 취소된 영수증 취소 재시도 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/07_이미 취소된 영수증 취소 재시도.gif" alt="에러 테스트 - 이미 취소된 영수증 취소 재시도 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>에러 테스트 - 10초 이내 중복 결제 시도 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/08_10초 이내 중복 결제 시도.gif" alt="에러 테스트 - 10초 이내 중복 결제 시도 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>

<details>
    <summary><b>결과 데이터 확인 테스트 상세보기</b></summary>
    <div markdown="1">
        <img src="./assets/test_case_gif/receipt/09_결과 데이터 확인.gif" alt="결과 데이터 확인 테스트 데모" style="max-width: 100%; height: auto;">    
    </div>
</details>
<br>
<br>
<h1 id="Our-Playground">🗂️ Our Playground</h1>
<a href="https://www.notion.so/be15_1st_Project_DB-5c52900ed26b42ad812641a28fe85249"><text><strong>| 📓 Notion Page Link |</text></strong></a><br><br>

<img src="./assets/scrum_meeting.jpg" style="width: 100%; height: auto;">
<center><i>매일 아침 8시 40분에 진행하는 Scrum Meeting</i></center>
