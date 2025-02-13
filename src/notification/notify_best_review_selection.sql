DROP PROCEDURE if exists notify_best_review_selection;
DELIMITER //

CREATE PROCEDURE notify_best_review_selection()
BEGIN 
	INSERT 
	  INTO notification_history (notification_type_id, user_id, created_at)
			SELECT 
    		        4                                           -- 알림 타입
					, review.user_id                             -- 리뷰 작성자 ID
               , NOW() AS created_at                           -- 알림 생성일 (현재 시간)
           FROM review 
           LEFT JOIN (
               SELECT 
                      review_id
						  , COUNT(*) AS like_count            -- 각 리뷰의 좋아요 개수 계산
                 FROM review_like
               GROUP BY review_id
          ) rl ON review.review_id = rl.review_id       -- 리뷰와 좋아요 테이블 조인
          WHERE review.created_at >= DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m-01')  -- 지난달 작성된 리뷰 필터링
          AND review.created_at < DATE_FORMAT(NOW(), '%Y-%m-01')
          ORDER BY like_count DESC           -- 추천 수 내림차순
          LIMIT 3;                                                   -- 상위 3개 리뷰만 선택

END //
DELIMITER ;

-- 테스트케이스 --
/*
0. 테스트 데이터 삽입
1. 베스트 리뷰 선정 프로시저 실행
2. 베스트 리뷰 작성자 확인
3. 알람내역 테이블에 베스트 리뷰 작성자들에게 알람 생성되었는지 확인

*/
-- 테스트 시작
START TRANSACTION;

-- ------테스트 데이터 삽입--------
INSERT INTO review (
  review_id,
  user_id, 
  store_id, 
  content, 
  rating, 
  created_at, 
  modified_at, 
  deleted_at
)
VALUES
  (14,'user01', 1,  '좋았습니다!',     5, '2025-01-03 10:15:00', NOW(), NULL),
  (15,'user02', 2,  '가격이 저렴해요', 4, '2025-01-05 14:30:00', NOW(), NULL),
  (16,'user03', 3,  '서비스 별로...',  2, '2025-01-08 09:45:00', NOW(), NULL),
  (17,'user04', 4,  '재방문 의사 있음',4, '2025-01-12 13:00:00', NOW(), NULL),
  (18,'user05', 5,  '평범합니다',     3, '2025-01-15 16:20:00', NOW(), NULL),
  (19,'user06', 6,  '사장님이 친절해요',5, '2025-01-18 11:10:00', NOW(), NULL),
  (20,'user07', 7,  '24시간이라 편해요',4, '2025-01-20 08:50:00', NOW(), NULL),
  (21,'user08', 8,  '좀 시끄러움',     2, '2025-01-23 19:35:00', NOW(), NULL),
  (22,'user09', 9,  '비추천합니다...', 1, '2025-01-27 21:00:00', NOW(), NULL),
  (23,'user10',10, '진짜 최고!',     5, '2025-01-30 17:25:00', NOW(), NULL);
  
INSERT INTO review_like (
  review_id, 
  user_id, 
  created_at
)
VALUES
  (14, 'user01', NOW()),
  (14, 'user02', NOW()),
  (14, 'user03', NOW()),
  (14, 'user04', NOW()),
  (15, 'user05', NOW()),
  (15, 'user06', NOW()),
  (15, 'user07', NOW()),
  (16, 'user08', NOW()),
  (16, 'user09', NOW()),
  (18,'user10', NOW());
  


call notify_best_review_selection();         -- (1)
  
SELECT                                       -- (2)
    		4,    -- 알림 타입
         review.user_id,                             -- 리뷰 작성자 ID
         NOW() AS created_at,                   -- 알림 생성일 (현재 시간)
         rl.like_count                           -- 리뷰에 해당하는 좋아요 개수
  FROM review 
  LEFT JOIN (
               SELECT 
                      review_id
						  , COUNT(*) AS like_count            -- 각 리뷰의 좋아요 개수 계산
                 FROM review_like
                 GROUP BY review_id
            ) rl ON review.review_id = rl.review_id       -- 리뷰와 좋아요 테이블 조인
         WHERE review.created_at >= DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m-01')  -- 지난달 작성된 리뷰 필터링
         AND review.created_at < DATE_FORMAT(NOW(), '%Y-%m-01')
         ORDER BY like_count DESC           -- 추천 수 내림차순
         LIMIT 3;    
                  
SELECT * FROM notification_history;      -- (3)

ROLLBACK;