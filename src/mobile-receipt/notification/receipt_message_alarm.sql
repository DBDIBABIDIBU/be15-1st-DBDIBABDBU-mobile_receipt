DELIMITER //

CREATE TRIGGER after_receipt_insert
AFTER INSERT ON receipt
FOR EACH ROW
BEGIN
    -- 사용자의 알람 설정이 'Y'인 경우에만 알림을 생성
    IF (SELECT is_alarm_enabled FROM user WHERE user_id = NEW.user_id) = 'Y' THEN
        -- 알람 메시지를 notification_type_id 9 또는 10으로 설정
        INSERT INTO notification_history (notification_type_id, user_id, created_at)
        VALUES (
            CASE 
                WHEN NEW.transaction_status = '승인' THEN 6
                WHEN NEW.transaction_status = '취소' THEN 7
            END, 
            NEW.user_id, 
            NOW()
        );
    END IF;
END;
//

DELIMITER ;




SELECT * FROM notification_history;


SELECT * FROM notification_type;


SELECT * FROM receipt;