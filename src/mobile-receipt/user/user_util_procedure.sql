-- USER UTIL PROCEDURE

-- 1. 회원 ID 존재 여부 확인

DELIMITER //

CREATE OR REPLACE PROCEDURE sp_check_user_exists(
    IN p_user_id VARCHAR(30)
)
BEGIN
    -- 사용자 존재 여부 확인
    IF NOT EXISTS (SELECT 1 
	 						FROM user 
						  WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오류: 존재하지 않는 사용자입니다.';
    END IF;
END //

DELIMITER ;

-- 2. 비밀번호 일치 여부 확인
DELIMITER //

CREATE OR REPLACE PROCEDURE sp_check_password_match(
    IN p_user_id VARCHAR(30),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE v_password_match INT DEFAULT 0;

    -- 비밀번호 확인
    IF NOT EXISTS (
        SELECT 
		  			1 
			 FROM user 
         WHERE user_id = p_user_id 
        	  AND password = p_password
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오류: 회원 정보가 일치하지 않습니다. ';
    END IF;
END //

DELIMITER ;

