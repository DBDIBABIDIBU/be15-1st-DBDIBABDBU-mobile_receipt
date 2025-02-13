 -- 리뷰에 좋아요가 추가되면 리뷰 작성자에게 알림을 전송한다.  
DROP TRIGGER if EXISTS after_like_insert_notinication;
DELIMITER $$  
CREATE TRIGGER after_like_insert_notinication
AFTER INSERT ON `review_like`
FOR EACH ROW
BEGIN
    DECLARE review_author_id VARCHAR(30);

    -- 리뷰 작성자 찾기
    SELECT user_id INTO review_author_id
    FROM review
    WHERE review_id = NEW.review_id;
	 IF (SELECT is_alarm_enabled FROM user WHERE user_id = review_author_id) = 'Y' THEN
	    -- 알림 삽입
	    INSERT 
		   INTO notification_history 
			(user_id, notification_type_id, created_at)
	    VALUES 
		   (review_author_id, 1, NOW());     /* notification_type_id는 임의의 알림 메세지를 참조하는 id */
	 END if;
END $$
DELIMITER ;

-- 테스트 --
/*
테스트 계획
1. 현재 좋아요 테이블에는 10개의 데이터 존재. 1번 리뷰에는 user01가 좋아요를 누름
2. user03 유저가 user01이 작성한 1번 리뷰에 좋아요를 누름
3. 트리거가 정상적으로 작동했다면 11개의 테이터와 user01에 대한 1번 알람이 기록됨
*/
-- 테스트 시작
START TRANSACTION;    -- 테스트를 위한 트랜잭션 시작

SELECT * FROM `review_like`;    -- (1)

INSERT INTO `review_like`(user_id, review_id, created_at)
VALUES('user03', 8, CURRENT_TIMESTAMP);     -- (2)

SELECT * FROM `review_like`; -- (3)
SELECT * FROM notification_history;
ROLLBACK;     -- 테스트 이후 데이터 유지 위한 데이터 롤백
