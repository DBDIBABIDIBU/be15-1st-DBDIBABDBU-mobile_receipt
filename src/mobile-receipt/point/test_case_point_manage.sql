/*
테스트 케이스: POINT 관리
목적: 포인트 적립, 사용, 취소 프로시저 테스트
작성자: 박양하

변경 이력:
2025-02-14 박양하
- 불필요한 NULL 파라미터 제거
- 테스트 케이스 구조화 및 주석 개선
- 취소 테스트를 영수증 기반으로 수정
- 각 테스트 케이스의 의도를 명확히 기술
- 테스트 데이터 초기화 로직 추가

2025-02-13 박양하
- 최초 작성
*/

-- test_case_point_manage.sql
-- 테스트를 위한 초기 데이터 설정
/* 1. 기존 데이터 삭제 */
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE POINT_EXCHANGE_HISTORY;
TRUNCATE TABLE POINT;
TRUNCATE TABLE RECEIPT;
TRUNCATE TABLE STORE;
TRUNCATE TABLE USER;
TRUNCATE TABLE CATEGORY;
TRUNCATE TABLE AUTHORITY;
SET FOREIGN_KEY_CHECKS = 1;

/* 2. 테스트 데이터 생성 */

/* 2.1 AUTHORITY 생성 */
INSERT INTO AUTHORITY 
(
    AUTHORITY_ID
  , AUTHORITY_NAME
) 
VALUES 
(1, 'USER');

/* 2.2 CATEGORY 생성 */
INSERT INTO CATEGORY
(
    CATEGORY_ID
  , CATEGORY_NAME
  , CREATED_AT
  , MODIFIED_AT
)
VALUES
(
    1
  , '음식점'
  , NOW()
  , NOW()
);

/* 2.3 테스트용 USER 생성 */
INSERT INTO USER 
(
    USER_ID
  , AUTHORITY_ID
  , PASSWORD
  , USER_NAME
  , CONTACT_NUMBER
  , EMAIL
  , AGE
  , GENDER
  , PROFILE_IMAGE_URL
  , IS_ALARM_ENABLED
  , IS_CONSENT_PROVIDED
  , ACCOUNT_STATUS
  , CREATED_AT
  , MODIFIED_AT
  , REMAINING_POINT
) 
VALUES 
(
    'test_user'      /* user_id */
  , 1                /* authority_id */
  , 'test1234'       /* password */
  , '홍길동'          /* user_name */
  , '01012345678'    /* contact_number */
  , 'test@test.com'  /* email */
  , 25               /* age */
  , 'M'              /* gender */
  , 'https://billon.com/profile_image_test_url/'  /* profile_image_url */
  , 'N'              /* is_alarm_enabled */
  , 'N'              /* is_consent_provided */
  , '활성'            /* account_status */
  , NOW()            /* created_at */
  , NOW()            /* modified_at */
  , 1000             /* remaining_point */
);

/* 2.4 테스트용 STORE 생성 */
INSERT INTO STORE 
(
    STORE_ID
  , USER_ID
  , CATEGORY_ID
  , BUSINESS_REGISTRATION_NUMBER
  , STORE_NAME
  , CONTACT_NUMBER
  , ADDRESS
  , ADDRESS_DETAIL
  , BUSINESS_HOURS
  , AVERAGE_RATING
) 
VALUES 
(
    1
  , 'test_user'
  , 1
  , '123-45-67890'
  , '테스트 가게'
  , '02-123-4567'
  , '서울시 강남구'
  , '1층'
  , '09:00-18:00'
  , 4.5
);

/* 2.5 테스트용 RECEIPT 생성 */
INSERT INTO RECEIPT 
(
    RECEIPT_ID
  , USER_ID
  , STORE_ID
  , RECEIPT_BODY
  , AMOUNT
  , PAYMENT_METHOD
  , TRANSACTION_STATUS
  , IS_CANCELED
  , CREATED_AT
) 
VALUES 
(1001, 'test_user', 1, '{"items": [{"name": "테스트 상품", "price": 10000}]}', 10000, '현금', '승인', 'N', NOW()),
(1002, 'test_user', 1, '{"items": [{"name": "테스트 상품2", "price": 5000}]}', 5000, '현금', '승인', 'N', NOW()),
(1003, 'test_user', 1, '{"items": [{"name": "테스트 상품3", "price": 3000}]}', 3000, '현금', '승인', 'N', NOW());

