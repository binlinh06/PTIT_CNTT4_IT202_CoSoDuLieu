DROP DATABASE IF EXISTS ks24_cntt04_ss07_06;
CREATE DATABASE ks24_cntt04_ss07_06;
USE ks24_cntt04_ss07_06;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
);
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2024-01-10', 1500000),
(1, '2024-02-15', 2500000),
(2, '2024-01-20', 3000000),
(2, '2024-03-05', 1000000),
(3, '2024-02-01', 4000000),
(4, '2024-02-10', 2000000),
(5, '2024-03-01', 1200000);
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM orders
        GROUP BY customer_id
    ) AS temp
);
