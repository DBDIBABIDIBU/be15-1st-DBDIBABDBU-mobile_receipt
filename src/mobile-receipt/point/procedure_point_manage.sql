/*
프로시저: SP_MANAGE_POINT
목적: 포인트 적립, 사용, 취소 관리
작성자: 박양하
파라미터:
    - P_USER_ID: 사용자 ID
    - P_RECEIPT_ID: 영수증 ID (NULL 가능)
    - P_TRANSACTION_TYPE: 거래 유형 ('적립','사용','취소')
    - P_POINT: 포인트 금액
    - P_REFERENCE_POINT_ID: 취소 시 원본 거래 ID (취소 시 필수)
    - P_PAYMENT_AMOUNT: 결제 금액 (적립 시 사용)
반환: 없음
에러:
    - 45000: 비즈니스 로직 위반
    - 기타: SQL 오류
*/

-- ---------------------------------------------------------------
-- 로직
-- 1) 결제 취소 시 원본 포인트 내역 찾아서 취소 로직 (point_history 테이블의 point_history_id)
-- 2) --2025-02.12 삭제: 장건희 님의 UPDATE 로직과 중복됨-- 결제 취소 시 receipt 테이블의 원본 receipt_id를 찾아서 is_canceled 컬럼 'Y'로 업데이트
-- 3) 결제 승인 시 결제액의 2% 포인트 적립(1원 이하 절삭) (user 테이블의 remaining_point)  
-- 4) 포인트 교환 시 포인트 차감 (user 테이블의 remaining_point)
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
-- ----------------------------------------------------------------
-- 2025-02-12 박양하 최초 커밋
-- ----------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE SP_MANAGE_POINT (
    IN P_USER_ID VARCHAR(30),
    IN P_RECEIPT_ID BIGINT,
    IN P_TRANSACTION_TYPE VARCHAR(10),
    IN P_POINT INT,                 
    IN P_REFERENCE_POINT_ID BIGINT,
    IN P_PAYMENT_AMOUNT INT
)
BEGIN
    DECLARE V_ORIG_TYPE VARCHAR(10) DEFAULT NULL;
    DECLARE V_ORIG_POINT INT DEFAULT 0;
    DECLARE V_ORIG_IS_CANCELED ENUM('Y','N') DEFAULT 'N';
    DECLARE V_USER_CURRENT_POINT INT DEFAULT 0;
    DECLARE V_CALCULATED_POINT INT DEFAULT 0;  /* 포인트 적립 결제액의 2% */
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1
            @SQL_STATE = RETURNED_SQLSTATE,
            @ERROR_NO = MYSQL_ERRNO,
            @MESSAGE = MESSAGE_TEXT;
        
        SET @ERROR_MESSAGE = COALESCE(
            @MESSAGE,
            'Unknown error occurred during point management'
        );
        
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = @ERROR_MESSAGE;
    END;

    /* 트랜잭션 외부 검증 */
    IF P_TRANSACTION_TYPE NOT IN ('적립', '사용', '취소') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid transaction_type. Allowed: 적립, 사용, 취소';
    END IF;

    /* 적립인 경우 영수증 검증 추가 */
    IF P_TRANSACTION_TYPE = '적립' THEN
        IF P_RECEIPT_ID IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Receipt ID is required for 적립';
        END IF;
        
        /* 이미 적립된 영수증인지 확인 */
        IF EXISTS (
            SELECT 1 
              FROM POINT A
             WHERE A.RECEIPT_ID = P_RECEIPT_ID
               AND A.TRANSACTION_TYPE = '적립'
               AND A.IS_CANCELED = 'N'
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Points already awarded for this receipt';
        END IF;

        /* 결제금액 체크 */
        IF COALESCE(P_PAYMENT_AMOUNT, 0) <= 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'P_PAYMENT_AMOUNT must be > 0 for 적립';
        END IF;
    END IF;

    /* 적립은 결제금액으로 계산하므로 P_POINT 체크에서 제외 */
    IF (P_TRANSACTION_TYPE = '사용') AND (COALESCE(P_POINT, 0) <= 0) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'P_POINT must be > 0 for 사용';
    END IF;

    /* 사용자 존재 여부 확인 */
    IF NOT EXISTS (
        SELECT 1 
          FROM USER A
         WHERE A.USER_ID = P_USER_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User not found';
    END IF;

    START TRANSACTION;

    /* [A] 적립 로직 */
    IF P_TRANSACTION_TYPE = '적립' THEN
        SET V_CALCULATED_POINT = FLOOR(P_PAYMENT_AMOUNT * 0.02);
        
        INSERT INTO POINT 
        (
            USER_ID
          , RECEIPT_ID
          , REFERENCE_POINT_ID
          , TRANSACTION_TYPE
          , POINT
          , CREATED_AT
          , IS_CANCELED
        )
        VALUES
        (
            P_USER_ID
          , P_RECEIPT_ID
          , NULL
          , '적립'
          , V_CALCULATED_POINT
          , NOW()
          , 'N'
        );

        UPDATE USER A
           SET A.REMAINING_POINT = COALESCE(A.REMAINING_POINT, 0) + V_CALCULATED_POINT
         WHERE A.USER_ID = P_USER_ID;

    /* [B] 사용 로직 */
    ELSEIF P_TRANSACTION_TYPE = '사용' THEN
        SELECT COALESCE(A.REMAINING_POINT, 0)
          INTO V_USER_CURRENT_POINT
          FROM USER A
         WHERE A.USER_ID = P_USER_ID;

        IF V_USER_CURRENT_POINT < P_POINT THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Not enough remaining_point for 사용';
        END IF;

        INSERT INTO POINT 
        (
            USER_ID
          , TRANSACTION_TYPE
          , POINT
          , CREATED_AT
          , IS_CANCELED
        )
        VALUES
        (
            P_USER_ID
          , '사용'
          , P_POINT
          , NOW()
          , 'N'
        );

        UPDATE USER A
           SET A.REMAINING_POINT = COALESCE(A.REMAINING_POINT, 0) - P_POINT
         WHERE A.USER_ID = P_USER_ID;

    /* [C] 취소 로직 */
    ELSEIF P_TRANSACTION_TYPE = '취소' THEN
        /* 영수증 ID로 취소하는 경우 */
        IF P_RECEIPT_ID IS NOT NULL THEN
            SELECT A.POINT_ID
              INTO P_REFERENCE_POINT_ID
              FROM POINT A
             WHERE A.RECEIPT_ID = P_RECEIPT_ID
               AND A.USER_ID = P_USER_ID
               AND A.IS_CANCELED = 'N'
               AND A.TRANSACTION_TYPE = '적립'
             ORDER BY A.CREATED_AT DESC
             LIMIT 1;
             
            IF P_REFERENCE_POINT_ID IS NULL THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'No active point transaction found for this receipt';
            END IF;
        /* 직접 포인트 거래 ID를 지정한 경우 */
        ELSEIF P_REFERENCE_POINT_ID IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Either receipt_id or reference_point_id is required for 취소';
        END IF;

        SELECT A.TRANSACTION_TYPE
             , A.POINT
             , A.IS_CANCELED
          INTO V_ORIG_TYPE
             , V_ORIG_POINT
             , V_ORIG_IS_CANCELED
          FROM POINT A
         WHERE A.POINT_ID = P_REFERENCE_POINT_ID;

        IF V_ORIG_TYPE IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Original transaction not found';
        END IF;

        IF V_ORIG_IS_CANCELED = 'Y' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'This transaction is already canceled';
        END IF;
        
        INSERT INTO POINT 
        (
            USER_ID
          , RECEIPT_ID
          , REFERENCE_POINT_ID
          , TRANSACTION_TYPE
          , POINT
          , CREATED_AT
          , IS_CANCELED
        )
        VALUES
        (
            P_USER_ID
          , P_RECEIPT_ID
          , P_REFERENCE_POINT_ID
          , '취소'
          , V_ORIG_POINT
          , NOW()
          , 'N'
        );

        IF V_ORIG_TYPE = '적립' THEN
            UPDATE USER A
               SET A.REMAINING_POINT = COALESCE(A.REMAINING_POINT, 0) - V_ORIG_POINT
             WHERE A.USER_ID = P_USER_ID;
        ELSEIF V_ORIG_TYPE = '사용' THEN
            UPDATE USER A
               SET A.REMAINING_POINT = COALESCE(A.REMAINING_POINT, 0) + V_ORIG_POINT
             WHERE A.USER_ID = P_USER_ID;
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid original transaction_type for cancellation';
        END IF;

        /* 원본 거래 취소 처리 */
        UPDATE POINT A
           SET A.IS_CANCELED = 'Y'
         WHERE A.POINT_ID = P_REFERENCE_POINT_ID;
    END IF;

    COMMIT;
END $$

DELIMITER ;
