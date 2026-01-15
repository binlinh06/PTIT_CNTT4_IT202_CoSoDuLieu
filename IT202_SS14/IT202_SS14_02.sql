CREATE DATABASE IF NOT EXISTS social_network;
USE social_network;

ALTER TABLE posts
ADD COLUMN likes_count INT DEFAULT 0;
CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY unique_like (post_id, user_id)
);
START TRANSACTION;

-- User 2 like bài viết 1
INSERT INTO likes (post_id, user_id)
VALUES (1, 2);

-- Tăng số lượt like của bài viết
UPDATE posts
SET likes_count = likes_count + 1
WHERE post_id = 1;

COMMIT;
START TRANSACTION;

-- Lỗi: user 2 đã like post 1 trước đó
INSERT INTO likes (post_id, user_id)
VALUES (1, 2);

-- Không được thực thi do INSERT lỗi
UPDATE posts
SET likes_count = likes_count + 1
WHERE post_id = 1;

ROLLBACK;
SELECT * FROM likes;
SELECT post_id, likes_count FROM posts;
