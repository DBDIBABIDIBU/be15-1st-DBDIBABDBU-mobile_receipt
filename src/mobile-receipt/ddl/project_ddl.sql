-- 외래 키 체크 해제
SET FOREIGN_KEY_CHECKS = 0;

-- 1. authority
CREATE TABLE `authority` (
  `authority_id` INT NOT NULL AUTO_INCREMENT,
  `authority_name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`authority_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. category
CREATE TABLE `category` (
  `category_id` BIGINT NOT NULL AUTO_INCREMENT,
  `category_name` VARCHAR(60) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT NOW(),
  `modified_at` TIMESTAMP NOT NULL DEFAULT NOW(),
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. user
CREATE TABLE `user` (
  `user_id` VARCHAR(30) NOT NULL,
  `authority_id` INT NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `user_name` VARCHAR(50) NOT NULL DEFAULT '홍길동',
  `contact_number` VARCHAR(15) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `age` INT NOT NULL,
  `gender` ENUM('M','F') NOT NULL,
-- 2025-02-11 박양하:  ERD와 Type 매칭 TEXT -> VARCHAR(255) DEFAULT 설정 임의 설정 후 Not null로 제약조건  변경)
  `profile_image_url` VARCHAR(255) NOT NULL DEFAULT('https://billon.com/profile_image_test_url/'),
-- 2025-02-12 박양하: boolean을 ENUM Y,N 으로 처리하기로 했으나 아래 정보제공동의와 알림수신동의가  TINYINT로 선언되어 타입 수정
  `is_alarm_enabled` ENUM('Y','N') NOT NULL DEFAULT('N'),
  `is_consent_provided` ENUM('Y','N') NOT NULL DEFAULT('N'),
-- 2025-02-12 박성용: ENUM 활성 추가. DEFAULT 활성으로 설정
  `account_status` ENUM('휴면','탈퇴','정지', '활성') NOT NULL DEFAULT('활성'),
  `reported_count` INT NOT NULL DEFAULT 0,
--  2025-02-12 박성용: created_at 및 modifed_at default 값 설정
  `created_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  `modified_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  `deleted_at` TIMESTAMP NULL,
--  2025-02-12 박성용: remaining_point type INT로 변경 및 DEFAULT 0으로 설정
  `remaining_point` INT NULL DEFAULT(0),
  PRIMARY KEY (`user_id`),
  CONSTRAINT `FK_AUTHORITY` FOREIGN KEY (`authority_id`) REFERENCES `authority`(`authority_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. store
CREATE TABLE `store` (
  `store_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `category_id` BIGINT NOT NULL,
  `business_registration_number` VARCHAR(255) NOT NULL,
-- 2025-02-11 박양하:  ERD와 Type 매칭 TEXT -> VARCHAR(255) DEFAULT 설정 임의 설정 후 Not null로 제약조건  변경)
  `business_operation_certificate_url` VARCHAR(255) NOT NULL DEFAULT('https://billon.com/brn_test_url/'),
  `store_name` VARCHAR(150) NOT NULL,
  `contact_number` VARCHAR(15) NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `address_detail` VARCHAR(90) NOT NULL,
  `business_hours` VARCHAR(255) NOT NULL,
  `average_rating` DECIMAL(2, 1) NOT NULL,
  -- 25-02-12 하채린 : DEFAULT(NOW()) 추가
  `created_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  -- 25-02-12 하채린 : DEFAULT(NOW()) 추가
  `modified_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`store_id`),
  CONSTRAINT `FK_USER_STORE` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_CATEGORY_STORE` FOREIGN KEY (`category_id`) REFERENCES `category`(`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. notification_type
CREATE TABLE `notification_type` (
  `notification_type_id` BIGINT NOT NULL AUTO_INCREMENT,
  `notification_message` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`notification_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. report_type
CREATE TABLE `report_type` (
  `report_type_id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL,
  `modified_at` TIMESTAMP NOT NULL,
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`report_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. card_company
CREATE TABLE `card_company` (
  `card_company_id` BIGINT NOT NULL AUTO_INCREMENT,
  `card_company_name` VARCHAR(50) NOT NULL,
  `created_at` TIMESTAMP NOT NULL,
  `modified_at` TIMESTAMP NOT NULL,
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`card_company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. receipt
-- 2025-02-11 박양하: JSON → LONGTEXT로 변경
CREATE TABLE `receipt` (
  `receipt_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `store_id` BIGINT NOT NULL,
  `card_company_id` BIGINT NULL,
  `receipt_body` LONGTEXT NOT NULL,
  `amount` INT NOT NULL,
  `payment_method` ENUM('신용','체크','현금') NOT NULL,
  `transaction_status` ENUM('승인','취소') NOT NULL,
  `is_canceled` ENUM('Y','N') NULL,
  `created_at` TIMESTAMP NOT NULL,
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`receipt_id`),
  CONSTRAINT `FK_USER_RECEIPT` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  CONSTRAINT `FK_STORE_RECEIPT` FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`),
  CONSTRAINT `FK_CARD_COMPANY` FOREIGN KEY (`card_company_id`) REFERENCES `card_company`(`card_company_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--  2025-02-12 트랜잭션 관련 테이블 삭제
-- 9. transaction_status_code
-- CREATE TABLE `transaction_status_code` (
--   `transaction_status_code` INT NOT NULL,
--   `code_description` VARCHAR(255) NOT NULL,
--   PRIMARY KEY (`transaction_status_code`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- 
-- 10. point_product
CREATE TABLE `point_product` (
  `point_product_id` BIGINT NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(100) NOT NULL,
  `price` INT NOT NULL,
  `quantity` INT NOT NULL,
  `created_at` TIMESTAMP NOT NULL,
  `modified_at` TIMESTAMP NOT NULL,
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`point_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. review
CREATE TABLE `review` (
  `review_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `store_id` BIGINT NOT NULL,
  -- 2025-02-11 박양하: content VARCHAR(255) -> TEXT로 변경
  `content` TEXT NOT NULL,
  `rating` INT NOT NULL,
  -- 25-02-12 하채린 : DEFAULT(NOW()) 추가
  `created_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  -- 25-02-12 하채린 : DEFAULT(NOW()) 추가
  `modified_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`review_id`),
  -- 25-02-12 하채린: 회원 삭제될 때 같이 삭제되게 수정
  CONSTRAINT `FK_USER_REVIEW` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  -- 25-02-12 하채린: 매장 삭제될 때 같이 삭제되게 수정
  CONSTRAINT `FK_STORE_REVIEW` FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. comment
CREATE TABLE `comment` (
  `comment_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `review_id` BIGINT NOT NULL,
  `content` VARCHAR(255) NOT NULL,
  -- 25-02-12 하채린 : DEFAULT(NOW()) 추가
  `created_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  -- 25-02-12 하채린 : DEFAULT(NOW()) 추가
  `modified_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`comment_id`),
  -- 25-02-12 하채린: 회원 삭제될 때 같이 삭제되게 수정 
  CONSTRAINT `FK_USER_COMMENT` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE ,
  -- 25-02-12 하채린: 리뷰 삭제될 때 같이 삭제되게 수정 
  CONSTRAINT `FK_REVIEW_COMMENT` FOREIGN KEY (`review_id`) REFERENCES `review`(`review_id`) ON DELETE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. review_like
-- like는 예약어이므로 백틱(`)으로 감싸야 함.
CREATE TABLE `review_like` (
-- 25-02-12 하채린: like_id -> review_like_id 로 수정 
  `review_like_id` BIGINT NOT NULL AUTO_INCREMENT,
  `review_id` BIGINT NOT NULL,
  `user_id` VARCHAR(30) NOT NULL,
  -- 25-02-12 하채린 : DEFAULT(NOW()) 추가
  `created_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  PRIMARY KEY (`review_like_id`),
  -- 2025-02-11 박양하: UNIQUE 조건 추가(user_id당 하나의 review에 한 번의 좋아요 가능)
  UNIQUE (`review_id`, `user_id`),
  -- 25-02-12 리뷰 삭제 시 같이 삭제됨 
  CONSTRAINT `FK_REVIEW_LIKE` FOREIGN KEY (`review_id`) REFERENCES `review`(`review_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_USER_LIKE` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. review_image
CREATE TABLE `review_image` (
  `review_image_id` BIGINT NOT NULL AUTO_INCREMENT,
  `review_id` BIGINT NOT NULL,
-- 2025-02-11 박양하:  ERD와 Type 매칭 TEXT -> VARCHAR(255) DEFAULT 설정 임의 설정 후 Not null로 제약조건  변경)
  `review_image_url` VARCHAR(255) NOT NULL DEFAULT('https://billon.com/review_test_url/'),
  PRIMARY KEY (`review_image_id`),
  -- 25-02-12 하채린: 리뷰 삭제 시 같이 삭제됨
  CONSTRAINT `FK_REVIEW_IMAGE` FOREIGN KEY (`review_id`) REFERENCES `review`(`review_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. point
CREATE TABLE `point` (
  `point_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `reference_point_id` BIGINT NULL,
  `receipt_id` BIGINT NOT NULL,
  `transaction_type` VARCHAR(10) NULL,
  `point` INT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
  `is_canceled` ENUM('Y','N') NOT NULL,
  PRIMARY KEY (`point_id`),
  CONSTRAINT `FK_USER_POINT` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  CONSTRAINT `FK_RECEIPT_POINT` FOREIGN KEY (`receipt_id`) REFERENCES `receipt`(`receipt_id`),
  CONSTRAINT `FK_REFERENCE_POINT` FOREIGN KEY (`reference_point_id`) REFERENCES `point`(`point_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2025-02-12 박양하: 포인트 교환 내역 테이블 추가
-- 16. point_exchange_history
CREATE TABLE `point_exchange_history` (
	  `point_exchange_id` BIGINT NOT NULL AUTO_INCREMENT,
	  `user_id` VARCHAR(30) NOT NULL,
	  `point_product_id` BIGINT NOT NULL,
	  `quantity` INT NOT NULL,
	  `created_at` TIMESTAMP NOT NULL DEFAULT(NOW()),
	  PRIMARY KEY (`point_exchange_id`),
	  CONSTRAINT `FK_USER_EXCHANGE` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
	  CONSTRAINT `FK_POINT_PRODUCT` FOREIGN KEY (`point_product_id`) REFERENCES `point_product`(`point_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--  2025-02-12 트랜잭션 관련 테이블 삭제
-- 16. transaction_error_history
-- CREATE TABLE `transaction_error_history` (
--   `point_transaction_id` BIGINT NOT NULL AUTO_INCREMENT,
--   `transaction_status_code` INT NOT NULL,
--   `receipt_id` BIGINT NULL,
--   `point_product_id` BIGINT NULL,
--   `transaction_type` VARCHAR(10) NOT NULL,
--   `created_at` DATETIME NOT NULL,
--   PRIMARY KEY (`point_transaction_id`),
--   CONSTRAINT `FK_RECEIPT` FOREIGN KEY (`receipt_id`) REFERENCES `receipt`(`receipt_id`),
--   CONSTRAINT `FK_POINT_PRODUCT` FOREIGN KEY (`point_product_id`) REFERENCES `point_product`(`point_product_id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- 
-- 17. favorite
CREATE TABLE `favorite` (
  `favorite_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `store_id` BIGINT NOT NULL,
  `created_at` TIMESTAMP NOT NULL,
  `deleted_at` TIMESTAMP NULL,
  PRIMARY KEY (`favorite_id`),
  -- 2025-02-11 박양하: UNIQUE 조건 추가(user_id당 하나의 store에 한 번의 즐겨찾기 가능)
  UNIQUE (`user_id`, `store_id`),
  CONSTRAINT `FK_USER_FAVORITE` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  CONSTRAINT `FK_STORE_FAVORITE` FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 18. store_image
CREATE TABLE `store_image` (
  `store_image_id` BIGINT NOT NULL AUTO_INCREMENT,
  `store_id` BIGINT NOT NULL,
  -- 2025-02-11 박양하:  ERD와 Type 매칭 TEXT -> VARCHAR(255) DEFAULT 설정 임의 설정 후 Not null로 제약조건  변경)
  `store_image_url` VARCHAR(255) NOT NULL DEFAULT('https://billon.com/store_image_test_url/'),
  PRIMARY KEY (`store_image_id`),
  CONSTRAINT `FK_STORE_IMAGE` FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 19. login_history
CREATE TABLE `login_history` (
  `login_history_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `login_at` TIMESTAMP NOT NULL,
-- 2025-02-11 박양하: ip, device_type TEXT 타입에서 VARCHAR(50)으로 통일
  `ip_address` VARCHAR(50) NOT NULL,
  `device_type` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`login_history_id`),
  CONSTRAINT `FK_USER_LOGIN` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

-- 20. report
CREATE TABLE `report` (
  `report_id` BIGINT NOT NULL AUTO_INCREMENT,
  `report_type_id` BIGINT NOT NULL,
  `user_id` VARCHAR(30) NOT NULL,
  `comment_id` BIGINT NULL,
  `review_id` BIGINT NULL,
  `report_comment` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`report_id`),
  CONSTRAINT `FK_REPORT_TYPE` FOREIGN KEY (`report_type_id`) REFERENCES `report_type`(`report_type_id`),
  CONSTRAINT `FK_USER_REPORT` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  CONSTRAINT `FK_COMMENT_REPORT` FOREIGN KEY (`comment_id`) REFERENCES `comment`(`comment_id`),
  CONSTRAINT `FK_REVIEW_REPORT` FOREIGN KEY (`review_id`) REFERENCES `review`(`review_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 21. penalty_history
CREATE TABLE `penalty_history` (
  `penalty_history_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` VARCHAR(30) NOT NULL,
  `admin_id` VARCHAR(30) NOT NULL,
  `penalty_reason` VARCHAR(255) NOT NULL,
  `start_penalty_at` TIMESTAMP NOT NULL,
  `end_penalty_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`penalty_history_id`),
  CONSTRAINT `FK_USER` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  CONSTRAINT `FK_ADMIN` FOREIGN KEY (`admin_id`) REFERENCES `user`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;

-- 2025-02-11 박양하: notification_history Entity 누락되어 추가
-- 22. notification_history
CREATE TABLE `notification_history` (
  `notification_history_id` BIGINT NOT NULL AUTO_INCREMENT,
  `notification_type_id` BIGINT NOT NULL,
  `user_id` VARCHAR(30) NOT NULL,
  `read_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`notification_history_id`),
  CONSTRAINT `FK_NOTIFICATION_TYPE`
    FOREIGN KEY (`notification_type_id`) REFERENCES `notification_type`(`notification_type_id`),
  CONSTRAINT `FK_USER_NOTIFICATION_HISTORY`
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 외래 키 체크 다시 활성화
SET FOREIGN_KEY_CHECKS = 1;
