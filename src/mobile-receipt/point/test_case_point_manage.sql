-- 테스트를 위한 초기 데이터 설정
-- 1. authority 데이터 생성
INSERT INTO `authority` (authority_id, authority_name) 
VALUES (1, 'ROLE_USER');

-- 2. 테스트용 store 생성을 위한 category 생성
INSERT INTO `category` (category_id, category_name, created_at, modified_at)
VALUES (1, '음식점', NOW(), NOW());

-- 3. 테스트용 user 생성
INSERT INTO `user` (
    user_id, 
    authority_id,
    password,
    contact_number,
    email,
    age,
    gender,
    account_status,
    created_at,
    modified_at,
    remaining_point
) VALUES (
    'test_user',                    -- user_id
    1,                             -- authority_id
    'test1234',                    -- password
    '01012345678',                 -- contact_number
    'test@test.com',               -- email
    25,                            -- age
    'M',                           -- gender
    '정지',                         -- account_status
    NOW(),                         -- created_at
    NOW(),                         -- modified_at
    1000.00                        -- remaining_point (초기값)
);

-- 4. 테스트용 store 생성
INSERT INTO `store` (
    store_id,
    user_id,
    category_id,
    business_registration_number,
    store_name,
    contact_number,
    address,
    address_detail,
    business_hours,
    average_rating,
    created_at,
    modified_at
) VALUES (
    1,
    'test_user',
    1,
    '123-45-67890',
    '테스트 가게',
    '02-123-4567',
    '서울시 강남구',
    '1층',
    '09:00-18:00',
    4.5,
    NOW(),
    NOW()
);

-- 5. 테스트용 receipt 생성
INSERT INTO `receipt` (
    receipt_id,
    user_id,
    store_id,
    receipt_body,
    amount,
    payment_method,
    transaction_status,
    is_canceled,
    created_at
) VALUES 
(1001, 'test_user', 1, '영수증1', 10000, '현금', '승인', 'N', NOW()),
(1002, 'test_user', 1, '영수증2', 20000, '현금', '승인', 'N', NOW()),
(1003, 'test_user', 1, '영수증3', 30000, '현금', '승인', 'N', NOW());

-- 테스트 케이스 실행
-- 1. 성공 케이스

-- Case 1: 정상적인 포인트 적립
CALL sp_manage_point(
    'test_user',                           -- user_id
    1001,                                  -- receipt_id
    '적립',                                -- transaction_type
    100,                                   -- point
    NULL                                   -- reference_point_id
);
SELECT user_id, remaining_point FROM USER;

-- Case 2: 정상적인 포인트 사용
CALL sp_manage_point(
    'test_user',
    1002,
    '사용',
    50,
    NULL
);

-- Case 3: 정상적인 취소
CALL sp_manage_point(
    'test_user',
    1003,
    '취소',
    50,                                    -- 원본과 동일한 포인트
    (SELECT point_id FROM point WHERE receipt_id = 1002) -- 원본 거래의 point_id
);

-- 2. 실패 케이스

-- Case 4: 실패 - 존재하지 않는 사용자
CALL sp_manage_point(
    'non_existing_user',
    1001,
    '적립',
    100,
    NULL
);

-- Case 5: 실패 - 존재하지 않는 영수증
CALL sp_manage_point(
    'test_user',
    9999,
    '적립',
    100,
    NULL
);

-- Case 6: 실패 - 보유 포인트보다 많은 금액 사용 시도
CALL sp_manage_point(
    'test_user',
    1002,
    '사용',
    9999999,
    NULL
);

-- Case 7: 실패 - 존재하지 않는 원본 거래 취소 시도
CALL sp_manage_point(
    'test_user',
    1003,
    '취소',
    50,
    99999                                  -- 존재하지 않는 point_id
);

-- Case 8: 실패 - 이미 취소된 거래를 다시 취소
CALL sp_manage_point(
    'test_user',
    1003,
    '취소',
    50,
    (SELECT point_id FROM point WHERE receipt_id = 1002) -- 이미 취소된 거래
);

-- 테스트 결과 확인
SELECT user_id, remaining_point 
FROM `user` 
WHERE user_id = 'test_user';

SELECT p.point_id,
       p.user_id,
       p.receipt_id,
       p.transaction_type,
       p.point,
       p.reference_point_id,
       p.is_canceled,
       p.created_at
FROM point p
WHERE p.user_id = 'test_user'
ORDER BY p.created_at DESC;

