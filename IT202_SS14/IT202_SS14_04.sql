-- Tạo database
CREATE DATABASE IF NOT EXISTS social_network;
USE social_network;

-- Bảng users
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL
);

-- Bảng posts (có comments_count)
CREATE TABLE IF NOT EXISTS posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    comments_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Bảng comments
CREATE TABLE IF NOT EXISTS comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Procedure đăng bình luận có SAVEPOINT
DELIMITER $$

CREATE PROCEDURE sp_post_comment(
    IN p_post_id INT,
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    proc_block: BEGIN
        START TRANSACTION;

        -- Check post tồn tại
        SELECT COUNT(*) INTO v_count FROM posts WHERE post_id = p_post_id;
        IF v_count = 0 THEN
            ROLLBACK;
            LEAVE proc_block;
        END IF;

        -- Check user tồn tại
        SELECT COUNT(*) INTO v_count FROM users WHERE user_id = p_user_id;
        IF v_count = 0 THEN
            ROLLBACK;
            LEAVE proc_block;
        END IF;

        -- Insert comment
        INSERT INTO comments(post_id, user_id, content)
        VALUES (p_post_id, p_user_id, p_content);

        -- Savepoint sau insert
        SAVEPOINT after_insert;

        -- Giả lập lỗi để test savepoint
        IF p_content = 'ERROR_TEST' THEN
            ROLLBACK TO after_insert; -- rollback phần update
            COMMIT;                  -- giữ comment
            LEAVE proc_block;
        END IF;

        -- Update comments_count
        UPDATE posts
        SET comments_count = comments_count + 1
        WHERE post_id = p_post_id;

        COMMIT;
    END proc_block;

END$$

DELIMITER ;

-- Dữ liệu mẫu
INSERT INTO users(username) VALUES ('Alice'), ('Bob');
INSERT INTO posts(user_id, content) VALUES (1, 'Bài viết số 1');

-- Test thành công
CALL sp_post_comment(1, 2, 'Bình luận hợp lệ');

-- Test rollback một phần
CALL sp_post_comment(1, 2, 'ERROR_TEST');

-- Kiểm tra kết quả
SELECT * FROM comments;
SELECT post_id, comments_count FROM posts;
