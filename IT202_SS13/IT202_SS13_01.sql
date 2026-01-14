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

-- 2
INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');

-- 3
DROP TRIGGER IF EXISTS trg_after_insert_post;
delimiter //
create trigger trg_after_insert_post
after insert on posts
for each row
begin
 UPDATE users
    SET post_count = post_count + 1
    WHERE user_id = NEW.user_id;
end //
delimiter ;	

DROP TRIGGER IF EXISTS trg_after_delete_post;
delimiter //
create trigger trg_after_delete_post
after delete on posts
for each row
begin
 UPDATE users
    SET post_count = post_count - 1
    WHERE user_id = OLD.user_id;
end //
delimiter ;	

-- 4
INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

SELECT * FROM users;

-- 5
DELETE FROM posts WHERE post_id = 2;
