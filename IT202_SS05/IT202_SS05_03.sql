DROP DATABASE IF EXISTS Ks24_CNTT04_SS05_03;
CREATE DATABASE Ks24_CNTT04_SS05_03;
USE Ks24_CNTT04_SS05_03;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    order_date DATE NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') NOT NULL
);
INSERT INTO orders (customer_id, total_amount, order_date, status) VALUES
(1, 3000000, '2024-09-01', 'pending'),
(2, 6500000, '2024-09-03', 'completed'),
(3, 12000000, '2024-09-05', 'completed'),
(1, 4500000, '2024-09-07', 'cancelled'),
(4, 8000000, '2024-09-08', 'completed'),
(2, 2000000, '2024-09-09', 'pending'),
(5, 15000000, '2024-09-10', 'completed');
SELECT * 
FROM orders
WHERE status = 'completed';
SELECT * 
FROM orders
WHERE total_amount > 5000000;
SELECT * 
FROM orders
ORDER BY order_date DESC
LIMIT 5;
SELECT * 
FROM orders
WHERE status = 'completed'
ORDER BY total_amount DESC;
