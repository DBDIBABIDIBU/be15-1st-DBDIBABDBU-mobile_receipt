-- comment

INSERT
  INTO comment (
  user_id, 
  review_id, 
  content, 
  created_at, 
  modified_at
)
VALUES
('user10', 1, '퀄리티가 좋아요.', NOW(), NOW());

-- 댓글 내용 수정 
UPDATE comment
   SET content = '돈만 있으면 매일 갔음.'
	  , modified_at = NOW()
 WHERE comment_id = 1;
 
-- 댓글 소프트딜리트
UPDATE comment
   SET deleted_at = NOW()
 WHERE comment_id = 1;
