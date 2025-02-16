-- 즐겨찾기 추가

DELIMITER //

CREATE OR REPLACE PROCEDURE add_favorite(
    IN p_user_id VARCHAR(30),
    IN p_store_id BIGINT
)
BEGIN
    DECLARE v_favorite_exists INT DEFAULT 0;
    DECLARE v_store_exists INT DEFAULT 0;
    DECLARE v_user_deleted_at INT DEFAULT 0;

    -- 1. 매장 존재 여부 확인
    SELECT 
			  COUNT(*) 
		INTO v_store_exists
      FROM store
     WHERE store_id = p_store_id;

    IF v_store_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오류: 존재하지 않는 매장입니다.';
    END IF;

    -- 3. 이미 즐겨찾기에 추가된 경우 중복 방지
    SELECT 
	 		  COUNT(*) 
		INTO v_favorite_exists
      FROM favorite
     WHERE user_id = p_user_id 
	    AND store_id = p_store_id 
		 AND deleted_at IS NULL;

    IF v_favorite_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오류: 이미 즐겨찾기에 추가된 매장입니다.';
    END IF;

    -- 4. 즐겨찾기 추가 (중복 방지 및 논리 삭제 고려)
    INSERT 
	   INTO favorite 
	 (
	    user_id
	  , store_id
	  , created_at
	 )
    VALUES 
	 (
		p_user_id
	 , p_store_id
	 , NOW()
	 );

END //

DELIMITER ;

-- 테스트 케이스
-- 1. 성공 케이스
-- 예상 결과: 즐겨찾기 목록에 회원 id, 매장 id, 생성 일시 시점이 포함된다. 
CALL add_favorite('user01', 16);
SELECT
		  user_id 'user ID'
		, store_id 'store ID'
		, created_at '생성 일시'
  FROM favorite;
  
  
-- 2. 실패 케이스(동일 회원 id를 가진 회원이 동일한 매장을 즐겨찾기 추가한 경우)
-- 예상 결과: 에러 머시지('오류: 이미 즐겨찾기에 추가된 매장입니다.')를 출력하면서 에러 발생.
CALL add_favorite('user01', 16);
SELECT
		  user_id 'user ID'
		, store_id 'store ID'
		, created_at '생성 일시'
  FROM favorite;

