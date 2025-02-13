-- 리뷰 등록 시 알림	: 리뷰 등록 시 매장 관리자에게 리뷰 등록 메세지를 전송한다.
DROP TRIGGER if exists after_review_insert_notification;
DELIMITER //
CREATE TRIGGER after_review_insert_notification
AFTER INSERT ON review
FOR EACH ROW
BEGIN
		DECLARE seller_id VARCHAR(30);
		
		SELECT user_id INTO seller_id
		  FROM store
		 WHERE store_id = NEW.store_id;
		IF (SELECT is_alarm_enabled FROM user WHERE user_id = seller_id) = 'Y' THEN
    		-- 알림 삽입
    		INSERT INTO notification_history (
			  user_id
			, notification_type_id
			, created_at
			)
         VALUES (
			seller_id
			, 5
			, CURRENT_TIMESTAMP
			);     /* notification_type_id는 임의의 알림 메세지를 참조하는 id */
		END if;
END //
DELIMITER ;
SELECT * FROM store;
SELECT * FROM user;
-- 테스트 코드 --
/*
1. user01 회원이 리뷰를 작성
2. 리뷰 테이블 확인
3. 알림 테이블 확인
*/
START TRANSACTION;

INSERT
  INTO review(
    user_id
  , store_id
  , content
  , rating
  , created_at
  , modified_at
  )
VALUES(
  'user01'
  , 8
  , '너무 맛있어요'
  , 5
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
);                               -- (1)

SELECT 
        user_id
      , store_id
      , content
      , rating
      , created_at
      , modified_at
  FROM review
 WHERE user_id = 'user01';       -- (2)
 
SELECT 
        notification_history_id
      , notification_type_id
      , user_id
      , created_at
  FROM notification_history;     -- (3)

ROLLBACK;

DESCRIBE notification_history;