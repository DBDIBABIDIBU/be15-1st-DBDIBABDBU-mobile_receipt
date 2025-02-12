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
	
--	 1. 아이디 중복 검사
	SELECT 
			  COUNT(*) INTO user_count
	  FROM user
	 WHERE user_id = p_user_id;
	 
-- 	 아이디 중복 검사에 대한 에러처리
    IF user_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '회원가입 실패: 아이디가 이미 존재합니다.';
    END IF;
    
--  2. 이메일 중복 검사
    SELECT
    		  COUNT(*) INTO email_count
      FROM user
	  WHERE contact_number = p_email;

    IF email_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '회원가입 실패: 이메일이 이미 사용 중입니다.';
    END IF;

-- 3. 전화번호 중복 검사
     SELECT 
	 		  COUNT(*) INTO phone_count
      FROM user
     WHERE contact_number = p_contact_number;

    IF phone_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '회원가입 실패: 전화번호가 이미 사용 중입니다.';
    END IF;
    
-- 4. 회원 정보 저장
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
    
--   5. 회원가입 성공한 id 반환
	SET signed_id = p_user_id;

END //
DELIMITER ;

-- 테스트 케이스(성공 및 실패)

-- 정상 회원가입(성공)
@signed_id = '';
CALL signup(
    'new_user04', 'password444', '010-1244-4444', 'newuser03@example.com',
    '박사사', 44, 'M', TRUE, TRUE, 1, @signed_id
);
SELECT *
  FROM user
 WHERE user_id = @signed_id;

-- 중복 아이디 테스트(실패)

CALL sp_register_user(
    'user01', 'password123', '010-9999-9999', 'newemail@example.com',
    '김철수', 30, 'M', TRUE, TRUE
);
SELECT *
  FROM user
 WHERE user_id = @signed_id;
