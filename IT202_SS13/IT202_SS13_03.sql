USE social_trigger_db;

/* =================================================
   1. ĐẢM BẢO KHÔNG CÓ TRIGGER CŨ GÂY XUNG ĐỘT
================================================= */
DROP TRIGGER IF EXISTS trg_before_insert_like;
DROP TRIGGER IF EXISTS trg_after_insert_like;
DROP TRIGGER IF EXISTS trg_after_delete_like;
DROP TRIGGER IF EXISTS trg_after_update_like;

/* =================================================
   2. TRIGGER BEFORE INSERT
   Không cho phép user like bài của chính mình
================================================= */
DELIMITER //

CREATE TRIGGER trg_before_insert_like
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE post_owner INT;

    SELECT user_id
    INTO post_owner
    FROM posts
    WHERE post_id = NEW.post_id;

    IF NEW.user_id = post_owner THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không được phép like bài viết của chính mình';
    END IF;
END //
DELIMITER ;

/* =================================================
   3. TRIGGER AFTER INSERT
   Tăng like_count
================================================= */
DELIMITER //

CREATE TRIGGER trg_after_insert_like
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END //
DELIMITER ;

/* =================================================
   4. TRIGGER AFTER DELETE
   Giảm like_count
================================================= */
DELIMITER //

CREATE TRIGGER trg_after_delete_like
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
END //
DELIMITER ;

/* =================================================
   5. TRIGGER AFTER UPDATE
   Điều chỉnh like_count khi đổi post_id
================================================= */
DELIMITER //

CREATE TRIGGER trg_after_update_like
AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
    -- Nếu đổi sang bài khác
    IF OLD.post_id <> NEW.post_id THEN
        UPDATE posts
        SET like_count = like_count - 1
        WHERE post_id = OLD.post_id;

        UPDATE posts
        SET like_count = like_count + 1
        WHERE post_id = NEW.post_id;
    END IF;
END //
DELIMITER ;

/* =================================================
   6. KIỂM THỬ
================================================= */

--  Test like bài của chính mình (phải lỗi)
-- Alice (user_id = 1) like post_id = 1 (của Alice)
INSERT INTO likes (user_id, post_id)
VALUES (1, 1);

-- Like hợp lệ
INSERT INTO likes (user_id, post_id)
VALUES (2, 4);

-- Kiểm tra like_count
SELECT * FROM posts WHERE post_id = 4;

-- UPDATE like sang post khác
-- Ví dụ đổi like_id = 2 sang post_id = 3
UPDATE likes
SET post_id = 3
WHERE like_id = 2;

-- Kiểm tra cả 2 post
SELECT * FROM posts WHERE post_id IN (3,4);

-- XÓA LIKE
DELETE FROM likes WHERE like_id = 2;

/* =================================================
   7. KIỂM CHỨNG VIEW
================================================= */
SELECT * FROM posts;
SELECT * FROM user_statistics;
