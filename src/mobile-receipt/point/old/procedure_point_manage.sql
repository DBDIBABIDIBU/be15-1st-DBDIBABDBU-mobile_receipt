/*
프로시저: SP_MANAGE_POINT
목적: 포인트 적립, 사용, 취소 관리
작성자: 박양하

파라미터:
    - P_USER_ID: 사용자 ID
    - P_RECEIPT_ID: 영수증 ID (적립 시 필수)
    - P_TRANSACTION_TYPE: 거래 유형 ('적립','사용','취소')
    - P_POINT: 포인트 금액 (사용 시 필수)
    - P_REFERENCE_POINT_ID: 취소 시 원본 거래 ID (취소 시 필수)
    - P_PAYMENT_AMOUNT: 결제 금액 (적립 시 필수)

처리 순서:
    [적립]
    1. 사용자 및 영수증 검증
    2. 포인트 적립 내역 생성
    3. 사용자 포인트 증가

    [사용]
    1. 사용자 및 잔액 검증
    2. 포인트 사용 내역 생성
    3. 사용자 포인트 차감

    [취소]
    1. 원본 포인트 거래 검증
    2. 포인트 취소 내역 생성
    3. 원본 거래 취소 처리
    4. 사용자 포인트 복원/차감

에러:
    - 45000: 비즈니스 로직 위반
    - 기타: SQL 오류

변경 이력:
2025-02-14 박양하
- 공통 프로시저 활용하도록 수정
- 트랜잭션 범위 최소화
- 검증 로직 분리
*/

DELIMITER $$

CREATE PROCEDURE SP_MANAGE_POINT(
    IN P_USER_ID VARCHAR(30),
    IN P_RECEIPT_ID BIGINT,
    IN P_TRANSACTION_TYPE VARCHAR(10),
    IN P_POINT INT,
    IN P_REFERENCE_POINT_ID BIGINT,
    IN P_PAYMENT_AMOUNT INT
)
BEGIN
    DECLARE V_ORIG_TYPE VARCHAR(10);
    DECLARE V_ORIG_POINT INT;
    
    /* 1. 기본 검증 */
    IF P_TRANSACTION_TYPE NOT IN ('적립', '사용', '취소') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid transaction_type. Allowed: 적립, 사용, 취소';
    END IF;

    /* 2. 사용자 검증 */
    CALL SP_VALIDATE_USER(P_USER_ID);

    /* 3. 거래 유형별 검증 */
    CASE P_TRANSACTION_TYPE
        WHEN '적립' THEN
            /* 적립 검증 */
            IF P_RECEIPT_ID IS NULL THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Receipt ID is required for 적립';
            END IF;
            
            CALL SP_VALIDATE_RECEIPT(P_RECEIPT_ID, TRUE);
            
            IF COALESCE(P_PAYMENT_AMOUNT, 0) <= 0 THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Payment amount must be greater than 0';
            END IF;
            
            SET P_POINT = FN_CALCULATE_POINT(P_PAYMENT_AMOUNT);
            
        WHEN '사용' THEN
            /* 사용 검증 */
            IF COALESCE(P_POINT, 0) <= 0 THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Point amount must be greater than 0';
            END IF;
            
            CALL SP_VALIDATE_POINT_BALANCE(P_USER_ID, P_POINT);
            
        WHEN '취소' THEN
            /* 취소 검증 */
            CALL SP_VALIDATE_POINT_TRANSACTION(
                P_REFERENCE_POINT_ID,
                V_ORIG_TYPE,
                V_ORIG_POINT
            );
    END CASE;

    /* 트랜잭션 시작 */
    START TRANSACTION;
    
    /* 4. 포인트 내역 생성 */
    INSERT INTO POINT (
        USER_ID,
        RECEIPT_ID,
        REFERENCE_POINT_ID,
        TRANSACTION_TYPE,
        POINT,
        CREATED_AT,
        IS_CANCELED
    ) VALUES (
        P_USER_ID,
        P_RECEIPT_ID,
        P_REFERENCE_POINT_ID,
        P_TRANSACTION_TYPE,
        CASE P_TRANSACTION_TYPE
            WHEN '취소' THEN V_ORIG_POINT
            ELSE P_POINT
        END,
        NOW(),
        'N'
    );

    /* 5. 사용자 포인트 업데이트 */
    UPDATE USER A
       SET A.REMAINING_POINT = 
           CASE P_TRANSACTION_TYPE
               WHEN '적립' THEN COALESCE(A.REMAINING_POINT, 0) + P_POINT
               WHEN '사용' THEN COALESCE(A.REMAINING_POINT, 0) - P_POINT
               WHEN '취소' THEN 
                   CASE V_ORIG_TYPE
                       WHEN '적립' THEN COALESCE(A.REMAINING_POINT, 0) - V_ORIG_POINT
                       WHEN '사용' THEN COALESCE(A.REMAINING_POINT, 0) + V_ORIG_POINT
                   END
           END
     WHERE A.USER_ID = P_USER_ID;

    /* 6. 취소 시 원본 거래 취소 처리 */
    IF P_TRANSACTION_TYPE = '취소' THEN
        UPDATE POINT A
           SET A.IS_CANCELED = 'Y'
         WHERE A.POINT_ID = P_REFERENCE_POINT_ID;
    END IF;

    COMMIT;
    
    /* 트랜잭션 실패 시 롤백 */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
END $$

DELIMITER ;
