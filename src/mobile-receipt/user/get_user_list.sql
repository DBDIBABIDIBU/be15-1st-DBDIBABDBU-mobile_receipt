-- 회원 목록 조회
DELIMITER //

CREATE OR REPLACE PROCEDURE sp_get_user_list(
    IN p_status ENUM('활성', '휴면', '탈퇴', '정지'),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    -- 회원 목록 조회 (페이징 적용)
    SELECT 
			    u.user_id
			  , u.contact_number
			  , u.email
			  , u.age
			  , u.gender
			  , u.account_status
			  , u.created_at
			  , a.authority_name
     FROM user u
    LEFT JOIN authority a ON u.authority_id = a.authority_id
    WHERE u.account_status = p_status
    ORDER BY u.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END //

DELIMITER ;

-- 테스트 케이스
-- 1. 활성 상태의 회원 목록 조회
CALL sp_get_user_list('활성', 5, 0);

-- 2. 탈퇴한 회원 목록 조회
CALL sp_get_user_list('탈퇴', 5, 0);

