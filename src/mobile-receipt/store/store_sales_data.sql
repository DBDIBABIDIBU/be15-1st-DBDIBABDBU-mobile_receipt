SELECT 
    store_id, -- 매장 ID 추가
    SUM(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount ELSE 0 END) AS '이달 매출',

    SUM(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount ELSE 0 END) AS '전월 매출',

    (SUM(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount ELSE 0 END)
    - SUM(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount ELSE 0 END)) AS '매출 차이',

    COUNT(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN 1 END) AS '이달 판매 건수',

    COUNT(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN 1 END) AS '전월 판매 건수',

    MAX(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount END) AS '이달 최고 매출',

    MAX(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount END) AS '전월 최고 매출',

    MIN(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount END) AS '이달 최저 매출',

    MIN(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount END) AS '전월 최저 매출',

    FLOOR(AVG(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount END)) AS '이달 평균 매출',

    FLOOR(AVG(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount END)) AS '전월 평균 매출',

    -- 일일 평균 판매량 (이번 달)
    FLOOR(SUM(CASE
        WHEN created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
         AND created_at < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
        THEN amount ELSE 0 END) 
        / DAY(CURRENT_DATE())) AS '이달 일일 평균 매출',

    -- 일일 평균 판매량 (지난 달)
    FLOOR(SUM(CASE
        WHEN created_at >= DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), '%Y-%m-01')
         AND created_at < DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
        THEN amount ELSE 0 END) 
        / DAY(LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)))) AS '전월 일일 평균 매출'

FROM receipt
WHERE is_canceled = 'N'
  AND transaction_status = '승인'
  AND store_id = 1 -- 특정 매장 ID를 지정하여 조회
GROUP BY store_id;




SELECT 
    HOUR(created_at) AS '시간대',
    SUM(amount) AS '시간대별 매출',
    COUNT(*) AS '시간대별 거래 건수',
    FLOOR(SUM(amount) / COUNT(*)) AS '평균 객단가'
FROM receipt
WHERE is_canceled = 'N'
  AND transaction_status = '승인'
  AND store_id = 1
  AND created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
GROUP BY HOUR(created_at)
ORDER BY HOUR(created_at);





SELECT 
    DAYNAME(created_at) AS '요일',
    SUM(amount) AS '요일별 매출',
    COUNT(*) AS '거래 건수',
    FLOOR(SUM(amount) / COUNT(*)) AS '평균 객단가'
FROM receipt
WHERE is_canceled = 'N'
  AND transaction_status = '승인'
  AND store_id = 1
  AND created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
GROUP BY DAYNAME(created_at)
ORDER BY FIELD(DAYNAME(created_at), 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


SELECT 
    COUNT(DISTINCT CASE WHEN visit_count = 1 THEN user_id END) AS '신규 고객 수',
    COUNT(DISTINCT CASE WHEN visit_count > 1 THEN user_id END) AS '재방문 고객 수',
    FLOOR(AVG(visit_count)) AS '고객 1인당 평균 방문 횟수'
FROM (
    SELECT user_id, COUNT(*) AS visit_count
    FROM receipt
    WHERE is_canceled = 'N'
      AND transaction_status = '승인'
      AND store_id = 1
      AND created_at >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
    GROUP BY user_id
) AS visit_stats;
