USE social_trigger_db;

/* =========================================
   1. STORED PROCEDURE add_user
========================================= */
DROP PROCEDURE IF EXISTS add_user;
DELIMITER //

CREATE PROCEDURE add_user(
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_created_at DATE
)
BEGIN
    INSERT INTO users (username, email, created_at)
    VALUES (p_username, p_email, p_created_at);
END //
DELIMITER ;

/* =========================================
   2. TRIGGER BEFORE INSERT ON users
   Kiểm tra toàn vẹn dữ liệu
========================================= */
DROP TRIGGER IF EXISTS trg_before_insert_user;
DELIMITER //

CREATE TRIGGER trg_before_insert_user
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    -- Kiểm tra email có chứa '@' và '.'
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email không hợp lệ';
    END IF;

    -- Kiểm tra username chỉ gồm chữ, số, underscore
    IF NEW.username NOT REGEXP '^[A-Za-z0-9_]+$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username chỉ được chứa chữ cái, số và dấu gạch dưới';
    END IF;
END //
DELIMITER ;

/* =========================================
   3. KIỂM THỬ PROCEDURE + TRIGGER
========================================= */

--  HỢP LỆ
CALL add_user('valid_user_01', 'valid01@example.com', '2025-01-20');

--  Email sai định dạng
CALL add_user('invaliduser', 'invalidemail', '2025-01-20');

--  Username chứa ký tự đặc biệt
CALL add_user('invalid-user!', 'user2@example.com', '2025-01-20');

/* =========================================
   4. KIỂM TRA KẾT QUẢ
========================================= */
SELECT * FROM users;
