CREATE OR REPLACE VIEW user_receipts_view AS
SELECT 
    s.store_name AS 매장명,
    r.user_id AS 아이디,
    cc.card_company_name AS 카드명,
    r.payment_method AS 결제방식,
    r.transaction_status AS 거래구분,
    r.amount AS 결제금액,
    r.receipt_body AS 결제내용,
    r.created_at  AS 결제시간
FROM receipt r
JOIN store s ON r.store_id = s.store_id
JOIN card_company cc ON r.card_company_id = cc.card_company_id
WHERE r.deleted_at IS NULL;



SELECT 
		 * 
  FROM user_receipts_view 
 WHERE 아이디 = 'user10'
   AND 결제시간 BETWEEN '2024-01-01' AND '2025-12-31';
   
   
SELECT 
		  * 
  FROM user_receipts_view 
 WHERE 아이디 = 'user10'
   AND 매장명 LIKE '%가게%';   
   
SELECT 
		  * 
  FROM user_receipts_view 
 WHERE 아이디 = 'user10'
   AND 결제방식 = '신용';
