/*
프로시저: SP_POINT_USE
목적: 포인트 사용 처리
작성자: 박양하

파라미터:
    - P_USER_ID: 사용자 ID
    - P_POINT: 사용할 포인트 금액
    - P_USE_TYPE: 사용 유형 ('상품교환' 등)

처리 순서:
    1. 필수 파라미터 검증
    2. 사용자 및 포인트 잔액 검증
    3. 포인트 사용 내역 생성
    4. 사용자 포인트 차감

주의사항:
    - 호출하는 쪽의 트랜잭션 내에서 실행되어야 함
    - 독립적인 트랜잭션 관리를 하지 않음
    - 포인트 상품 교환 프로시저에서 호출됨

에러:
    - 45000: 비즈니스 로직 위반
    - 기타: SQL 오류

변경 이력:
2025-02-14 박양하
- SP_MANAGE_POINT에서 분리
- 사용 로직 단순화
*/

DELIMITER $$

CREATE PROCEDURE SP_POINT_USE(
    IN P_USER_ID VARCHAR(30),
    IN P_POINT INT,
    IN P_USE_TYPE VARCHAR(20)
)
BEGIN
    /* 1. 필수 파라미터 검증 */
    IF P_POINT IS NULL OR P_USE_TYPE IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Point amount and use type are required';
    END IF;
    
    IF P_POINT <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Point amount must be greater than 0';
    END IF;
    
    /* 2. 사용자 및 포인트 잔액 검증 */
    CALL SP_VALIDATE_USER(P_USER_ID);
    CALL SP_VALIDATE_POINT_BALANCE(P_USER_ID, P_POINT);
    
    /* 3. 포인트 사용 내역 생성 */
    INSERT INTO POINT (
        USER_ID,
        TRANSACTION_TYPE,
        POINT,
        CREATED_AT,
        IS_CANCELED
    ) VALUES (
        P_USER_ID,
        '사용',
        P_POINT,
        NOW(),
        'N'
    );
    
    /* 4. 사용자 포인트 차감 */
    UPDATE USER A
       SET A.REMAINING_POINT = COALESCE(A.REMAINING_POINT, 0) - P_POINT
     WHERE A.USER_ID = P_USER_ID;
END $$

DELIMITER ;