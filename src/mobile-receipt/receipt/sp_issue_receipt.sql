/*
프로시저: SP_ISSUE_RECEIPT
목적: 영수증 발행 및 포인트 적립 처리
작성자: 박양하

파라미터:
    - P_USER_ID: 사용자 ID
    - P_STORE_ID: 매장 ID
    - P_CARD_COMPANY_ID: 카드사 ID
    - P_RECEIPT_BODY: 영수증 상세 내용 (JSON)
    - P_AMOUNT: 결제 금액
    - P_PAYMENT_METHOD: 결제 방식 ('신용', '체크', '현금' 등)

처리 순서:
    1. 사용자 유효성 검증
    2. 중복 영수증 검증
    3. 포인트 계산 (결제금액의 2%)
    4. 영수증 발행
    5. 포인트 적립
    6. 사용자 포인트 증가

에러:
    - 45000: 비즈니스 로직 위반 (사용자 없음, 중복 영수증 등)
    - 기타: SQL 오류

변경 이력:
2025-02-14 박양하
- 트랜잭션 범위 최소화
- 검증 로직 트랜잭션 밖으로 이동
- 포인트 계산 로직 분리
*/

DELIMITER $$

CREATE PROCEDURE SP_ISSUE_RECEIPT(
    IN P_USER_ID VARCHAR(30),
    IN P_STORE_ID INT,
    IN P_CARD_COMPANY_ID INT,
    IN P_RECEIPT_BODY JSON,
    IN P_AMOUNT INT,
    IN P_PAYMENT_METHOD VARCHAR(10)
)
BEGIN
    DECLARE V_NEW_RECEIPT_ID BIGINT;
    
    /* 1. 검증 */
    CALL SP_VALIDATE_USER(P_USER_ID);
    CALL SP_VALIDATE_DUPLICATE_RECEIPT(
        P_USER_ID,
        P_STORE_ID,
        P_CARD_COMPANY_ID,
        P_AMOUNT,
        '승인'
    );
    
    /* 트랜잭션 시작 */
    CALL SP_TRANSACTION_MANAGE('SP_ISSUE_RECEIPT');
    
    /* 2. 영수증 발행 */
    INSERT INTO RECEIPT (
        USER_ID,
        STORE_ID,
        CARD_COMPANY_ID,
        RECEIPT_BODY,
        AMOUNT,
        PAYMENT_METHOD,
        TRANSACTION_STATUS,
        IS_CANCELED,
        CREATED_AT
    ) VALUES (
        P_USER_ID,
        P_STORE_ID,
        P_CARD_COMPANY_ID,
        P_RECEIPT_BODY,
        P_AMOUNT,
        P_PAYMENT_METHOD,
        '승인',
        'N',
        NOW()
    );
    
    SET V_NEW_RECEIPT_ID = LAST_INSERT_ID();
    
    /* 3. 포인트 적립 */
    CALL SP_POINT_EARN(
        P_USER_ID,
        V_NEW_RECEIPT_ID,
        P_AMOUNT
    );
    
    COMMIT;
END $$

DELIMITER ;