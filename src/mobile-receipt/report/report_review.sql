-- 리뷰 신고 : 회원은 리뷰를 신고할 수 있다. 
DROP PROCEDURE if exists report_review;
DELIMITER //

CREATE PROCEDURE report_review( -- 사용자id, 신고 타입, 리뷰id, 신고 내용
    IN reporting_user_id VARCHAR(30),
    IN report_type_id BIGINT(20),
    IN reported_review_id BIGINT(20),
    IN report_comment TEXT
)
BEGIN
	DECLARE reported_user_id VARCHAR(30);
	DECLARE counts INT(11);
	
	-- 유저 아이디 가져오기
	SELECT user_id INTO reported_user_id
	  FROM review
	 WHERE review_id = reported_review_id;
	 
	 UPDATE user
		 SET reported_count = reported_count+1
	  WHERE user_id = reported_user_id;
	 
	 -- 신고 테이블 데이터 추가
    INSERT 
	   INTO report(
		     report_type_id
		   , user_id
			, review_id
			, report_comment
			, created_at
			)
	 VALUES(
	        report_type_id
			, reporting_user_id
			, reported_review_id
			, report_comment
			, CURRENT_TIMESTAMP
			);
	 
	 -- 3. 만약 신고수가 5라면
	 SELECT reported_count INTO counts
		FROM user
	  WHERE user_id = reported_user_id;
	  if counts = 5 then
			-- 3.1 사용자의 누적신고수와 계정 상태 수정
			UPDATE user
			   SET account_status = '정지',
			       reported_count = 0
			 WHERE user_id = reported_user_id;
			
			-- 3.2 재제 내역 추가
			INSERT
			  INTO penalty_history( 
			       user_id, admin_id
			      , penalty_reason
			      , start_penalty_at
			      , end_penalty_at
					)
			VALUES(
			        reported_user_id
					, "user01"
					, "시스템 정지"
					, CURRENT_TIMESTAMP
					, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 7 DAY)
					);
		END if;

END //

DELIMITER ;

-- 테스트케이스 --
/*
1. user01 회원이 user03 회원이 작성한 리뷰를 신고
2. 신고 테이블 데이터 추가 확인
*/
START TRANSACTION;

call report_review('user01', 2 , 8, '못생겼어');    -- (1)

SELECT 
        report_id
      , report_type_id
      , user_id
      , comment_id
      , review_id
      , report_comment
      , created_at
  FROM report;  
  WHERE user_id='user08';                             -- (2)

SELECT 
        user_id
      , reported_count
  FROM user
  WHERE user_id='user08';                                 -- (3)

SELECT
        penalty_history_id
      , user_id
      , admin_id
      , penalty_reason
      , start_penalty_at
      , end_penalty_at
  FROM penalty_history;                      -- (4)
  
ROLLBACK;

DESCRIBE penalty_history;