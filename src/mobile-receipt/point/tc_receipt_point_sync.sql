/* 
테스트 케이스 작성
작성자: 박양하
목적: 영수증 발행과 포인트 연동, 포인트 물품 교환 프로시저 테스트

테스트 시나리오:
1. 영수증 발행 및 포인트 적립
2. 포인트로 상품 교환
3. 영수증 취소 및 포인트 취소
4. 예외 케이스 테스트
   - 잔액 부족
   - 재고 부족
   - 중복 취소
   - 중복 결제
*/

-- 테스트용 데이터 생성
INSERT INTO authority (authority_id, authority_name) 
VALUES (1, 'USER');

INSERT INTO user (
    user_id, authority_id, password, user_name,
    contact_number, email, age, gender, remaining_point
) VALUES 
('test_user1', 1, 'password123', '테스트1', '01012341234', 'test1@test.com', 20, 'M', 1000),
('test_user2', 1, 'password123', '테스트2', '01012341235', 'test2@test.com', 25, 'F', 500);

INSERT INTO point_product (
    point_product_id, product_name, price, quantity,
    point_product_image_url, created_at, modified_at
) VALUES 
(1, '테스트상품1', 500, 10, 'http://test.com/image1.jpg', NOW(), NOW()),
(2, '테스트상품2', 1000, 5, 'http://test.com/image2.jpg', NOW(), NOW());

INSERT INTO card_company (card_company_id, card_company_name, created_at, modified_at) 
VALUES (1, '테스트카드사', NOW(), NOW());

INSERT INTO category (category_id, category_name, created_at, modified_at) 
VALUES (1, '테스트카테고리', NOW(), NOW());

INSERT INTO store (
    store_id, user_id, category_id, business_registration_number,
    store_name, contact_number, address, address_detail,
    business_hours, average_rating
) VALUES 
(1, 'test_user1', 1, '123-45-67890', '테스트매장', '02-123-4567', 
'서울시 강남구', '테스트빌딩', '09:00-18:00', 4.5);

-- 초기 상태 확인
SELECT U.user_id
     , U.user_name
     , U.remaining_point
  FROM user U
 ORDER BY U.user_id;

-- 1. 영수증 발행 및 포인트 적립 테스트
CALL SP_ISSUE_RECEIPT(
    'test_user1', 1, 1,
    '{"items": [{"name": "테스트상품", "price": 50000}]}',
    500000, '신용'
);

SELECT U.user_id
     , U.user_name
     , U.remaining_point
     , R.receipt_id
     , R.amount
     , R.transaction_status
     , R.is_canceled
     , P.point_id
     , P.transaction_type
     , P.point
     , P.is_canceled AS point_canceled
     , S.store_name
     , CC.card_company_name
  FROM user U
  LEFT JOIN receipt R ON U.user_id = R.user_id
  LEFT JOIN point P ON R.receipt_id = P.receipt_id
  LEFT JOIN store S ON R.store_id = S.store_id
  LEFT JOIN card_company CC ON R.card_company_id = CC.card_company_id
 WHERE U.user_id = 'test_user1'
   AND R.receipt_id = (SELECT MAX(receipt_id) FROM receipt);

-- 2. 포인트 사용 테스트
CALL SP_POINT_EXCHANGE('test_user1', 1, 1);

SELECT U.user_id
     , U.user_name
     , U.remaining_point
     , P.point_id
     , P.transaction_type
     , P.point
     , P.is_canceled
     , PEH.point_exchange_id
     , PP.product_name
     , PP.price AS product_price
     , PP.quantity AS remaining_stock
     , PEH.quantity AS exchange_quantity
     , PEH.created_at AS exchange_date
  FROM user U
  LEFT JOIN point P ON U.user_id = P.user_id
  LEFT JOIN point_exchange_history PEH ON U.user_id = PEH.user_id
  LEFT JOIN point_product PP ON PEH.point_product_id = PP.point_product_id
 WHERE U.user_id = 'test_user1'
   AND P.point_id = (SELECT MAX(point_id) FROM point);

-- 3. 포인트 취소 테스트
SELECT @receipt_id := MAX(receipt_id) 
  FROM receipt 
 WHERE user_id = 'test_user1' 
   AND is_canceled = 'N';

CALL SP_CANCEL_RECEIPT(@receipt_id);

SELECT U.user_id
     , U.user_name
     , U.remaining_point
     , R.receipt_id
     , R.amount
     , R.is_canceled
     , P.point_id
     , P.transaction_type
     , P.point
     , P.is_canceled AS point_canceled
     , P.reference_point_id
     , OP.transaction_type AS original_transaction_type
     , OP.point AS original_point
     , OP.is_canceled AS original_point_canceled
  FROM user U
  LEFT JOIN receipt R ON U.user_id = R.user_id
  LEFT JOIN point P ON R.receipt_id = P.receipt_id
  LEFT JOIN point OP ON P.reference_point_id = OP.point_id
 WHERE U.user_id = 'test_user1'
   AND R.receipt_id = @receipt_id;

-- 4. 에러 케이스 테스트
CALL SP_POINT_EXCHANGE('test_user2', 2, 1);
CALL SP_POINT_EXCHANGE('test_user1', 1, 100);
CALL SP_CANCEL_RECEIPT(@receipt_id);
-- 중복 결제 테스트 (10초 이내 동일 거래, 아래 코드 3줄 블락 후 Ctrl + F9)
CALL SP_ISSUE_RECEIPT('test_user1', 1, 1, '{"items": [{"name": "테스트상품", "price": 10000}]}', 10000, '신용');
DO SLEEP(1);
CALL SP_ISSUE_RECEIPT('test_user1', 1, 1, '{"items": [{"name": "테스트상품", "price": 10000}]}', 10000, '신용');


-- 최종 상태 확인
SELECT U.user_id
     , U.user_name
     , U.remaining_point
     , COUNT(DISTINCT R.receipt_id) AS total_receipts
     , COUNT(DISTINCT P.point_id) AS total_point_transactions
     , COUNT(DISTINCT PEH.point_exchange_id) AS total_exchanges
     , SUM(CASE WHEN P.transaction_type = '적립' AND P.is_canceled = 'N' THEN P.point ELSE 0 END) AS total_earned
     , SUM(CASE WHEN P.transaction_type = '사용' AND P.is_canceled = 'N' THEN P.point ELSE 0 END) AS total_used
  FROM user U
  LEFT JOIN receipt R ON U.user_id = R.user_id
  LEFT JOIN point P ON U.user_id = P.user_id
  LEFT JOIN point_exchange_history PEH ON U.user_id = PEH.user_id
 GROUP BY U.user_id, U.user_name, U.remaining_point
 ORDER BY U.user_id;

SELECT PP.point_product_id
     , PP.product_name
     , PP.price
     , PP.quantity AS current_stock
     , COUNT(PEH.point_exchange_id) AS total_exchanges
  FROM point_product PP
  LEFT JOIN point_exchange_history PEH ON PP.point_product_id = PEH.point_product_id
 GROUP BY PP.point_product_id, PP.product_name, PP.price, PP.quantity
 ORDER BY PP.point_product_id;
