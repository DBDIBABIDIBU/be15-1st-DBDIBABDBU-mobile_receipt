-- review_image

-- 리뷰 이미지 추가
INSERT INTO review_image (review_id, review_image_url)
VALUES (1, 'http://example.com/review/rev1_img2.jpg');

-- 리뷰 이미지 조회
SELECT 
       r.review_id
	  , r.user_id
	  , ri.review_image_id
	  , ri.review_image_url
  FROM review r
  LEFT JOIN review_image ri ON r.review_id = ri.review_id
 WHERE r.review_id = 1
 ORDER BY r.review_id;

-- 리뷰 이미지 삭제
DELETE FROM review_image
 WHERE review_image_id = 13;