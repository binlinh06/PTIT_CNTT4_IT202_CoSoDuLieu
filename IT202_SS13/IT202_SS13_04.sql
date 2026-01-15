USE social_trigger_db;

-- 1. TẠO BẢNG post_history
CREATE TABLE post_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME,
    changed_by_user_id INT,
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
        ON DELETE CASCADE
);
-- 2. XÓA TRIGGER CŨ NẾU TỒN TẠI
DROP TRIGGER IF EXISTS trg_before_update_post;
DROP TRIGGER IF EXISTS trg_after_delete_post_history;
-- 3. TRIGGER BEFORE UPDATE ON posts Lưu lịch sử khi content thay đổi
DELIMITER //

CREATE TRIGGER trg_before_update_post
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    -- Chỉ ghi lịch sử khi nội dung thay đổi
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_history (
            post_id,
            old_content,
            new_content,
            changed_at,
            changed_by_user_id
        )
        VALUES (
            OLD.post_id,
            OLD.content,
            NEW.content,
            NOW(),
            OLD.user_id   -- giả sử người sửa là chủ bài
        );
    END IF;
END //
DELIMITER ;
-- 4. TRIGGER AFTER DELETE ON posts(CASCADE đã tự xóa history & likes)
DELIMITER //

CREATE TRIGGER trg_after_delete_post_history
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    -- Có thể ghi log nếu muốn (ở đây để trống)
    -- CASCADE sẽ tự xóa post_history & likes
END //
DELIMITER ;
-- 5. KIỂM THỬ UPDATE BÀI ĐĂNG

-- Cập nhật nội dung bài viết
UPDATE posts
SET content = 'Alice updated her first post!'
WHERE post_id = 1;

UPDATE posts
SET content = 'Bob updated his first post!'
WHERE post_id = 3;
-- 6. KIỂM TRA LỊCH SỬ CHỈNH SỬA
SELECT * FROM post_history;
 -- 7. KIỂM TRA LIKE_COUNT KHÔNG BỊ ẢNH HƯỞNG
SELECT post_id, content, like_count
FROM posts;
-- 8. KIỂM TRA VIEW user_statistics 
SELECT * FROM user_statistics;
