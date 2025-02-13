-- 로그인 기록 조회

-- 사용자 ID 존재 여부 확인
CALL sp_check_user_exists('user01');

-- 최근 로그인 기록 조회 (최신 10개)
SELECT 
  login_at,
  ip_address,
  device_type
FROM login_history
WHERE user_id = 'user01'
ORDER BY login_at DESC
LIMIT 10;