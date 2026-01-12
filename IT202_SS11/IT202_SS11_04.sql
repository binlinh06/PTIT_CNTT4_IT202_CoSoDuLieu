-- 1
use social_network_pro;
DROP PROCEDURE IF EXISTS CreatePostWithValidation;

delimiter //
create procedure CreatePostWithValidation(
	 IN p_user_id int,
     IN p_content text,
     OUT result_message VARCHAR(255)
)
begin
	if CHAR_LENGTH(p_content) < 5 then 
		SET result_message = 'Nội dung quá ngắn';
    ELSE
        INSERT INTO posts(user_id, content)
        VALUES (p_user_id, p_content);

        SET result_message = 'Thêm bài viết thành công';
    END IF;
end //
delimiter ;

SET @result = '';
CALL CreatePostWithValidation(1, 'Hi', @result);
SELECT @result AS result_message;

SET @result = '';
CALL CreatePostWithValidation(1, 'Hôm nay trời đẹp', @result);
SELECT @result AS result_message;

SELECT * FROM posts
WHERE user_id = 1
ORDER BY post_id DESC;

