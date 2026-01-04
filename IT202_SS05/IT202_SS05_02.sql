DROP DATABASE IF EXISTS Ks24_CNTT04_SS05_02;
CREATE DATABASE Ks24_CNTT04_SS05_02;
USE Ks24_CNTT04_SS05_02;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    city VARCHAR(255),
    status ENUM('active', 'inactive') NOT NULL
);
INSERT INTO customers (full_name, email, city, status) VALUES
('Nguyễn Văn An', 'an.nguyen@gmail.com', 'TP.HCM', 'active'),
('Trần Thị Bình', 'binh.tran@gmail.com', 'Hà Nội', 'active'),
('Lê Minh Châu', 'chau.le@gmail.com', 'Đà Nẵng', 'inactive'),
('Phạm Văn Dũng', 'dung.pham@gmail.com', 'Hà Nội', 'inactive'),
('Hoàng Thị Lan', 'lan.hoang@gmail.com', 'TP.HCM', 'active');
SELECT * 
FROM customers;
SELECT * 
FROM customers
WHERE city = 'TP.HCM';
SELECT * 
FROM customers
WHERE status = 'active'
  AND city = 'Hà Nội';
SELECT * 
FROM customers
ORDER BY full_name ASC;
