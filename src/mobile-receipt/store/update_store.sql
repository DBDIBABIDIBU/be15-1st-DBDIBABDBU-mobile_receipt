DELIMITER //

CREATE TRIGGER before_store_update
BEFORE UPDATE ON store
FOR EACH ROW
BEGIN
    DECLARE existing_count INT DEFAULT 0;

    -- 기존 데이터와 비교하여 business_registration_number 또는 business_operation_certificate_url이 변경되었는지 확인
    IF OLD.business_registration_number <> NEW.business_registration_number 
        OR OLD.business_operation_certificate_url <> NEW.business_operation_certificate_url THEN

        -- 중복 여부 확인
        SELECT COUNT(*) INTO existing_count
        FROM store
        WHERE (business_registration_number = NEW.business_registration_number 
            OR business_operation_certificate_url = NEW.business_operation_certificate_url)
          AND store_id <> NEW.store_id;  -- 자기 자신 제외

        -- 중복이면 오류 반환
        IF existing_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '이미 등록된 사업 정보입니다.';
        END IF;
    END IF;
END;

//
DELIMITER ;




-- 중복 없는 경우 (정상 업데이트)
UPDATE store
SET category_id = 5
  , business_registration_number = 'BRN-NEW123'
  , business_operation_certificate_url = 'http://example.com/opert/new_store.jpg'
  , store_name = '업데이트된 가게'
  , contact_number = '02-9999-9999'
  , address = '서울시 동대문구'
  , address_detail = '999호'
  , business_hours = '08:00 ~ 20:00'
  , average_rating = 4.8
  , modified_at = NOW()
WHERE store_id = 3;

-- 중복된 값 업데이트 시도 → 오류 발생
UPDATE store
SET category_id = 5
  , business_registration_number = 'BRN-9999'  -- 기존에 존재하는 값
  , business_operation_certificate_url = 'http://example.com/opert/store_update.jpg'  -- 기존 값
  , store_name = '업데이트된 가게'
  , contact_number = '02-9999-9999'
  , address = '서울시 동대문구'
  , address_detail = '999호'
  , business_hours = '08:00 ~ 20:00'
  , average_rating = 4.8
  , modified_at = NOW()
WHERE store_id = 3;
