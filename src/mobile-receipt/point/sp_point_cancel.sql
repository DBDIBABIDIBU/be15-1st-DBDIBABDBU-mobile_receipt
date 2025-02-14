/*
프로시저: SP_POINT_CANCEL
목적: 영수증 취소에 따른 포인트 취소 처리
작성자: 박양하

파라미터:
    - P_USER_ID: 사용자 ID
    - P_RECEIPT_ID: 취소 영수증 ID
    - P_REFERENCE_POINT_ID: 취소할 원본 포인트 내역 ID

처리 순서:
    1. 원본 포인트 내역 검증
    2. 포인트 취소 내역 생성
    3. 원본 포인트 내역 취소 처리
    4. 사용자 포인트 차감

주의사항:
    - 호출하는 쪽의 트랜잭션 내에서 실행되어야 함
    - 독립적인 트랜잭션 관리를 하지 않음
    - 영수증 취소 프로시저에서 호출됨

에러:
    - 45000: 비즈니스 로직 위반
    - 기타: SQL 오류

변경 이력:
2025-02-14 박양하
- SP_MANAGE_POINT에서 분리
- 취소 로직 단순화
- 트랜잭션 관리 제거 (상위 트랜잭션 사용)
*/

DELIMITER $$

CREATE PROCEDURE SP_POINT_CANCEL(
    IN P_USER_ID VARCHAR(30),
    IN P_RECEIPT_ID BIGINT,
    IN P_REFERENCE_POINT_ID BIGINT
)
BEGIN
    DECLARE V_ORIG_TYPE VARCHAR(10);
    DECLARE V_ORIG_POINT INT;
    
    /* 1. 원본 포인트 내역 검증 */
    CALL SP_VALIDATE_POINT_TRANSACTION(
        P_REFERENCE_POINT_ID,
        V_ORIG_TYPE,
        V_ORIG_POINT
    );
    
    /* 2. 포인트 취소 내역 생성 */
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
        '취소',
        V_ORIG_POINT,
        NOW(),
        'N'
    );
    
    /* 3. 원본 포인트 내역 취소 처리 */
    UPDATE POINT A
       SET A.IS_CANCELED = 'Y'
     WHERE A.POINT_ID = P_REFERENCE_POINT_ID;
    
    /* 4. 사용자 포인트 조정 */
    UPDATE USER A
       SET A.REMAINING_POINT = 
           CASE V_ORIG_TYPE
               WHEN '적립' THEN COALESCE(A.REMAINING_POINT, 0) - V_ORIG_POINT
               WHEN '사용' THEN COALESCE(A.REMAINING_POINT, 0) + V_ORIG_POINT
           END
     WHERE A.USER_ID = P_USER_ID;
END $$

DELIMITER ;