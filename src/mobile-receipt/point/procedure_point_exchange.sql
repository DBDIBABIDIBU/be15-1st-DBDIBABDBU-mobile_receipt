/*
프로시저: SP_POINT_EXCHANGE
목적: 포인트를 사용하여 상품 교환
작성자: 박양하
파라미터:
    - P_USER_ID: 사용자 ID
    - P_POINT_PRODUCT_ID: 교환할 상품 ID
    - P_QUANTITY: 교환 수량
반환: 없음
에러:
    - 45000: 비즈니스 로직 위반
    - 기타: SQL 오류
*/

-- ----------------------------------------------------------------
-- 비즈니스 로직
-- 1) 상품 존재 여부 및 가격 확인
-- 2) 상품 재고 확인
-- 3) 물품 교환을 위한 총 필요 포인트 계산 (포인트 가격 * 교환 수량)
-- 4) 포인트 차감 (sp_manage_point 프로시저 사용)
-- 5) 상품 재고 차감
-- 6) 교환 이력 기록
-- ----------------------------------------------------------------
-- 변경 이력
-- 2025-02-13 박양하 변경사항
-- - 트랜잭션 밖에서 검증 로직 수행하도록 변경
-- - 에러 메세지 상세화
-- - DB 컨벤션에 맞게 코드 리팩토링
-- 
-- 사유:
-- 1) 성능 최적화
-- 2) 트랜잭션 범위 최소화
-- 3) 검증 로직을 트랜잭션 밖으로 이동
-- 4) 불필요한 트랜잭션 오버헤드 제거
-- 5) 데이터베이스 리소스 사용 효율화
-- 6) DB 컨벤션 준수
-- ----------------------------------------------------------------
-- 2025-02-12 박양하 최초 커밋

DELIMITER $$

CREATE PROCEDURE SP_POINT_EXCHANGE (
    IN P_USER_ID VARCHAR(30),
    IN P_POINT_PRODUCT_ID BIGINT,
    IN P_QUANTITY INT
)
BEGIN
    DECLARE V_TOTAL_PRICE INT;
    DECLARE V_CURRENT_STOCK INT;
    DECLARE V_PRODUCT_PRICE INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1
            @SQL_STATE = RETURNED_SQLSTATE,
            @ERROR_NO = MYSQL_ERRNO,
            @MESSAGE = MESSAGE_TEXT;
        
        SET @ERROR_MESSAGE = COALESCE(
            @MESSAGE,
            'Point exchange failed'
        );
        
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = @ERROR_MESSAGE;
    END;

    /* 트랜잭션 외부 검증 */
    IF COALESCE(P_QUANTITY, 0) <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantity must be greater than 0';
    END IF;

    /* 상품 존재 여부 및 가격 확인 */
    SELECT A.PRICE
         , A.QUANTITY 
      INTO V_PRODUCT_PRICE
         , V_CURRENT_STOCK
      FROM POINT_PRODUCT A
     WHERE A.POINT_PRODUCT_ID = P_POINT_PRODUCT_ID
       AND A.DELETED_AT IS NULL;

    IF V_PRODUCT_PRICE IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product not found';
    END IF;

    /* 재고 확인 */
    IF V_CURRENT_STOCK < P_QUANTITY THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough stock';
    END IF;

    /* 총 필요 포인트 계산 */
    SET V_TOTAL_PRICE = V_PRODUCT_PRICE * P_QUANTITY;

    START TRANSACTION;

    /* 포인트 차감 프로시저 호출 */
    CALL SP_MANAGE_POINT(
        P_USER_ID,
        NULL,         /* receipt_id는 NULL (포인트 상품 교환은 영수증 없음) */
        '사용',
        V_TOTAL_PRICE,
        NULL,         /* reference_point_id */
        NULL          /* payment_amount (포인트 사용이므로 0) */
    );

    /* 상품 재고 차감 */
    UPDATE POINT_PRODUCT A
       SET A.QUANTITY = A.QUANTITY - P_QUANTITY
         , A.MODIFIED_AT = NOW()
     WHERE A.POINT_PRODUCT_ID = P_POINT_PRODUCT_ID;

    /* 교환 이력 기록 */
    INSERT INTO POINT_EXCHANGE_HISTORY 
    (
      USER_ID
    , POINT_PRODUCT_ID
    , QUANTITY
    , CREATED_AT
    ) 
    VALUES 
    (
      P_USER_ID
    , P_POINT_PRODUCT_ID
    , P_QUANTITY
    , NOW()
    );

    COMMIT;
END $$

DELIMITER ;
