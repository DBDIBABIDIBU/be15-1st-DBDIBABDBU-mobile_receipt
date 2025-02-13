-- review

-- 사전에 필요한 데이터 삽입
INSERT INTO review (
  user_id, 
  store_id, 
  content, 
  rating, 
  created_at, 
  modified_at, 
  deleted_at
)
VALUES
  ('user01', 1,  '좋았습니다!',     5, NOW(), NOW(), NULL),
  ('user02', 2,  '가격이 저렴해요', 4, NOW(), NOW(), NULL),
  ('user03', 3,  '서비스 별로...',  2, NOW(), NOW(), NULL),
  ('user04', 4,  '재방문 의사 있음',4, NOW(), NOW(), NULL),
  ('user05', 5,  '평범합니다',     3, NOW(), NOW(), NULL),
  ('user06', 6,  '사장님이 친절해요',5, NOW(), NOW(), NULL),
  ('user07', 7,  '24시간이라 편해요',4, NOW(), NOW(), NULL),
  ('user08', 8,  '좀 시끄러움',     2, NOW(), NOW(), NULL),
  ('user09', 9,  '비추천합니다...', 1, NOW(), NOW(), NULL),
  ('user10',10, '진짜 최고!',     5, NOW(), NOW(), NULL), 
  ('user02', 1, '또 올게요!',     5, DATE_SUB(NOW(), INTERVAL 1 MONTH), DATE_SUB(NOW(), INTERVAL 1 MONTH), NULL),
  ('user03', 1, '굳!', 5, DATE_SUB(NOW(), INTERVAL 1 MONTH), DATE_SUB(NOW(), INTERVAL 1 MONTH), NULL),
  ('user04', 1, '좋아요', 5, DATE_SUB(NOW(), INTERVAL 1 MONTH), DATE_SUB(NOW(), INTERVAL 1 MONTH), NULL);

-- 12. comment
--
INSERT INTO `comment` (
  user_id, 
  review_id, 
  content, 
  created_at, 
  modified_at, 
  deleted_at
)
VALUES
  ('user01', 1,  '동감합니다!',         NOW(), NOW(), NULL),
  ('user02', 2,  '저도 싸게 샀어요.',    NOW(), NOW(), NULL),
  ('user03', 3,  '정말 별로였나요?',     NOW(), NOW(), NULL),
  ('user04', 4,  '괜찮아 보이네요~',    NOW(), NOW(), NULL),
  ('user05', 5,  'ㅇㅇ 평범함',         NOW(), NOW(), NULL),
  ('user06', 6,  '저도 친절함에 공감!',  NOW(), NOW(), NULL),
  ('user07', 7,  '한밤에도 편하죠 ㅎㅎ',  NOW(), NOW(), NULL),
  ('user08', 8,  '맞아요 좀 시끄럽...',  NOW(), NOW(), NULL),
  ('user09', 9,  '헉... 왜 비추천?',     NOW(), NOW(), NULL),
  ('user10',10, '완전 동의합니다!',      NOW(), NOW(), NULL);

--
-- 13. `review_like`
--
-- 25-02-12 하채린: 좋아요 갯수 늘림 
INSERT INTO `review_like` (
  review_id, 
  user_id, 
  created_at
)
VALUES
  (1, 'user01', NOW()),
  (2, 'user02', NOW()),
  (3, 'user03', NOW()),
  (4, 'user04', NOW()),
  (5, 'user05', NOW()),
  (6, 'user06', NOW()),
  (7, 'user07', NOW()),
  (8, 'user08', NOW()),
  (9, 'user09', NOW()),
  (10,'user10', NOW()),
  (1, 'user02', NOW()),
  (1, 'user03', NOW()),
  (11, 'user04', DATE_SUB(NOW(), INTERVAL 1 MONTH)),
  (11, 'user05', DATE_SUB(NOW(), INTERVAL 1 MONTH)),
  (11, 'user06', DATE_SUB(NOW(), INTERVAL 1 MONTH)),
  (12, 'user07', DATE_SUB(NOW(), INTERVAL 1 MONTH)),
  (12, 'user08', DATE_SUB(NOW(), INTERVAL 1 MONTH)),
  (13, 'user09', DATE_SUB(NOW(), INTERVAL 1 MONTH));
  

--
-- 14. review_image
--
-- 25-02-12 하채린: 리뷰 사진 늘림
INSERT INTO `review_image` (
  review_id, 
  review_image_url
)
VALUES
  (1, 'http://example.com/review/rev1_img1.jpg'),
  (2, 'http://example.com/review/rev2_img1.jpg'),
  (3, 'http://example.com/review/rev3_img1.jpg'),
  (4, 'http://example.com/review/rev4_img1.jpg'),
  (5, 'http://example.com/review/rev5_img1.jpg'),
  (6, 'http://example.com/review/rev6_img1.jpg'),
  (7, 'http://example.com/review/rev7_img1.jpg'),
  (8, 'http://example.com/review/rev8_img1.jpg'),
  (9, 'http://example.com/review/rev9_img1.jpg'),
  (10,'http://example.com/review/rev10_img1.jpg'), 
  (1, 'http://example.com/review/rev1_img2.jpg');