-- 테스트 케이스 실행
/* 1. 성공 케이스 */

/* Case 1: 정상 - 포인트 적립 */
CALL SP_MANAGE_POINT(
    'test_user'     -- user_id
  , 1001           -- receipt_id
  , '적립'         -- transaction_type
  , NULL           -- point
  , NULL           -- reference_point_id
  , 10000          -- payment_amount
);
SELECT A.USER_ID
     , A.REMAINING_POINT 
  FROM USER A
 WHERE A.USER_ID = 'test_user';

-- Case 2: 정상 - 포인트 사용
CALL SP_MANAGE_POINT(
    'test_user', -- user_id
    NULL,         -- receipt_id 
    '사용',       -- transaction_type
    100,          -- point
    NULL,         -- reference_point_id
    NULL          -- payment_amount
);

SELECT A.USER_ID
     , A.REMAINING_POINT 
  FROM USER A
 WHERE A.USER_ID = 'test_user';

-- Case 3: 정상 - 포인트 취소
CALL SP_MANAGE_POINT(
    'test_user', -- user_id
    1001,            -- receipt_id
    '취소', -- transaction_type
    NULL, -- point
    @POINT_TO_CANCEL, -- reference_point_id
    NULL -- payment_amount
);

SELECT A.USER_ID
     , A.REMAINING_POINT 
  FROM USER A
 WHERE A.USER_ID = 'test_user';

-- 2. 실패 케이스

-- Case 4: 실패 - 존재하지 않는 사용자
CALL SP_MANAGE_POINT(
    'non_existing_user', -- user_id
    1001,               -- receipt_id
    '적립',              -- transaction_type
    NULL,               -- point
    NULL,               -- reference_point_id
    10000               -- payment_amount
);

-- Case 5: 실패 - 잘못된 거래 유형
CALL SP_MANAGE_POINT(
    'test_user',    -- P_USER_ID
    1001,           -- P_RECEIPT_ID
    '오류',         -- P_TRANSACTION_TYPE
    100,            -- P_POINT
    NULL,           -- P_REFERENCE_POINT_ID
    NULL            -- P_PAYMENT_AMOUNT
);

-- Case 6: 실패 - 보유 포인트 초과 사용
CALL SP_MANAGE_POINT(
    'test_user',    -- P_USER_ID
    NULL,           -- P_RECEIPT_ID - 사용시에는 NULL 가능
    '사용',         -- P_TRANSACTION_TYPE
    9999999,        -- P_POINT
    NULL,           -- P_REFERENCE_POINT_ID
    NULL            -- P_PAYMENT_AMOUNT
);

-- Case 7: 실패 - 존재하지 않는 원본 거래 취소
CALL SP_MANAGE_POINT(
    'test_user',    -- P_USER_ID
    NULL,           -- P_RECEIPT_ID
    '취소',         -- P_TRANSACTION_TYPE
    NULL,           -- P_POINT
    99999,          -- P_REFERENCE_POINT_ID - 존재하지 않는 ID
    NULL            -- P_PAYMENT_AMOUNT
);

-- Case 8: 실패 - 이미 취소된 거래 재취소
CALL SP_MANAGE_POINT(
    'test_user',    -- P_USER_ID
    1001,           -- P_RECEIPT_ID
    '취소',         -- P_TRANSACTION_TYPE
    NULL,           -- P_POINT
    @POINT_TO_CANCEL,  -- P_REFERENCE_POINT_ID - 이미 취소된 거래
    NULL            -- P_PAYMENT_AMOUNT
);

-- 테스트 결과 확인
SELECT user_id, remaining_point 
FROM `user` 
WHERE user_id = 'test_user';

SELECT p.point_id,
       p.user_id,
       p.receipt_id,
       p.transaction_type,
       p.point,
       p.reference_point_id,
       p.is_canceled,
       p.created_at
FROM point p
WHERE p.user_id = 'test_user'
ORDER BY p.created_at DESC;

