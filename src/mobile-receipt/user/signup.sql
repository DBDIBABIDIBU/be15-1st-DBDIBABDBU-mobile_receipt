-- 회원가입

DELIMITER //

CREATE OR REPLACE PROCEDURE signup(
	IN p_user_id VARCHAR(30),
	IN p_password VARCHAR(255),
	IN p_contact_number VARCHAR(15),
	IN p_email VARCHAR(100),
	IN p_name VARCHAR(50),
	IN p_age INT,
	IN p_gender ENUM('M', 'F'),
   IN p_is_alarm_enabled BOOLEAN,
   IN p_is_consent_provided BOOLEAN,
   IN p_authority_id INT,
   OUT signed_id VARCHAR(30)
)
BEGIN
	DECLARE user_count INT DEFAULT 0;
	DECLARE email_count INT DEFAULT 0;
	DECLARE phone_count INT DEFAULT 0;
	
    
-- 1. 회원 정보 저장
    INSERT INTO 
	 user 
	 (
        user_id, password, contact_number, email, user_name, authority_id,
        age, gender, is_alarm_enabled, is_consent_provided, account_status,
        created_at, modified_at
    ) 
	 VALUES 
	 (
        p_user_id, p_password, p_contact_number, p_email, p_name, p_authority_id,
        p_age, p_gender, p_is_alarm_enabled, p_is_consent_provided, DEFAULT,
        DEFAULT, DEFAULT
    );
    
--   2. 회원가입 성공한 id 반환
	SET signed_id = p_user_id;

END //
DELIMITER ;

-- 테스트 케이스

-- 정상 회원가입
@signed_id = '';
CALL signup(
    'new_user04', 'password444', '010-1244-4444', 'newuser03@example.com',
    '박사사', 44, 'M', TRUE, TRUE, 1, @signed_id
);
SELECT *
  FROM user
 WHERE user_id = @signed_id;

