-- 신고 내역 조회 : 관리자는 신고된 내역을 조회할 수 있다.
SELECT * FROM report;
DROP PROCEDURE if EXISTS admin_report_select;
DELIMITER //

CREATE PROCEDURE admin_report_select(
	IN p_admin_id VARCHAR(30),
	IN p_admin_password VARCHAR(255)
)
BEGIN 
	if (SELECT authority_id FROM user WHERE user_id = p_admin_id) =3 then
		SELECT  user_id
      		, comment_id
      		, review_id
      		, report_comment
      		, created_at
   	FROM report;
   else
   	SELECT "권한이 없습니다." AS "메세지";
	END if;
END//
DELIMITER ;

-- ----- 테스트코드  -------
-- 1. 아이디 입력 성공시 신고 내역 출력
CALL admin_report_select('user03','pw03');

-- 2. 아이디 입력 실패시 메세지 출력
CALL admin_report_select('user01','pw01');
   
SELECT * 
  FROM authority;

SELECT * 
  FROM user;

DESCRIBE user;