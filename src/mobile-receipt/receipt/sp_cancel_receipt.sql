/*
프로시저: SP_CANCEL_RECEIPT
목적: 영수증 취소 및 포인트 취소 처리
작성자: 박양하

파라미터:
    - P_RECEIPT_ID: 취소할 원본 영수증 ID

처리 순서:
    1. 원본 영수증 유효성 검증
       - 존재하는 영수증인지
       - 이미 취소된 영수증은 아닌지
       - 승인 상태인지
    2. 원본 포인트 내역 검증
       - 적립된 포인트가 있는지
       - 이미 취소된 포인트는 아닌지
    3. 원본 영수증 취소 처리
    4. 취소 영수증 발행
    5. 원본 포인트 취소 처리
    6. 포인트 취소 내역 생성
    7. 사용자 포인트 차감

에러:
    - 45000: 비즈니스 로직 위반 (영수증 없음, 이미 취소됨 등)
    - 기타: SQL 오류

변경 이력:
2025-02-14 박양하
- 트랜잭션 범위 최소화
- 검증 로직 트랜잭션 밖으로 이동
- 취소 영수증 ID 명시적 관리
*/

DELIMITER $$

CREATE PROCEDURE SP_CANCEL_RECEIPT(
    IN P_RECEIPT_ID BIGINT
)
BEGIN
    DECLARE V_USER_ID VARCHAR(30);
    DECLARE V_POINT_ID BIGINT;
    
    /* 1. 원본 영수증 검증 */
    SELECT A.USER_ID
      INTO V_USER_ID
      FROM RECEIPT A
     WHERE A.RECEIPT_ID = P_RECEIPT_ID;
    
    CALL SP_VALIDATE_RECEIPT(P_RECEIPT_ID, TRUE);
    CALL SP_VALIDATE_USER(V_USER_ID);
    
    /* 2. 원본 포인트 내역 조회 */
    SELECT A.POINT_ID
      INTO V_POINT_ID
      FROM POINT A
     WHERE A.RECEIPT_ID = P_RECEIPT_ID
       AND A.TRANSACTION_TYPE = '적립'
       AND A.IS_CANCELED = 'N'
     LIMIT 1;
    
    IF V_POINT_ID IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Original point record not found';
    END IF;
    
    /* 트랜잭션 시작 */
    CALL SP_TRANSACTION_MANAGE('SP_CANCEL_RECEIPT');
    
    /* 3. 원본 영수증 취소 처리 */
    UPDATE RECEIPT A
       SET A.IS_CANCELED = 'Y',
           A.DELETED_AT = NOW()
     WHERE A.RECEIPT_ID = P_RECEIPT_ID;
    
    /* 4. 포인트 취소 */
    CALL SP_POINT_CANCEL(
        V_USER_ID,
        P_RECEIPT_ID,
        V_POINT_ID
    );
    
    COMMIT;
END $$

DELIMITER ;