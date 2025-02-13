-- 카테고리 별 기간 내 평균 소비 금액

SELECT c.category_name	AS category
     , FLOOR(AVG(r.amount))	AS '기간 내 평균 소비 금액'
  FROM receipt r
  JOIN store s ON r.store_id = s.store_id
  JOIN category c ON s.category_id = c.category_id
 WHERE s.category_id = '1'
   AND r.created_at BETWEEN '2025-01-01 00:00:00' AND '2025-02-29 23:59:59'
   AND r.is_canceled = 'N'
   AND r.transaction_status = '승인'
   AND r.user_id = 'user01'
 GROUP BY c.category_name;







