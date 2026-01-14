USE social_trigger_db;

/* =================================================
   1. TẠO BẢNG friendships
================================================= */
CREATE TABLE friendships (
    follower_id INT,
    followee_id INT,
    status ENUM('pending', 'accepted') DEFAULT 'accepted',
    PRIMARY KEY (follower_id, followee_id),
    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (followee_id) REFERENCES users(user_id) ON DELETE CASCADE
);

/* =================================================
   2. TRIGGER CẬP NHẬT follower_count
================================================= */

-- Sau khi FOLLOW (accepted)
DROP TRIGGER IF EXISTS trg_after_insert_friendship;
DELIMITER //

CREATE TRIGGER trg_after_insert_friendship
AFTER INSERT ON friendships
FOR EACH ROW
BEGIN
    IF NEW.status = 'accepted' THEN
        UPDATE users
        SET follower_count = follower_count + 1
        WHERE user_id = NEW.followee_id;
    END IF;
END //
DELIMITER ;

-- Sau khi UNFOLLOW
DROP TRIGGER IF EXISTS trg_after_delete_friendship;
DELIMITER //

CREATE TRIGGER trg_after_delete_friendship
AFTER DELETE ON friendships
FOR EACH ROW
BEGIN
    IF OLD.status = 'accepted' THEN
        UPDATE users
        SET follower_count = follower_count - 1
        WHERE user_id = OLD.followee_id;
    END IF;
END //
DELIMITER ;

/* =================================================
   3. PROCEDURE follow_user
================================================= */
DROP PROCEDURE IF EXISTS follow_user;
DELIMITER //

CREATE PROCEDURE follow_user(
    IN p_follower_id INT,
    IN p_followee_id INT,
    IN p_status ENUM('pending','accepted')
)
BEGIN
    -- Không cho tự follow
    IF p_follower_id = p_followee_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không được tự follow chính mình';
    END IF;

    -- Tránh follow trùng
    IF EXISTS (
        SELECT 1 FROM friendships
        WHERE follower_id = p_follower_id
          AND followee_id = p_followee_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Đã tồn tại quan hệ follow';
    END IF;

    -- Thêm follow
    INSERT INTO friendships (follower_id, followee_id, status)
    VALUES (p_follower_id, p_followee_id, p_status);
END //
DELIMITER ;

/* =================================================
   4. VIEW user_profile (CHI TIẾT)
================================================= */
CREATE OR REPLACE VIEW user_profile AS
SELECT
    u.user_id,
    u.username,
    u.follower_count,
    u.post_count,
    IFNULL(us.total_likes, 0) AS total_likes,
    GROUP_CONCAT(p.content ORDER BY p.created_at DESC SEPARATOR ' | ') AS recent_posts
FROM users u
LEFT JOIN user_statistics us ON u.user_id = us.user_id
LEFT JOIN posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username, u.follower_count, u.post_count, us.total_likes;

/* =================================================
   5. KIỂM THỬ FOLLOW / UNFOLLOW
================================================= */

--  FOLLOW hợp lệ
CALL follow_user(2, 1, 'accepted'); -- Bob follow Alice
CALL follow_user(3, 1, 'accepted'); -- Charlie follow Alice

--  Tự follow (phải lỗi)
CALL follow_user(1, 1, 'accepted');

--  Follow trùng (phải lỗi)
CALL follow_user(2, 1, 'accepted');

-- Kiểm tra follower_count
SELECT user_id, username, follower_count FROM users;

-- Kiểm tra view profile
SELECT * FROM user_profile;

-- UNFOLLOW
DELETE FROM friendships
WHERE follower_id = 2 AND followee_id = 1;

-- Kiểm tra lại
SELECT user_id, username, follower_count FROM users;
SELECT * FROM user_profile;
