DELIMITER //

CREATE TRIGGER trg_store_soft_delete
AFTER UPDATE ON store
FOR EACH ROW
BEGIN
    -- deleted_at 값이 NULL에서 변경될 때만 실행
    IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
        
        -- review 테이블의 deleted_at 업데이트 (이미 값이 있는 경우 건너뜀)
        UPDATE review
        SET deleted_at = NEW.deleted_at
        WHERE store_id = NEW.store_id 
        AND deleted_at IS NULL;

        -- favorite 테이블의 deleted_at 업데이트 (이미 값이 있는 경우 건너뜀)
        UPDATE favorite
        SET deleted_at = NEW.deleted_at
        WHERE store_id = NEW.store_id 
        AND deleted_at IS NULL;

    END IF;
END //

DELIMITER ;



-- 테스트 케이스

UPDATE favorite
   SET deleted_at = NULL
 WHERE store_id = 1;


