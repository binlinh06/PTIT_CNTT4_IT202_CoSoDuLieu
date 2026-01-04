DROP DATABASE IF EXISTS Ks24_CNTT04_SS05_05;
CREATE DATABASE Ks24_CNTT04_SS05_05;
USE Ks24_CNTT04_SS05_05;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    order_date DATE NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') NOT NULL
);

INSERT INTO orders (customer_id, total_amount, order_date, status) VALUES
(1, 3000000, '2024-09-01', 'completed'),
(2, 4500000, '2024-09-02', 'pending'),
(3, 1200000, '2024-09-03', 'completed'),
(4, 8000000, '2024-09-04', 'completed'),
(5, 2500000, '2024-09-05', 'cancelled'),
(1, 6000000, '2024-09-06', 'completed'),
(2, 1500000, '2024-09-07', 'pending'),
(3, 9500000, '2024-09-08', 'completed'),
(4, 2200000, '2024-09-09', 'completed'),
(5, 1800000, '2024-09-10', 'pending'),
(1, 7200000, '2024-09-11', 'completed'),
(2, 3100000, '2024-09-12', 'completed'),
(3, 4000000, '2024-09-13', 'cancelled'),
(4, 8600000, '2024-09-14', 'completed'),
(5, 2700000, '2024-09-15', 'pending');
SELECT *
FROM orders
WHERE status != 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 0;
SELECT *
FROM orders
WHERE status != 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 5;
SELECT *
FROM orders
WHERE status != 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 10;
SELECT *
FROM orders
WHERE status != 'cancelled'
ORDER BY order_date DESC
LIMIT 5 OFFSET 10;

