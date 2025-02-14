DROP TRIGGER if exists after_comment_insert_notinication;
DELIMITER //  -- 리뷰 댓글이 작성되면 리뷰 작성자에게 알림을 전송한다.
CREATE TRIGGER after_comment_insert_notinication
AFTER INSERT ON comment
FOR EACH ROW
BEGIN
    DECLARE review_author_id VARCHAR(30);
    
    -- 리뷰 작성자 찾기
	    SELECT user_id 
		   INTO review_author_id
	      FROM review
	     WHERE review_id = NEW.review_id;
	
	IF (SELECT is_alarm_enabled FROM user WHERE user_id = review_author_id) = 'Y' THEN
	    -- 알림 삽입
	    INSERT INTO notification_history ( 
		   user_id
		 , notification_type_id
		 , created_at)
	    VALUES (
		   review_author_id
			, 2
			, CURRENT_TIMESTAMP
		 );     /* notification_type_id는 임의의 알림 메세지를 참조하는 id */
	END if;
END //
DELIMITER ;

-- 테스트 --
/*
테스트 계획
1. 기존 테이블에는 10개의 데이터 존재
2. '댓글 데이터 삽입'
3.
*/
-- 테스트 시작
START TRANSACTION;    -- 테스트를 위한 트랜잭션 시작

SELECT
        notification_history_id
      , notification_type_id
      , user_id
      , created_at
  FROM notification_history;    -- (1)

INSERT INTO comment( 
  user_id
, review_id
, content
,created_at
, modified_at 
)
VALUES( 
  'user02'
, 8, '좋은 리뷰네용'
, CURRENT_TIMESTAMP
, CURRENT_TIMESTAMP);     -- (2)

SELECT
        notification_history_id
      , notification_type_id
      , user_id
      , created_at
  FROM notification_history; -- (3)
  
SELECT
        comment_id
      , user_id
      , review_id
      , content
      , created_at
  FROM COMMENT;