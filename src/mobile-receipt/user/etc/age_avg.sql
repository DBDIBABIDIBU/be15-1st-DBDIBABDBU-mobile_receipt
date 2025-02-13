DELIMITER //

CREATE PROCEDURE GetUserSpending(IN userId VARCHAR(30))
BEGIN
    DECLARE alarmStatus CHAR(1);

    -- 유저의 정보 제공 동의 여부 조회
    SELECT is_alarm_enabled INTO alarmStatus FROM user WHERE user_id = userId;

    -- 정보 제공 동의하지 않으면 에러 발생
    IF alarmStatus != 'Y' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '정보 제공에 동의하지 않은 유저입니다.';
    END IF;

    -- 동의한 경우에만 소비 내역 조회
    SELECT 
        CASE
            WHEN u.age BETWEEN 10 AND 19 THEN '10대'
            WHEN u.age BETWEEN 20 AND 29 THEN '20대'
            WHEN u.age BETWEEN 30 AND 39 THEN '30대'
            WHEN u.age BETWEEN 40 AND 49 THEN '40대'
            WHEN u.age BETWEEN 50 AND 59 THEN '50대'
            ELSE '기타'
        END AS 연령대,
        FLOOR(AVG(r.amount)) AS 평균소비금액
    FROM receipt r
    JOIN user u ON r.user_id = u.user_id
    WHERE u.user_id = userId
      AND r.created_at BETWEEN '2025-01-01 00:00:00' AND '2025-02-29 23:59:59'
      AND r.is_canceled = 'N'
      AND r.transaction_status = '승인';
END //

DELIMITER ;


CALL GetUserSpending('user09');