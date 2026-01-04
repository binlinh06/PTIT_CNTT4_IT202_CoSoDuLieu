DROP DATABASE IF EXISTS Ks24_CNTT04_SS05_01;
CREATE DATABASE shop_db;
USE shop_db;

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL CHECK (stock >= 0),
    status ENUM('active', 'inactive') NOT NULL
);
INSERT INTO Product (product_name, price, stock, status) VALUES
('iPhone 15', 25000000, 10, 'active'),
('Samsung Galaxy S23', 21000000, 15, 'active'),
('Tai nghe Bluetooth', 850000, 50, 'active'),
('Laptop Dell XPS', 32000000, 5, 'inactive'),
('Chuột không dây', 350000, 100, 'active'),
('Bàn phím cơ', 1200000, 30, 'inactive');
SELECT * 
FROM Product;
SELECT * 
FROM Product
WHERE status = 'active';
SELECT * 
FROM Product
WHERE price > 1000000;
SELECT * 
FROM Product
WHERE status = 'active'
ORDER BY price ASC;
