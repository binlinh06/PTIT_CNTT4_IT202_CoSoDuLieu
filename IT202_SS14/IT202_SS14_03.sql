-- Dùng database
USE social_network;

-- Thêm friends_count vào users
ALTER TABLE users
ADD COLUMN friends_count INT DEFAULT 0;

-- Bảng friend_requests
CREATE TABLE IF NOT EXISTS friend_requests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    from_user_id INT,
    to_user_id INT,
    status ENUM('pending','accepted','rejected') DEFAULT 'pending'
);

-- Bảng friends (quan hệ 2 chiều)
CREATE TABLE IF NOT EXISTS friends (
    user_id INT,
    friend_id INT,
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (friend_id) REFERENCES users(user_id)
);

DELIMITER $$

-- Procedure chấp nhận lời mời kết bạn
CREATE PROCEDURE sp_accept_friend_request(
    IN p_request_id INT,
    IN p_to_user_id INT
)
BEGIN
    DECLARE v_from_user_id INT;
    DECLARE v_status VARCHAR(10);

    proc_block: BEGIN
        -- Isolation level để tránh dirty / non-repeatable read
        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
        START TRANSACTION;

        -- Lấy thông tin request
        SELECT from_user_id, status
        INTO v_from_user_id, v_status
        FROM friend_requests
        WHERE request_id = p_request_id
          AND to_user_id = p_to_user_id
        FOR UPDATE;

        -- Check request hợp lệ
        IF v_from_user_id IS NULL OR v_status <> 'pending' THEN
            ROLLBACK;
            LEAVE proc_block;
        END IF;

        -- Check đã là bạn chưa
        IF EXISTS (
            SELECT 1 FROM friends
            WHERE user_id = p_to_user_id
              AND friend_id = v_from_user_id
        ) THEN
            ROLLBACK;
            LEAVE proc_block;
        END IF;

        -- Insert quan hệ bạn bè 2 chiều
        INSERT INTO friends(user_id, friend_id)
        VALUES (p_to_user_id, v_from_user_id),
               (v_from_user_id, p_to_user_id);

        -- Tăng friends_count cho cả hai
        UPDATE users
        SET friends_count = friends_count + 1
        WHERE user_id IN (p_to_user_id, v_from_user_id);

        -- Cập nhật trạng thái request
        UPDATE friend_requests
        SET status = 'accepted'
        WHERE request_id = p_request_id;

        COMMIT;
    END proc_block;

END$$

DELIMITER ;

-- ================= TEST =================

-- Dữ liệu mẫu
INSERT INTO users(username) VALUES ('Alice'), ('Bob'), ('Charlie');

INSERT INTO friend_requests(from_user_id, to_user_id)
VALUES (1, 2);  -- Alice gửi lời mời cho Bob

-- Trường hợp hợp lệ
CALL sp_accept_friend_request(1, 2);

-- Trường hợp lỗi (đã là bạn / request không pending)
CALL sp_accept_friend_request(1, 2);

-- Kiểm tra kết quả
SELECT * FROM friend_requests;
SELECT * FROM friends;
SELECT user_id, friends_count FROM users;
