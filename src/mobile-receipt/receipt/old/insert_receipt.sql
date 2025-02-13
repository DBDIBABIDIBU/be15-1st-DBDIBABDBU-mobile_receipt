DELIMITER //

CREATE TRIGGER before_receipt_insert
BEFORE INSERT ON receipt
FOR EACH ROW
BEGIN
    DECLARE existing_count INT DEFAULT 0;

    -- 최근 10초 이내에 동일한 transaction_status와 amount가 있는지 확인
    SELECT COUNT(*) INTO existing_count
    FROM receipt
    WHERE user_id = NEW.user_id
      AND store_id = NEW.store_id
      AND card_company_id = NEW.card_company_id
      AND transaction_status = NEW.transaction_status
      AND amount = NEW.amount
      AND created_at >= NOW() - INTERVAL 10 SECOND;

    -- 중복 결제인 경우 오류 발생
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '중복 결제입니다.';
    END IF;
END;

//
DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_insert_receipt_with_point (
    IN p_user_id VARCHAR(30),
    IN p_store_id INT,
    IN p_card_company_id INT,
    IN p_receipt_body JSON,
    IN p_amount INT,
    IN p_payment_method VARCHAR(10),
    IN p_transaction_status VARCHAR(10),
    IN p_is_canceled ENUM('Y', 'N')
)
BEGIN
    DECLARE v_receipt_id BIGINT;
    DECLARE v_calculated_point INT;

    -- 유저 존재 여부 확인
    IF NOT EXISTS (SELECT 1 FROM user WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found';
    END IF;

    -- receipt 테이블에 데이터 삽입
    INSERT INTO receipt (
        user_id, store_id, card_company_id, receipt_body, amount,
        payment_method, transaction_status, is_canceled, created_at
    ) VALUES (
        p_user_id, p_store_id, p_card_company_id, p_receipt_body, p_amount,
        p_payment_method, p_transaction_status, p_is_canceled, NOW()
    );

    -- 삽입된 receipt_id 가져오기
    SET v_receipt_id = LAST_INSERT_ID();

    -- 결제 금액의 2%를 포인트로 적립 (1원 이하 절삭)
    SET v_calculated_point = FLOOR(p_amount * 0.02);

    -- sp_manage_point 프로시저 호출 (적립 처리)
    CALL sp_manage_point(
        p_user_id,         -- user_id
        v_receipt_id,      -- receipt_id
        '적립',            -- transaction_type
        v_calculated_point,-- 계산된 포인트
        NULL,              -- reference_point_id (적립 시 필요 없음)
        p_amount           -- 결제 금액 (2% 적립)
    );

END $$

DELIMITER ;



CALL sp_insert_receipt_with_point(
    'user10',       -- user_id
    1,              -- store_id
    3,              -- card_company_id
    '{ "items": ["itemA", "itemB"], "description": "영수증 내용 추가" }',  -- JSON receipt_body
    18000,          -- amount
    '신용',         -- payment_method
    '승인',         -- transaction_status
    'N'             -- is_canceled
);