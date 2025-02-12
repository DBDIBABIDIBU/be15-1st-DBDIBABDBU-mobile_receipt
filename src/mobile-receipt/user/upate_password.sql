-- 비밀번호 변경

DELIMITER //

CREATE OR REPLACE PROCEDURE update_password(
	 IN p_user_id VARCHAR(30),
    IN p_old_password VARCHAR(255),
    IN p_new_password VARCHAR(255),
    OUT updated_id VARCHAR(255)
)
BEGIN
    DECLARE password_correct INT DEFAULT 0;

    -- 1. 기존 비밀번호가 일치하는지 확인
	 SELECT 
	 		  user_id INTO updated_id
	   FROM user 
	  WHERE password = p_old_password
	  LIMIT 1;

    -- 기존 비밀번호가 일치하지 않으면 오류 반환
    IF updated_id = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '비밀번호 변경 실패: 기존 비밀번호가 일치하지 않습니다.';
    END IF;

    -- 2. 비밀번호 업데이트 수행
    UPDATE user
       SET   password = p_new_password
           , modified_at = NOW()
     WHERE user_id = p_user_id;
END //

DELIMITER ;

SET @updated_user_id = '';
CALL update_password('user01', 'pw01', 'new01', @updated_user_id);
SELECT
		 user_id
		, PASSWORD
  FROM user
 WHERE user_id =  @updated_user_id;

