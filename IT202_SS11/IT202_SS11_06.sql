-- 1
USE social_network_pro;

DROP PROCEDURE IF EXISTS NotifyFriendsOnNewPost;
DELIMITER //

CREATE PROCEDURE NotifyFriendsOnNewPost(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_friend_id INT;
    DECLARE v_full_name VARCHAR(100);
    DECLARE v_message TEXT;

    -- Cursor lấy danh sách bạn bè accepted (2 chiều)
    DECLARE friend_cursor CURSOR FOR
        SELECT friend_id FROM friends 
        WHERE user_id = p_user_id AND status = 'accepted'
        UNION
        SELECT user_id FROM friends
        WHERE friend_id = p_user_id AND status = 'accepted';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Lấy tên người đăng
    SELECT full_name
    INTO v_full_name
    FROM users
    WHERE user_id = p_user_id;

    -- Thêm bài viết mới
    INSERT INTO posts(user_id, content)
    VALUES (p_user_id, p_content);

    -- Nội dung thông báo
    SET v_message = CONCAT(v_full_name, ' đã đăng một bài viết mới');

    -- Duyệt bạn bè và gửi thông báo
    OPEN friend_cursor;

    read_loop: LOOP
        FETCH friend_cursor INTO v_friend_id;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        IF v_friend_id <> p_user_id THEN
            INSERT INTO notifications(user_id, type, content)
            VALUES (v_friend_id, 'new_post', v_message);
        END IF;
    END LOOP;

    CLOSE friend_cursor;
END //

DELIMITER ;
CALL NotifyFriendsOnNewPost(1, 'Hôm nay tôi vừa hoàn thành bài tập SQL nâng cao!');
SELECT n.notification_id,
       u.full_name AS receiver_name,
       n.type,
       n.content,
       n.created_at
FROM notifications n
JOIN users u ON n.user_id = u.user_id
ORDER BY n.notification_id DESC;
