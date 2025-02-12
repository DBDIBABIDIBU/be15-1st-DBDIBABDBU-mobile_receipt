-- 로그인
DELIMITER //

CREATE OR REPLACE PROCEDURE user_login(
    IN p_user_id VARCHAR(30),
    IN p_password VARCHAR(255),
    IN p_ip_address TEXT,
    IN p_device_type TEXT
)
BEGIN
    DECLARE v_account_status VARCHAR(10);
    DECLARE v_user_exists INT DEFAULT 0;

    -- 1. 사용자 존재 여부 및 계정 상태 확인
    SELECT 
	 		    COUNT(*)
			  , account_status 
      INTO   v_user_exists
			  , v_account_status
      FROM user
     WHERE user_id = p_user_id 
	    AND password = p_password;

    -- 존재하지 않는 사용자 예외 처리
    IF v_user_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '로그인 실패: 아이디 또는 비밀번호가 잘못되었습니다.';
    END IF;

    -- 2. 계정 상태에 따른 로그인 제한
    CASE v_account_status
    	  when '활성' then
    	  		-- 3. 로그인 기록 저장 (활성화 계정만 가능)
			   INSERT INTO login_history (user_id, login_at, ip_address, device_type)
			   VALUES (p_user_id, NOW(), p_ip_address, p_device_type);
        WHEN '휴면' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '로그인 실패: 휴면 계정입니다. 계정 활성화 후 이용해주세요.';
        WHEN '탈퇴' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '로그인 실패: 탈퇴한 계정입니다.';
        WHEN '정지' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '로그인 실패: 정지된 계정입니다. 관리자에게 문의하세요.';
        ELSE
        		SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '로그인 실패: 알 수 없는 계정 상태입니다. 관리자에게 문의하세요.';
    END CASE;
END //

DELIMITER ;

-- 테스트 케이스
-- 1. 로그인 성공(활성화 계정, 로그인 성공)
CALL user_login('user03', 'pw03', '192.168.1.1', 'Windows 10');
SELECT
		  u.user_id 'user ID'
		, u.user_name '회원명'
		, j.login_at '로그인 일시'
		, j.ip_address '로그인 IP'
		, j.device_type '디바이스 타입'
  FROM user u
  JOIN login_history j ON u.user_id = j.user_id
  WHERE u.user_id = 'user03';

-- 2. 탈퇴한 계정(로그인 실패)
CALL user_login('user02', 'pw02', '192.168.1.1', 'Windows 10');
