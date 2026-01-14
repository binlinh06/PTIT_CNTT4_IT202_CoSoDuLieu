DROP DATABASE IF EXISTS social_trigger_db;
CREATE DATABASE social_trigger_db;
USE social_trigger_db;
-- 1
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATE,
    follower_count INT DEFAULT 0,
    post_count INT DEFAULT 0
);
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content TEXT,
    created_at DATETIME,
    like_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);
CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    post_id INT,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);
-- 2
INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');
INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');	
INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');
-- 3
DROP TRIGGER IF EXISTS trg_after_insert_like;
delimiter //
create trigger trg_after_insert_like
after insert on likes
for each row
begin
	UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
end //
delimiter ;

DROP TRIGGER IF EXISTS trg_after_delete_like;
delimiter //
create trigger trg_after_delete_like
after delete on likes
for each row
begin
	UPDATE posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
end //
delimiter ;

-- 4
create or replace view user_statistics 
as
select  u.user_id, u.username, u.post_count, IFNULL(SUM(p.like_count), 0) AS total_likes
from  users u
LEFT JOIN posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username, u.post_count;

-- 5
INSERT INTO likes (user_id, post_id, liked_at)
VALUES (2, 4, NOW());

-- Kiểm tra like_count của post
SELECT * FROM posts WHERE post_id = 4;

-- Kiểm tra view
SELECT * FROM user_statistics;

-- 6
DELETE FROM likes
WHERE like_id = 1;

-- Kiểm tra lại view
SELECT * FROM user_statistics;