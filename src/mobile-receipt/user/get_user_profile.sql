-- 프로필 조회
-- 사용자 ID 존재 여부 확인
CALL sp_check_user_exists('user01');

-- 사용자 프로필 조회
SELECT 
  u.user_id,
  u.contact_number,
  u.email,
  u.age,
  u.gender,
  u.profile_image_url,
  u.account_status,
  u.created_at,
  u.modified_at,
  a.authority_name
FROM user u
LEFT JOIN authority a ON u.authority_id = a.authority_id
WHERE u.user_id = 'user01';