-- 이용 제한 내역 조회 : 이용 제한 내역을 조회할 수 있다.
SELECT * FROM penalty_history;

SELECT  penalty_reason
      , start_penalty_at
      , end_penalty_at
   FROM penalty_history
   WHERE user_id = 'user01';
   
SELECT  penalty_reason
      , start_penalty_at
      , end_penalty_at
   FROM penalty_history
   WHERE user_id = 'user02';