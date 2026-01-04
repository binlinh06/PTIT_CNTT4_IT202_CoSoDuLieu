DROP DATABASE IF EXISTS Ks24_CNTT04_SS05_06;
CREATE DATABASE Ks24_CNTT04_SS05_06;
USE Ks24_CNTT04_SS05_06;
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL CHECK (stock >= 0),
    status ENUM('active', 'inactive') NOT NULL
);
INSERT INTO products (product_name, price, stock, status) VALUES
('Laptop Dell', 2500000, 10, 'active'),
('Laptop HP', 3200000, 8, 'active'),
('Chuột Logitech', 900000, 50, 'active'),
('Bàn phím cơ', 1500000, 30, 'active'),
('Tai nghe Sony', 2000000, 20, 'active'),
('Ổ cứng SSD', 2800000, 15, 'active'),
('Màn hình LG', 3500000, 12, 'inactive'),
('Webcam', 1200000, 25, 'active'),
('USB 64GB', 700000, 100, 'active'),
('Loa Bluetooth', 1800000, 18, 'active'),
('Router Wifi', 2300000, 14, 'active'),
('Micro thu âm', 2700000, 9, 'active'),
('Balo Laptop', 1100000, 40, 'active'),
('Đế tản nhiệt', 1000000, 35, 'active'),
('Cáp sạc nhanh', 300000, 200, 'inactive');
SELECT *
FROM products
WHERE status = 'active'
  AND price BETWEEN 1000000 AND 3000000
ORDER BY price ASC
LIMIT 10 OFFSET 0;
SELECT *
FROM products
WHERE status = 'active'
  AND price BETWEEN 1000000 AND 3000000
ORDER BY price ASC
LIMIT 10 OFFSET 0;
