SELECT r.receipt_id	AS 영수증ID
     , r.user_id	AS 사용자ID
     , r.store_id	AS 매장ID
     , r.amount	AS 소비금액
     , r.payment_method	AS 결제방법
     , r.transaction_status	AS 거래상태
     , r.created_at	AS 발행시간
FROM receipt r
WHERE r.user_id = 'user06'
  AND r.created_at BETWEEN '2025-01-01 00:00:00' AND '2025-02-29 23:59:59'
ORDER BY r.created_at;
