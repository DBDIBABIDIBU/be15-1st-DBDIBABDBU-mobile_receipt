-- 프로필 수정

DELIMITER //

CREATE or replace PROCEDURE update_user_profile(
    IN p_user_id VARCHAR(30),
    IN p_new_profile_image TEXT,
    IN p_new_contact_number VARCHAR(15),
    IN p_new_email VARCHAR(100)
)
BEGIN
    DECLARE v_existing_contact_count INT DEFAULT 0;
    DECLARE v_existing_email_count INT DEFAULT 0;

    -- 전화번호 중복 확인
	  IF p_new_contact_number IS NOT NULL THEN
	     SELECT 
		  			COUNT(*)
			 INTO v_existing_contact_count
	       FROM user
	      WHERE contact_number = p_new_contact_number 
			  AND user_id <> p_user_id;
	
	     IF v_existing_contact_count > 0 THEN
	         SIGNAL SQLSTATE '45000'
	         SET MESSAGE_TEXT = '전화번호가 이미 사용 중입니다.';
	     END IF;
	  END if;

    -- 이메일 중복 확인
     IF p_new_email IS NOT NULL THEN
	     SELECT COUNT(*) 
		  	 INTO v_existing_email_count
	       FROM user
	      WHERE email = p_new_email 
		     AND user_id <> p_user_id;
	
	     IF v_existing_email_count > 0 THEN
	         SIGNAL SQLSTATE '45000'
	         SET MESSAGE_TEXT = '이메일이 이미 사용 중입니다.';
	     END IF;
     END if; 

    -- 사용자 정보 업데이트
    UPDATE user
    SET 
        profile_image_url = COALESCE(p_new_profile_image, profile_image_url),
        contact_number = COALESCE(p_new_contact_number, contact_number),
        email = COALESCE(p_new_email, email),
        modified_at = NOW()
    WHERE user_id = p_user_id;

END //

DELIMITER ;

-- 1. 프로필 사진만 변경
CALL update_user_profile('user01', 'https://new-image-url.com/user01.jpg', NULL, NULL);
SELECT
		  user_id
		, user_name
		, profile_image_url
		, contact_number
		, email
  FROM user
  WHERE user_id = 'user01';