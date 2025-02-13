-- 프로시저 개요

-- 포인트 차감 계산: 포인트 사용 시 사용한 포인트 수량
-- 포인트 거래 타입: '적립', '사용', '취소'
-- 비즈니스 로직:
-- 1) 결제 취소 시  포인트 차감 취소 로직 (user 테이블의 remaining_point)
-- 2) 결제 취소 시 포인트 적립 취소 로직 (user 테이블의 remaining_point)
-- 3) 결제 취소 시 포인트 차감 취소 로직 (user 테이블의 remaining_point)
-- 4) 결제 취소 시 receipt 테이블의 원본 receipt_id를 찾아서 is_canceled 컬럼 'Y'로 업데이트 (user 테이블의 remaining_point)
-- 5) 결제 승인인 시 결제액의 2% 포인트 적립(1원 이하 절삭) (user 테이블의 remaining_point)  
-- 6) 포인트 교환 시 포인트 차감 (user 테이블의 remaining_point)

-- Q1. user가 이미 point를 사용 후에 결제 취소를 통해 point가 환불되면? 음수 처리?
-- A1. ???


DELIMITER $$

CREATE PROCEDURE sp_manage_point (
    IN p_user_id VARCHAR(30),
    IN p_receipt_id BIGINT,
    IN p_transaction_type VARCHAR(10),
    IN p_point INT,                 
    IN p_reference_point_id BIGINT,
    IN p_payment_amount INT
)
BEGIN
    
    DECLARE v_orig_type VARCHAR(10) DEFAULT NULL;
    DECLARE v_orig_point INT DEFAULT 0;
    DECLARE v_orig_is_canceled ENUM('Y','N') DEFAULT 'N';
    DECLARE v_user_current_point INT DEFAULT 0;
    DECLARE v_calculated_point INT DEFAULT 0;  -- 포인트 적립 결제액의 2% 
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'Error: rollback executed' AS error_message;
    END;

    START TRANSACTION;
    
    /*
      (공통) 유효성 검증:
      1) transaction_type 값이 적절한지
      2) 적립/사용 시 p_point가 1 이상인지
    */
    IF p_transaction_type NOT IN ('적립','사용','취소') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid transaction_type. Allowed: 적립, 사용, 취소';
    END IF;

    IF (p_transaction_type IN ('적립','사용')) AND (p_point <= 0) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'p_point must be > 0 for 적립 or 사용.';
    END IF;

    -- user 존재 여부 확인 로직 (적립/사용/취소 전)
    IF NOT EXISTS (SELECT 1 FROM `user` WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User not found';
    END IF;

    -- [A] 적립 로직
    IF p_transaction_type = '적립' THEN
        -- 2% 포인트 계산 (1원 이하 절삭)
        SET v_calculated_point = FLOOR(p_payment_amount * 0.02);
        
        /*
          point 테이블 INSERT - 계산된 포인트 사용
        */
        INSERT INTO `point` (
            user_id, receipt_id, reference_point_id, transaction_type, 
            point, created_at, is_canceled
        ) VALUES (
            p_user_id, 
            p_receipt_id,
            NULL,
            '적립',
            v_calculated_point,  -- p_point 대신 계산된 포인트 사용
            NOW(),
            'N'
        );

        /*
          user.remaining_point = 기존 + 계산된 포인트
        */
        UPDATE `user`
           SET remaining_point = IFNULL(remaining_point, 0) + v_calculated_point
         WHERE user_id = p_user_id;

    -- [B] "사용"(차감) 로직
    ELSEIF p_transaction_type = '사용' THEN
        /*
          1) 현재 user의 잔여 포인트 확인
        */
        SELECT IFNULL(remaining_point, 0)
          INTO v_user_current_point
          FROM `user`
         WHERE user_id = p_user_id
         LIMIT 1;

        /*
          2) 보유 포인트 부족하면 에러 발생
        */
        IF v_user_current_point < p_point THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Not enough remaining_point for 사용.';
        END IF;

        /*
          3) point 테이블에 (transaction_type='사용') row 추가
        */
        INSERT INTO `point` (
            user_id, receipt_id, reference_point_id, transaction_type, 
            point, created_at, is_canceled
        ) VALUES (
            p_user_id, 
            p_receipt_id,
            NULL,           
            '사용',
            p_point,        
            NOW(),
            'N'
        );

        /*
          4) user.remaining_point -= p_point
        */
        UPDATE `user`
           SET remaining_point = IFNULL(remaining_point, 0) - p_point
         WHERE user_id = p_user_id;

    -- [C] "취소" 로직
    ELSEIF p_transaction_type = '취소' THEN

        -- 2025-02-12 박양하: 영수증 관련 로직에서 is_canceled의 값을 update하므로 주석 처리
        -- receipt 테이블 원본 영수증 취소 처리
        -- UPDATE receipt 
        --    SET is_canceled = 'Y'
        --  WHERE receipt_id = p_receipt_id;
  
        /*
          1) reference_point_id가 유효한지 체크 (NULL이면 에러 반환)
        */
        IF p_reference_point_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'reference_point_id is required for 취소.';
        END IF;

        /*
          2) 원본 거래(point_id=p_reference_point_id)를 찾는다.
             - 이미 취소된 거래는 취소 불가
             - row가 없으면 존재하지 않는 거래
        */
        SELECT transaction_type, point, is_canceled
          INTO v_orig_type, v_orig_point, v_orig_is_canceled
          FROM `point`
         WHERE point_id = p_reference_point_id
         LIMIT 1;

        -- SELECT 후 row를 못 찾으면 (원본 거래가 없음) -> 자동으로 exception
        IF v_orig_type IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Original transaction not found.';
        END IF;

        IF v_orig_is_canceled = 'Y' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'This transaction is already canceled.';
        END IF;

        /*
          3) 부분취소나 초과취소를 방지
             - p_point가 0 이상인 상황에서, "원본 포인트 v_orig_point"와 "요청한 p_point"가 동일해야만 취소 가능
        */
        IF p_point <> v_orig_point THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Partial or over cancellation not allowed. p_point must match original point exactly.';
        END IF;
        
        /*
          4) point 테이블에 "취소" 레코드 생성
             - reference_point_id로 원본 point_id를 FK 연결 
             - point 칼럼에 원본 거래와 동일한 v_orig_point 기록
        */
        INSERT INTO `point` (
            user_id, receipt_id, reference_point_id, transaction_type, 
            point, created_at, is_canceled
        ) VALUES (
            p_user_id,
            p_receipt_id,
            p_reference_point_id, 
            '취소',
            p_point,              
            NOW(),
            'N'
        );

        /*
          5) user.remaining_point 되돌리기 (일반적인 적립/차감 방식과 완전히 반대로 작동. 취소이기 때문에)
             - 원본이 '적립'이면 → 포인트를 - (적립을 취소)
             - 원본이 '사용'이면 → 포인트를 + (사용을 취소)
        */
        IF v_orig_type = '적립' THEN
            UPDATE `user`
               SET remaining_point = IFNULL(remaining_point, 0) - p_point
             WHERE user_id = p_user_id;

        ELSEIF v_orig_type = '사용' THEN
            UPDATE `user`
               SET remaining_point = IFNULL(remaining_point, 0) + p_point
             WHERE user_id = p_user_id;

        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid original transaction_type for cancellation.';
        END IF;
         
    END IF;

    COMMIT;
END $$

DELIMITER ;
