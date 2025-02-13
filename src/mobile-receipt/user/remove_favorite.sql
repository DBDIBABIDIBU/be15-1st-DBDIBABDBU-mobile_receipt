-- 즐겨찾기 삭제

DELIMITER //

CREATE OR REPLACE PROCEDURE sp_remove_favorite(
    IN p_user_id VARCHAR(30),
    IN p_store_id BIGINT
)
BEGIN
    -- 사용자 ID 존재 여부 확인
    CALL sp_check_user_exists(p_user_id);

    -- 즐겨찾기 존재 여부 확인 후 삭제
    IF EXISTS (
        SELECT 
		  		   1 
			 FROM favorite 
         WHERE user_id = p_user_id 
           AND store_id = p_store_id 
           AND deleted_at IS NULL
    ) THEN
        UPDATE favorite
           SET deleted_at = NOW()
         WHERE user_id = p_user_id 
           AND store_id = p_store_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오류: 삭제할 즐겨찾기가 없습니다.';
    END IF;
END //

DELIMITER ;

-- 테스트 케이스
-- 1. 성공 케이스: 즐겨찾기 삭제
CALL sp_remove_favorite('user01', 1);
SELECT 
		* 
  FROM favorite;

-- 2. 실패 케이스: 존재하지 않는 즐겨찾기 항목을 삭제 
CALL sp_remove_favorite('test_user', 999);

