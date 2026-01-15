-- Dùng database
USE social_network;

-- Bảng log xóa bài viết
CREATE TABLE IF NOT EXISTS delete_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    deleted_by INT,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

-- Procedure xóa bài viết + dữ liệu liên quan
CREATE PROCEDURE sp_delete_post(
    IN p_post_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE v_owner_id INT;
    DECLARE v_count INT;

    proc_block: BEGIN
        START TRANSACTION;

        -- Check bài viết tồn tại và lấy chủ bài viết
        SELECT user_id INTO v_owner_id
        FROM posts
        WHERE post_id = p_post_id;

        IF v_owner_id IS NULL THEN
            ROLLBACK;
            LEAVE proc_block;
        END IF;

        -- Check đúng chủ bài viết
        IF v_owner_id <> p_user_id THEN
            ROLLBACK;
            LEAVE proc_block;
        END IF;

        -- Xóa likes của bài viết
        DELETE FROM likes WHERE post_id = p_post_id;

        -- Xóa comments của bài viết
        DELETE FROM comments WHERE post_id = p_post_id;

        -- Xóa bài viết
        DELETE FROM posts WHERE post_id = p_post_id;

        -- Giảm posts_count của chủ bài viết
        UPDATE users
        SET posts_count = posts_count - 1
        WHERE user_id = p_user_id;

        -- Ghi log xóa thành công
        INSERT INTO delete_log(post_id, deleted_by)
        VALUES (p_post_id, p_user_id);

        COMMIT;
    END proc_block;

END$$

DELIMITER ;
-- Trường hợp hợp lệ (chủ bài viết)
CALL sp_delete_post(1, 1);

-- Trường hợp KHÔNG hợp lệ (không phải chủ bài viết)
CALL sp_delete_post(2, 1);

-- Kiểm tra kết quả
SELECT * FROM posts;
SELECT * FROM likes;
SELECT * FROM comments;
SELECT user_id, posts_count FROM users;
SELECT * FROM delete_log;
