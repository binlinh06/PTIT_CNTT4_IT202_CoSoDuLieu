-- 1
CREATE DATABASE IF NOT EXISTS social_network;
USE social_network;

-- Bảng users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    posts_count INT DEFAULT 0
);

-- Bảng posts
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users (username) VALUES ('alice'), ('bob');

START TRANSACTION;

-- Thêm bài viết mới
INSERT INTO posts (user_id, content)
VALUES (1, 'Bài viết đầu tiên của Alice');

-- Cập nhật số lượng bài viết
UPDATE users
SET posts_count = posts_count + 1
WHERE user_id = 1;

COMMIT;
START TRANSACTION;

-- Lỗi: user_id = 999 không tồn tại
INSERT INTO posts (user_id, content)
VALUES (999, 'Bài viết lỗi');

-- Câu lệnh này sẽ không có tác dụng vì INSERT đã lỗi
UPDATE users
SET posts_count = posts_count + 1
WHERE user_id = 999;

ROLLBACK;
SELECT * FROM posts;
SELECT * FROM users;
