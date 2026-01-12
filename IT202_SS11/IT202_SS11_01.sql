USE social_network_pro;
DROP PROCEDURE IF EXISTS p_user_id;
DELIMITER $$
CREATE PROCEDURE p_user_id(IN p_user_id INT)
BEGIN
    SELECT post_id, content, created_at
    FROM posts
    WHERE user_id = p_user_id;
END$$

DELIMITER ;
CALL p_user_id(1);
