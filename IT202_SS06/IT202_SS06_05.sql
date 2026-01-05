DROP DATABASE IF EXISTS ks24_cntt04_ss06_05;
CREATE DATABASE ks24_cntt04_ss06_05;
USE ks24_cntt04_ss06_05;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    city VARCHAR(255)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers (full_name, city) VALUES
('Nguyễn Văn An', 'Hà Nội'),
('Trần Thị Bình', 'TP.HCM'),
('Lê Minh Châu', 'Đà Nẵng'),
('Phạm Quốc Dũng', 'Hà Nội'),
('Hoàng Thị Lan', 'Cần Thơ');

INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
(1, '2024-09-01', 'completed', 3500000),
(1, '2024-09-05', 'completed', 4200000),
(1, '2024-09-10', 'completed', 2800000),
(2, '2024-09-02', 'completed', 3200000),
(2, '2024-09-08', 'completed', 4500000),
(3, '2024-09-03', 'completed', 1500000),
(3, '2024-09-06', 'completed', 1800000),
(3, '2024-09-09', 'completed', 2200000),
(4, '2024-09-04', 'completed', 6000000),
(4, '2024-09-07', 'completed', 5200000),
(5, '2024-09-05', 'cancelled', 4000000);

SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) >= 3
   AND SUM(o.total_amount) > 10000000
ORDER BY total_spent DESC;
