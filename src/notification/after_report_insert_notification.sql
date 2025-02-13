DROP TRIGGER if EXISTS after_report_insert_notification;

DELIMITER $$   -- 회원이 등록한 리뷰가 누적 신고 3회에 도달하면 경고 메세지 전송한다.
CREATE TRIGGER after_report_insert_notification
AFTER INSERT ON report
FOR EACH ROW
BEGIN
    DECLARE count INT;
    DECLARE reported_user_id VARCHAR(30);
    DECLARE reported_review_id BIGINT(20);
    DECLARE reported_comment_id BIGINT(20);
    
	 -- 신고 리뷰, 댓글 조회
    SELECT 
	 		  review_id
			, comment_id 
		INTO reported_review_id, reported_comment_id
      FROM report
     WHERE report_id = NEW.report_id;
     
     -- 리뷰, 댓글 신고에 따라 작성자 id조회
    if reported_review_id IS NOT NULL then
   		SELECT user_id INTO reported_user_id
   		  FROM review
   		 WHERE review_id = reported_review_id;
    else
    		SELECT user_id INTO reported_user_id
   		  FROM comment
   		 WHERE comment_id = reported_comment_id;
    END if;
    
    IF (SELECT is_alarm_enabled FROM user WHERE user_id = review_author_id) = 'Y' THEN
	    -- 위에서 구한 reported_user_id로 피신고횟수 조회
	    SELECT reported_count INTO count 
		   FROM user 
		  WHERE user_id = reported_user_id;
	
	    -- 피신고 횟수가 3 이면 경고 알림 추가
	    IF count = 3 THEN
	        INSERT INTO notification_history (
			    user_id
				, notification_type_id
				, created_at
				)
	        VALUES (
			    reported_user_id
				, 3
				, CURRENT_TIMESTAMP
				); -- notification_type_id 2는 "리뷰 3회 신고 경고" 가정
	    END IF;
	 END IF; 
END $$

DELIMITER ;
-- 테스트케이스 --
/*
1. 리뷰 신고
2. 리뷰 신고 데이터 확인
3. 알림 데이터 확인
4. 댓글 신고
5. 댓글 신고 데이터 확인
6. 알림 데이터 확인
*/

START TRANSACTION;
call report_review('user01', 2 , 3, '못생겼어');    -- (1)

SELECT 
        report_id
      , report_type_id
      , user_id
      , comment_id
      , review_id
      , report_comment
      , created_at
  FROM report;                                      -- (2)

SELECT
        notification_history_id
      , notification_type_id
      , user_id
      , created_at
  FROM notification_history;                        -- (3)
  
SELECT
        user_id
      , reported_count
  FROM user;

call report_comment('user01', 2 , 3, '못생겼어');  -- (4)

SELECT 
        report_id
      , report_type_id
      , user_id
      , comment_id
      , review_id
      , report_comment
      , created_at
  FROM report;                                     -- (5)

SELECT
        notification_history_id
      , notification_type_id
      , user_id
      , created_at
  FROM notification_history;                         -- (6)
  
ROLLBACK;

DESCRIBE user;