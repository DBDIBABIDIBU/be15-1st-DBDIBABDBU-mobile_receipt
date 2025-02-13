/*
프로시저: SP_POINT_EXCHANGE
목적: 포인트를 사용하여 상품 교환
작성자: 박양하

파라미터:
    - P_USER_ID: 사용자 ID
    - P_POINT_PRODUCT_ID: 교환할 상품 ID
    - P_QUANTITY: 교환 수량

처리 순서:
    1. 필수 파라미터 검증
    2. 사용자 검증
    3. 상품 검증 (재고 락 포함)
    4. 총 필요 포인트 계산
    5. 포인트 잔액 검증
    6. 포인트 사용
    7. 상품 재고 차감
    8. 교환 이력 기록

주의사항:
    - 재고 검증 시 SELECT FOR UPDATE로 락 설정
    - 모든 처리는 하나의 트랜잭션으로 관리

에러:
    - 45000: 비즈니스 로직 위반
    - 기타: SQL 오류

변경 이력:
2025-02-14 박양하
- 공통 프로시저 활용
- 재고 락 처리 추가
- 트랜잭션 관리 개선
*/

DELIMITER $$

CREATE PROCEDURE SP_POINT_EXCHANGE (
    IN P_USER_ID VARCHAR(30),
    IN P_POINT_PRODUCT_ID BIGINT,
    IN P_QUANTITY INT
)
BEGIN
    DECLARE V_TOTAL_PRICE INT;
    DECLARE V_CURRENT_STOCK INT;
    
    /* 1. 필수 파라미터 검증 */
    IF P_QUANTITY <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantity must be greater than 0';
    END IF;
    
    /* 2. 사용자 검증 */
    CALL SP_VALIDATE_USER(P_USER_ID);
    
    /* 트랜잭션 시작 */
    CALL SP_TRANSACTION_MANAGE('SP_POINT_EXCHANGE');
    
    /* 3. 상품 검증 (재고 락 포함) */
    SELECT A.PRICE
         , A.QUANTITY 
      INTO V_TOTAL_PRICE
         , V_CURRENT_STOCK
      FROM POINT_PRODUCT A
     WHERE A.POINT_PRODUCT_ID = P_POINT_PRODUCT_ID
       AND A.DELETED_AT IS NULL
     FOR UPDATE;
    
    IF V_TOTAL_PRICE IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product not found or deleted';
    END IF;

    IF V_CURRENT_STOCK < P_QUANTITY THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough stock';
    END IF;
    
    /* 4. 총 필요 포인트 계산 */
    SET V_TOTAL_PRICE = V_TOTAL_PRICE * P_QUANTITY;
    
    /* 5. 포인트 잔액 검증 */
    CALL SP_VALIDATE_POINT_BALANCE(P_USER_ID, V_TOTAL_PRICE);
    
    /* 6. 포인트 사용 */
    CALL SP_POINT_USE(
        P_USER_ID,
        V_TOTAL_PRICE,
        '상품교환'
    );
    
    /* 7. 상품 재고 차감 */
    UPDATE POINT_PRODUCT A
       SET A.QUANTITY = A.QUANTITY - P_QUANTITY
         , A.MODIFIED_AT = NOW()
     WHERE A.POINT_PRODUCT_ID = P_POINT_PRODUCT_ID;
    
    /* 8. 교환 이력 기록 */
    INSERT INTO POINT_EXCHANGE_HISTORY (
        USER_ID,
        POINT_PRODUCT_ID,
        QUANTITY,
        CREATED_AT
    ) VALUES (
        P_USER_ID,
        P_POINT_PRODUCT_ID,
        P_QUANTITY,
        NOW()
    );
    
    COMMIT;
END $$

DELIMITER ;