DROP DATABASE IF EXISTS ks24_cntt04_ss06_03;
CREATE DATABASE ks24_cntt04_ss06_03;
USE ks24_cntt04_ss06_03;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0)
);

INSERT INTO orders (order_date, status, total_amount) VALUES
('2024-09-01', 'completed', 3500000),
('2024-09-01', 'completed', 4200000),
('2024-09-01', 'completed', 2800000),
('2024-09-02', 'completed', 6000000),
('2024-09-02', 'completed', 5200000),
('2024-09-03', 'completed', 9000000),
('2024-09-03', 'pending',   3000000),
('2024-09-04', 'completed', 12000000),
('2024-09-04', 'completed', 2500000),
('2024-09-05', 'cancelled', 8000000);

SELECT
    order_date,
    SUM(total_amount) AS total_revenue,
    COUNT(order_id) AS total_orders
FROM orders
WHERE status = 'completed'
GROUP BY order_date
HAVING SUM(total_amount) > 10000000;
