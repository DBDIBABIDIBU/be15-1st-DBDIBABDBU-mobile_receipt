SELECT 
    user_id, -- 유저 ID 추가
    SUM(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount ELSE 0 END) AS '이번달 소비 내역',
    
    SUM(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount ELSE 0 END) AS '지난달 소비 내역',

    (SUM(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount ELSE 0 END)
    - SUM(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount ELSE 0 END)) AS '지출 차이',

    COUNT(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN 1 END) AS '이번달 거래 건수',

    COUNT(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN 1 END) AS '지난달 거래 건수',

    MAX(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount END) AS '이번달 최대 지출',

    MAX(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount END) AS '지난달 최대 지출',

    MIN(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount END) AS '이번달 최소 지출',

    MIN(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount END) AS '지난달 최소 지출',

    FLOOR(AVG(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount END)) AS '이번달 평균 지출',

    FLOOR(AVG(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount END)) AS '지난달 평균 지출'

FROM receipt
WHERE is_canceled = 'N'
  AND transaction_status = '승인'
  AND user_id = 'user01'
GROUP BY user_id; -- 유저별로 데이터를 그룹화하여 출력
