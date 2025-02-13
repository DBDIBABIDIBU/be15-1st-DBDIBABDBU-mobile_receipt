/*
프로시저: SP_POINT_EARN
목적: 영수증 발행에 따른 포인트 적립 처리
작성자: 박양하

파라미터:
    - P_USER_ID: 사용자 ID
    - P_RECEIPT_ID: 영수증 ID
    - P_PAYMENT_AMOUNT: 결제 금액

처리 순서:
    1. 필수 파라미터 검증
    2. 영수증 검증
    3. 포인트 계산
    4. 포인트 적립 내역 생성
    5. 사용자 포인트 증가

주의사항:
    - 호출하는 쪽의 트랜잭션 내에서 실행되어야 함
    - 독립적인 트랜잭션 관리를 하지 않음

에러:
    - 45000: 비즈니스 로직 위반
    - 기타: SQL 오류

변경 이력:
2025-02-14 박양하
- SP_MANAGE_POINT에서 분리
- 적립 로직 단순화
- 트랜잭션 관리 제거 (상위 트랜잭션 사용)
*/

DELIMITER $$

CREATE PROCEDURE SP_POINT_EARN(
    IN P_USER_ID VARCHAR(30),
    IN P_RECEIPT_ID BIGINT,
    IN P_PAYMENT_AMOUNT INT
)
BEGIN
    DECLARE V_POINT INT;
    
    /* 1. 필수 파라미터 검증 */
    IF P_RECEIPT_ID IS NULL OR P_PAYMENT_AMOUNT IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Receipt ID and payment amount are required';
    END IF;
    
    /* 2. 영수증 검증 */
    CALL SP_VALIDATE_RECEIPT(P_RECEIPT_ID, FALSE);

    /* 3. 포인트 계산 */
    SET V_POINT = FN_CALCULATE_POINT(P_PAYMENT_AMOUNT);
    
    /* 4. 포인트 적립 내역 생성 */
    INSERT INTO POINT (
        USER_ID,
        RECEIPT_ID,
        TRANSACTION_TYPE,
        POINT,
        CREATED_AT,
        IS_CANCELED
    ) VALUES (
        P_USER_ID,
        P_RECEIPT_ID,
        '적립',
        V_POINT,
        NOW(),
        'N'
    );
    
    /* 5. 사용자 포인트 증가 */
    UPDATE USER A
       SET A.REMAINING_POINT = COALESCE(A.REMAINING_POINT, 0) + V_POINT
     WHERE A.USER_ID = P_USER_ID;
END $$

DELIMITER ;