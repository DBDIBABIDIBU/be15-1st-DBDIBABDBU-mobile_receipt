DELIMITER //

CREATE PROCEDURE receipt_cancel(IN p_receipt_id INT)
BEGIN
	 -- 하나라도 실패하면 rollback 및 실패 메세지 출력
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error occurred while canceling receipt';
    END;

    START TRANSACTION;

    -- 1. 취소 영수증 INSERT (원본 데이터를 복제하여 TRANSACTION_STATUS 변경)
    INSERT INTO receipt (
        user_id
      , store_id
      , card_company_id
      , receipt_body
      , amount
      , payment_method
      , transaction_status
      , is_canceled
      , created_at
      , deleted_at
    )
    SELECT 
	 		  user_id
         , store_id
         , card_company_id
         , receipt_body
         , amount
         , payment_method
         , '취소'
         , 'N' -- 취소된 영수증이므로 'Y'로 설정
         , NOW()
         , NULL
     FROM receipt
    WHERE receipt_id = p_receipt_id
	   AND is_canceled = 'N';

    -- 2. 기존 영수증 업데이트 (취소 처리를 표시)
    UPDATE receipt
    SET is_canceled = 'Y',
        deleted_at = NOW()
    WHERE receipt_id = p_receipt_id AND is_canceled = 'N';
    
    CALL sp_manage_point(p_user_id, p_receipt_id, '취소', NULL, (SELECT point_id FROM point WHERE receipt_id = p_receipt_id) ,NULL)

    COMMIT;
END //

DELIMITER ;

SELECT * FROM receipt WHERE transaction_status = '승인' AND is_canceled = 'N';


CALL receipt_cancel(20);


SELECT * FROM receipt WHERE created_at = (select deleted_at from receipt where receipt_id = 20)
or receipt_id = 20;

