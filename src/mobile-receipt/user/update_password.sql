-- 비밀번호 변경

DELIMITER //

CREATE OR REPLACE PROCEDURE update_password(
	 IN p_user_id VARCHAR(30),
    IN p_password VARCHAR(255),
    IN p_new_password VARCHAR(255),
    OUT updated_id VARCHAR(255)
)
BEGIN
    DECLARE password_correct INT DEFAULT 0;

	 CALL sp_check_password_match(p_user_id,p_password);

    -- 2. 비밀번호 업데이트 수행
    UPDATE user
       SET   password = p_new_password
           , modified_at = NOW()
     WHERE user_id = p_user_id;
    
    SET updated_id = p_user_id;
END //

DELIMITER ;

-- 1. 테스트 케이스(성공)
-- 예상결과: user의 password 변경
 
SET @updated_user_id = '';
CALL update_password('user01', 'pw01', 'new01', @updated_user_id);
SELECT
		 user_id
		, PASSWORD
  FROM user
 WHERE user_id =  @updated_user_id;
 
-- 2. 테스트 케이스(실패): 기존 비밀번호와 불일치
-- 예상결과: 에러 메시지('비밀번호 변경 실패: 기존 비밀번호가 일치하지 않습니다.') 출력

SET @updated_user_id = '';
CALL update_password('user01', 'pw02', 'new02', @updated_user_id);
SELECT
		 user_id
		, PASSWORD
  FROM user
 WHERE user_id =  @updated_user_id;
