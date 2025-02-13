-- 평균 별점 순으로 매장 조회 구현
-- store_image 테이블에 입력된 url들을
-- , 로 묶어 한번에 출력 하게 구현


SELECT  s.store_name   AS 매장명
   	, s.contact_number AS 매장번호
      , s.address        AS 주소
      , s.address_detail AS 상세주소
      , s.business_hours AS 운영시간
      , s.average_rating AS 평점
      , GROUP_CONCAT(si.store_image_url SEPARATOR ', ') AS 매장사진
FROM store s
JOIN category c ON s.category_id = c.category_id
LEFT JOIN store_image si ON s.store_id = si.store_id
WHERE category_name LIKE '%%'
GROUP BY s.store_id, s.store_name, s.contact_number, s.address, s.address_detail, s.business_hours, s.average_rating
ORDER BY s.average_rating DESC;


INSERT INTO store_image (store_id, store_image_url)
VALUE ('3', 'http://example.com/store/store3_img2.jpg');