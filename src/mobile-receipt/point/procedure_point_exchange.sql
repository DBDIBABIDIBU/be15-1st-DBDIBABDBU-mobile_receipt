-- 비즈니스 로직
-- 1. 상품 존재 여부 및 가격 확인
-- 2. 상품 재고 확인
-- 3. 물품 교환을 위한 총 필요 포인트 계산 (포인트 가격 * 교환 수량)
-- 4. 포인트 차감 (sp_manage_point 프로시저 사용)
-- 5. 상품 재고 차감
-- 6. 교환 이력 기록

DELIMITER $$

CREATE PROCEDURE sp_point_exchange (
    IN p_user_id VARCHAR(30),
    IN p_point_product_id BIGINT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_total_price INT;
    DECLARE v_current_stock INT;
    DECLARE v_product_price INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Point exchange failed';
    END;

    START TRANSACTION;
    
    -- 1. 상품 존재 여부 및 가격 확인
    SELECT price, quantity 
    INTO v_product_price, v_current_stock
    FROM point_product 
    WHERE point_product_id = p_point_product_id
    AND deleted_at IS NULL
    FOR UPDATE;  -- 재고 락

    IF v_product_price IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product not found';
    END IF;

    -- 2. 재고 확인
    IF v_current_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Not enough stock';
    END IF;

    -- 3. 총 필요 포인트 계산
    SET v_total_price = v_product_price * p_quantity;

    -- 4. 포인트 차감 프로시저 호출
    CALL sp_manage_point(
        p_user_id,
        NULL,         -- receipt_id는 NULL (포인트 상품 교환은 영수증 없음)
        '사용',
        v_total_price,
        NULL,         -- reference_point_id
        0            -- payment_amount (포인트 사용이므로 0)
    );

    -- 5. 상품 재고 차감
    UPDATE point_product
    SET quantity = quantity - p_quantity,
        modified_at = NOW()
    WHERE point_product_id = p_point_product_id;

    -- 6. 교환 이력 기록
    INSERT INTO point_exchange_history (
        user_id,
        point_product_id,
        quantity,
        created_at
    ) VALUES (
        p_user_id,
        p_point_product_id,
        p_quantity,
        NOW()
    );

    COMMIT;
END $$

DELIMITER ;
