-- 회원 계정 관리 : 관리자는 정책을 위반한 회원의 계정을 정지시킬 수 있다.
DROP PROCEDURE if EXISTS admin_user_penalty_update;
DELIMITER //

CREATE PROCEDURE admin_user_penalty_update( -- 사용자id, 관리자id, 제제사유 입력
    IN p_user_id VARCHAR(30),
    IN p_admin_id VARCHAR(30),
    IN p_reason TEXT
)
BEGIN

    -- 1. 회원 계정 상태를 '정지'로 변경하고 신고 횟수 초기화
    UPDATE user
       SET account_status = '정지', reported_count = 0
     WHERE user_id = p_user_id;

    -- 2. 제제 내역 삽입
    INSERT 
	   INTO penalty_history 
	 (user_id, admin_id, penalty_reason, start_penalty_at, end_penalty_at)
    VALUES 
	 (p_user_id, p_admin_id, p_reason, CURRENT_TIMESTAMP, DATE_ADD(NOW(), INTERVAL 7 DAY));

END //

DELIMITER ;


-- 테스트 코드 --
/*
1. 관리자인 user03이 user10을 정지
2. 사용자 상태 및 피신고 횟수 조회
3. 제제 내역 확인
*/
SELECT * FROM user;
SELECT * FROM authority;
START TRANSACTION;

CALL admin_user_penalty_update('user08', 'user03', '욕설 사용');   -- (1)

SELECT user_id
     , account_status
     , reported_count
  FROM user
 WHERE user_id = 'user08';   -- (2)
 
SELECT * 
  FROM penalty_history 
 WHERE user_id = 'user10';    -- (3)
 
ROLLBACK;

