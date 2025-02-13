DELIMITER //

CREATE TRIGGER before_store_insert
BEFORE INSERT ON store
FOR EACH ROW
BEGIN
    DECLARE existing_count INT DEFAULT 0;

    -- 중복 여부 확인
    SELECT COUNT(*) INTO existing_count 
    FROM store 
    WHERE business_registration_number = NEW.business_registration_number 
       OR business_operation_certificate_url = NEW.business_operation_certificate_url;

    -- 중복이면 오류 반환
    IF existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '중복된 사업자 정보입니다';
    END IF;
END;

//
DELIMITER ;


-- 정상적으로 삽입됨
INSERT INTO store (
     user_id
	, category_id
	, business_registration_number
	, business_operation_certificate_url
	, store_name
	, contact_number
	, address
	, address_detail
	, business_hours
	, average_rating
	, created_at
	, modified_at
	, deleted_at
) VALUES (
    'user10', 3, 'BRN-9999', 'http://example.com/opert/store_9999.jpg',
    '테스트 매장', '02-9999-9999', '서울시 강남구', '301호', '10:00 ~ 22:00',
    0, NOW(), NOW(), NULL
);

-- 중복된 데이터 삽입 시도 → "중복된 사업자 정보입니다" 오류 발생
INSERT INTO store (
     user_id
	, category_id
	, business_registration_number
	, business_operation_certificate_url
	, store_name
	, contact_number
	, address
	, address_detail
	, business_hours
	, average_rating
	, created_at
	, modified_at
	, deleted_at
) VALUES (
    'user11', 3, 'BRN-9999', 'http://example.com/opert/store_9999.jpg',
    '중복 테스트 매장', '02-8888-8888', '서울시 종로구', '302호', '09:00 ~ 21:00',
    0, NOW(), NOW(), NULL
);



SELECT * FROM receipt;