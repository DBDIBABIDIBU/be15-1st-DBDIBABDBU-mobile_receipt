-- 계정 정지 알림	: 회원의 리뷰가 신고 누적 5회에 도달하거나, 관리자가 계정을 정지 시키는 경우 안내 메세지 전송한다.
DROP TRIGGER if EXISTS after_penalty_insert_notification;
DELIMITER //
CREATE TRIGGER after_penalty_insert_notification
AFTER INSERT ON penalty_history
FOR EACH ROW
BEGIN
	  IF (SELECT is_alarm_enabled FROM user WHERE user_id = NEW.user_id) = 'Y' THEN
	    -- 알림 삽입
	    INSERT INTO notification_history (
		   user_id
			, notification_type_id
			, created_at
		 )
	    VALUES (
		 NEW.user_id
		 , 4
		 , CURRENT_TIMESTAMP
		 );     /* notification_type_id는 임의의 알림 메세지를 참조하는 id */
	  END if;
END //
DELIMITER ;


-- 테스트 코드 --
/*
1. 관리자인 user03이 user10을 정지
2. 사용자 상태 및 피신고 횟수 조회
3. 정지 내역 확인
4. user10 알람 내역 확인
*/

START TRANSACTION;

CALL admin_user_penalty_update('user10', 'user08', '욕설 사용');   -- (1)

SELECT user_id
     , account_status
     , reported_count
  FROM user
 WHERE user_id = 'user10';                                         -- (2)
 
SELECT
	     penalty_history_id
	   , user_id
	   , admin_id
	   , penalty_reason
	   , start_penalty_at
	   , end_penalty_at
  FROM penalty_history 
 WHERE user_id = 'user10';                                         -- (3)

SELECT
        notification_history_id
      , notification_type_id
      , user_id
      , created_at
  FROM notification_history 
 WHERE user_id='user10';                                          --  (4)

ROLLBACK;