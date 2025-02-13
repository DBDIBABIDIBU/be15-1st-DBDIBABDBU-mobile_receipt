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



-- 

-- 첫 번째 결제 (정상)
INSERT INTO receipt (
      user_id
    , store_id
    , card_company_id
    , receipt_body
    , amount
    , payment_method
    , transaction_status
    , is_canceled
    , created_at
)
VALUES (
      (SELECT user_id FROM user WHERE contact_number = '01000000001')
    , 1
    , 3
    , '{ "items": ["itemA", "itemB"], "description": "영수증 내용 추가" }'
    , 18000
    , '신용'
    , '승인'
    , 'N'
    , NOW()
);

-- 10초 이내 같은 결제 금액, 상태로 중복 결제 시도 → 오류 발생
INSERT INTO receipt (
      user_id
    , store_id
    , card_company_id
    , receipt_body
    , amount
    , payment_method
    , transaction_status
    , is_canceled
    , created_at
)
VALUES (
      (SELECT user_id FROM user WHERE contact_number = '01000000001')
    , 1
    , 3
    , '{ "items": ["itemA", "itemB"], "description": "영수증 내용 추가" }'
    , 18000
    , '신용'
    , '승인'
    , 'N'
    , NOW()
);