-- 리뷰 생성
INSERT
  INTO review (user_id, store_id, content, rating, created_at, modified_at)
VALUES ('user10', 4, '맛집 인정이요.', 5, NOW(), NOW());

-- 리뷰 당 좋아요 카운트 함수
DELIMITER //

CREATE FUNCTION get_likes_count(input_review_id BIGINT)
RETURNS INT
BEGIN
DECLARE likes_count INT;


SELECT COUNT(*) INTO likes_count
FROM review_like
WHERE review_id = input_review_id;

RETURN likes_count;
END //

DELIMITER ;

-- 리뷰 최신순 조회
SELECT 
       r.user_id
 	  , r.content
	  , r.rating
	  , r.created_at
	  , COALESCE(l.likes_count, 0)
	  , GROUP_CONCAT(DISTINCT c.comment_id SEPARATOR ', ')
	  , GROUP_CONCAT(DISTINCT ri.review_image_url SEPARATOR ', ')
  FROM review r
  LEFT JOIN (SELECT review_id, COUNT(*) AS likes_count
              FROM review_like 
             GROUP BY review_id) l ON r.review_id = l.review_id
  LEFT JOIN comment c ON r.review_id = c.review_id
        AND c.deleted_at IS NULL
  LEFT JOIN review_image ri ON r.review_id = ri.review_id
 WHERE r.store_id = 1
 GROUP BY r.review_id
 ORDER BY r.created_at DESC;
 
 -- 리뷰 좋아요 많은 순 조회
SELECT r.user_id
     , r.content
	  , r.rating
	  , r.created_at
	  , COALESCE(l.likes_count, 0)
	  , GROUP_CONCAT(DISTINCT c.comment_id SEPARATOR ', ')
	  , GROUP_CONCAT(DISTINCT ri.review_image_url SEPARATOR ', ')
  FROM review r
  LEFT JOIN (SELECT review_id, COUNT(*) AS likes_count 
               FROM review_like 
              GROUP BY review_id) l ON r.review_id = l.review_id
  LEFT JOIN comment c ON r.review_id = c.review_id 
        AND c.deleted_at IS NULL
  LEFT JOIN review_image ri ON r.review_id = ri.review_id
 WHERE r.store_id = 1
 GROUP BY r.review_id
 ORDER BY COALESCE(l.likes_count, 0) DESC;
    
-- 베스트리뷰 top3 조회
SELECT
       r.user_id
     , r.content
     , r.rating
     , r.created_at
     , COALESCE(l.likes_count, 0)
     , GROUP_CONCAT(DISTINCT c.comment_id SEPARATOR ', ') AS comment_ids
     , GROUP_CONCAT(DISTINCT ri.review_image_url SEPARATOR ', ') AS review_image_urls
  FROM review r
     LEFT JOIN (
          SELECT review_id
               , COUNT(*) likes_count
          FROM review_like
          WHERE created_at >= DATE_SUB(DATE_FORMAT(NOW(), '%Y-%m-01'), INTERVAL 1 MONTH) 
             AND created_at < DATE_FORMAT(NOW(), '%Y-%m-01')
          GROUP BY review_id
       ) l ON r.review_id = l.review_id
     LEFT JOIN comment c ON r.review_id = c.review_id AND c.deleted_at IS NULL
     LEFT JOIN review_image ri ON r.review_id = ri.review_id
 WHERE r.created_at >= DATE_SUB(DATE_FORMAT(NOW(), '%Y-%m-01'), INTERVAL 1 MONTH) 
   AND r.created_at < DATE_FORMAT(NOW(), '%Y-%m-01')
   AND r.store_id = 1
 GROUP BY r.review_id
 ORDER BY COALESCE(l.likes_count, 0) DESC
 LIMIT 3;

-- 리뷰 수정
UPDATE review
   SET content = '사장님이 착하고 가격이 친절해요.'
     , rating = 5
     , modified_at = NOW()
 WHERE review_id = 11;
 
-- 리뷰 소프트딜리트
UPDATE review
   SET deleted_at = NOW()
 WHERE review_id = 1;
 
-- 25-02-13 하채린 : 팀원들과 논의 끝에 리뷰는 소프트딜리트만 하기로 결정
-- 리뷰 하드딜리트
-- DELETE FROM review
-- WHERE deleted_at IS NOT NULL
-- AND deleted_at < NOW() - INTERVAL 1 YEAR;

-- 회원, 매장이 하드딜리트 될 때
-- 리뷰, 댓글, 리뷰, 좋아요 같이 삭제되는 지 확인용

DELETE FROM user
 WHERE user_id = 'user01';
 
DELETE FROM store
 WHERE store_id = 5;