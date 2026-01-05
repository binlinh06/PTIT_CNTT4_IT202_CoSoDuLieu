DROP DATABASE IF EXISTS ks24_cntt04_ss06_06;
CREATE DATABASE ks24_cntt04_ss06_06;
USE ks24_cntt04_ss06_06;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products (product_name, price) VALUES
('Laptop Dell', 20000000),
('iPhone 15', 25000000),
('Tai nghe Sony', 3000000),
('Chuột Logitech', 800000),
('Bàn phím cơ', 1500000),
('Màn hình LG', 7000000),
('Loa JBL', 4000000);

INSERT INTO order_items (product_id, quantity, unit_price) VALUES
(1, 3, 20000000),
(1, 4, 19500000),
(1, 5, 19800000),
(2, 5, 25000000),
(2, 6, 24800000),
(3, 10, 3000000),
(3, 5, 2900000),
(4, 20, 800000),
(5, 8, 1500000),
(5, 5, 1450000),
(6, 6, 7000000),
(6, 5, 6900000),
(7, 12, 4000000);

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    AVG(oi.unit_price) AS avg_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >= 10
ORDER BY total_revenue DESC
LIMIT 5;
