DELIMITER $$

CREATE PROCEDURE GetGenderSpending(IN userId VARCHAR(50))
BEGIN
    DECLARE alarmStatus CHAR(1);
    DECLARE userGender VARCHAR(10);

    -- 유저 정보 제공 동의 여부 확인
    SELECT is_alarm_enabled, gender INTO alarmStatus, userGender 
    FROM user 
    WHERE user_id = userId;

    -- 정보 제공에 동의하지 않은 경우 에러 발생
    IF alarmStatus != 'Y' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '정보 제공에 동의하지 않은 유저입니다.';
    END IF;

    -- 동의한 경우에만 해당 성별 소비 내역 조회
    SELECT 
        u.gender AS 성별,
        FLOOR(AVG(r.amount)) AS 평균소비금액
    FROM receipt r
    JOIN user u ON r.user_id = u.user_id
    WHERE r.created_at BETWEEN '2025-01-01' AND '2025-02-29'  -- 2월 31일 → 2월 29일로 수정
      AND r.is_canceled = 'N'
      AND r.transaction_status = '승인'
      AND u.gender = userGender  -- 입력받은 유저의 성별을 기준으로 필터링
    GROUP BY u.gender;
END $$

DELIMITER ;

CALL GetGenderSpending('user09');
