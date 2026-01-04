DROP DATABASE IF EXISTS Ks24_CNTT04_SS05_04;
CREATE DATABASE Ks24_CNTT04_SS05_04;
USE Ks24_CNTT04_SS05_04;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    sold_quantity INT NOT NULL CHECK (sold_quantity >= 0),
    status ENUM('active', 'inactive') NOT NULL
);
INSERT INTO products (product_name, price, sold_quantity, status) VALUES
('iPhone 15', 25000000, 120, 'active'),
('Samsung Galaxy S23', 21000000, 95, 'active'),
('Tai nghe Bluetooth', 850000, 300, 'active'),
('Laptop Dell', 32000000, 40, 'active'),
('Chuột không dây', 350000, 500, 'active'),
('Bàn phím cơ', 1200000, 220, 'active'),
('Loa Bluetooth', 1800000, 260, 'active'),
('Ổ cứng SSD', 1500000, 180, 'active'),
('Webcam', 900000, 160, 'inactive'),
('Màn hình 24 inch', 4200000, 110, 'active'),
('Sạc dự phòng', 700000, 280, 'active'),
('USB 64GB', 250000, 350, 'active'),
('Router Wifi', 1300000, 140, 'active'),
('Tai nghe gaming', 1900000, 200, 'active'),
('Chuột gaming', 890000, 210, 'active');
SELECT * 
FROM products
ORDER BY sold_quantity DESC
LIMIT 10;
SELECT * 
FROM products
ORDER BY sold_quantity DESC
LIMIT 5 OFFSET 10;
SELECT * 
FROM products
WHERE price < 2000000
ORDER BY sold_quantity DESC;
