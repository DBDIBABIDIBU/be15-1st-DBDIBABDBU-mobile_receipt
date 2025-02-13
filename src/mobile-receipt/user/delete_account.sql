-- 회원탈퇴
DELIMITER //

CREATE OR REPLACE PROCEDURE delete_account(
    IN p_user_id VARCHAR(30),
    IN p_password VARCHAR(255),
    OUT deleted_id VARCHAR(30)
)
BEGIN
    DECLARE authority_name VARCHAR(30);
    DECLARE password_correct INT DEFAULT 0;

    -- 1. 비밀번호 검증
    SELECT 
	 		  COUNT(*) INTO password_correct
      FROM user
     WHERE user_id = p_user_id 
	    AND PASSWORD = p_password;

    IF password_correct = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '회원 탈퇴 실패: 회원의 정보가 일치하지 않습니다';
    END IF;

    -- 2. 회원 권한 확인
    SELECT 
	 		  a.authority_name INTO authority_name
    	FROM user u
      JOIN authority a ON u.authority_id = a.authority_id
     WHERE u.user_id = p_user_id;

    -- 3. 탈퇴 처리 로직
    CASE 
        -- 일반 사용자(USER) 탈퇴 (비활성화 처리)
        WHEN authority_name = 'USER' THEN
            UPDATE user
            	SET   account_status = '탈퇴' 
						 , deleted_at = NOW()
             WHERE user_id = p_user_id;

        -- 판매자(SELLER) 탈퇴 (매장 비활성화 후 탈퇴)
        WHEN authority_name = 'SELLER' THEN
            UPDATE store
            	SET deleted_at = NOW()
             WHERE user_id = p_user_id;

            UPDATE user
            	SET   account_status = '탈퇴'
					    , deleted_at = NOW()
             WHERE user_id = p_user_id;

        -- 관리자(ADMIN) 영구 삭제
        WHEN authority_name = 'ADMIN' THEN
        
            -- 관리자 계정 최종 삭제
            DELETE 
				  FROM user 
				 WHERE user_id = p_user_id;

        ELSE 
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '회원 탈퇴 실패: 알 수 없는 회원 유형입니다.';
    END CASE;
    
    SET deleted_id = p_user_id;
END //

DELIMITER ;

-- 테스트 케이스
-- 1. 판매자 탈퇴(성공) -> 관련 매장 비활성화 후 계정 비활성화
-- 예상결과: Store 테이블의 deleted_at 컬럼에 삭제 시점 기록, User 테이블의 account_status를 '탈퇴'로 변경하고 
-- deleted_at에 회원 삭제시점에 대한 기록이 포함되어 있다. 

SET @deleted_id = '';
CALL delete_account('user02', 'pw02', @deleted_id);

SELECT
		  u.user_id 'user ID'
		, u.user_name '회원명'
		, u.account_status '회원 상태'
		, u.deleted_at '삭제 일시'
		, s.deleted_at '매장 삭제 일시'
 FROM user u
 JOIN store s ON u.user_id = s.user_id
 WHERE user_id = @deleted_id;
 
 
-- 2. 비밀번호 틀림(실패)
-- 예상결과: 에러 메시지('회원 탈퇴 실패: 회원의 정보가 일치하지 않습니다')를 출력하고 에러 발생.
CALL sp_user_deactivate('user02', 'wrongpassword');