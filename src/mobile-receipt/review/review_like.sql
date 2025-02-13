-- 4. review_like

-- 좋아요 추가
INSERT INTO review_like (review_id, user_id, created_at)
VALUES(2, 'user05', NOW());

-- 좋아요 취소
DELETE FROM review_like
 WHERE review_like_id = 16;