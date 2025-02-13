/*
테스트 케이스: POINT_EXCHANGE 관리
목적: 포인트 상품 교환 프로시저 테스트
작성자: 박양하

변경 이력:
2025-02-14 박양하
- 최초 작성
*/

/* 1. 테스트 데이터 초기화 */
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE POINT_EXCHANGE_HISTORY;
TRUNCATE TABLE POINT_PRODUCT;
TRUNCATE TABLE POINT;
TRUNCATE TABLE USER;
SET FOREIGN_KEY_CHECKS = 1;

/* 테스트용 사용자 생성 */
INSERT INTO USER (USER_ID, REMAINING_POINT) 
VALUES ('test_user', 10000);

/* 테스트용 포인트 상품 생성 */
INSERT INTO POINT_PRODUCT 
(
    POINT_PRODUCT_ID
  , PRODUCT_NAME
  , PRICE
  , QUANTITY
  , DELETED_AT
) 
VALUES 
(1, '테스트 상품 1', 1000, 10, NULL),    /* 정상 상품 */
(2, '테스트 상품 2', 500, 0, NULL),      /* 재고 없음 */
(3, '테스트 상품 3', 2000, 5, NOW());    /* 삭제된 상품 */

/* 1. 성공 케이스 */

/* Case 1: 정상 - 포인트 상품 교환 */
CALL SP_POINT_EXCHANGE(
    'test_user'     /* user_id */
  , 1              /* point_product_id */
  , 2              /* quantity */
);

/* 2. 실패 케이스 */

/* Case 2: 실패 - 존재하지 않는 상품 */
CALL SP_POINT_EXCHANGE(
    'test_user'
  , 999
  , 1
);

/* Case 3: 실패 - 재고 부족 */
CALL SP_POINT_EXCHANGE(
    'test_user'
  , 2
  , 1
);

/* Case 4: 실패 - 삭제된 상품 */
CALL SP_POINT_EXCHANGE(
    'test_user'
  , 3
  , 1
);

/* Case 5: 실패 - 수량 0 또는 음수 */
CALL SP_POINT_EXCHANGE(
    'test_user'
  , 1
  , 0
);

/* Case 6: 실패 - 포인트 부족 */
CALL SP_POINT_EXCHANGE(
    'test_user'
  , 1
  , 100
);

/* 테스트 결과 확인 */
SELECT A.USER_ID
     , A.REMAINING_POINT 
  FROM USER A
 WHERE A.USER_ID = 'test_user';

SELECT A.POINT_PRODUCT_ID
     , A.PRODUCT_NAME
     , A.PRICE
     , A.QUANTITY
  FROM POINT_PRODUCT A
 WHERE A.DELETED_AT IS NULL;

SELECT A.USER_ID
     , A.POINT_PRODUCT_ID
     , A.QUANTITY
     , A.CREATED_AT
  FROM POINT_EXCHANGE_HISTORY A
 ORDER BY A.CREATED_AT DESC;

SELECT A.USER_ID
     , A.TRANSACTION_TYPE
     , A.POINT
     , A.IS_CANCELED
  FROM POINT A
 WHERE A.USER_ID = 'test_user'
 ORDER BY A.CREATED_AT DESC;