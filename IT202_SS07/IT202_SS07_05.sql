DROP DATABASE IF EXISTS ks24_cntt04_ss07_05;
CREATE DATABASE ks24_cntt04_ss07_05;
USE ks24_cntt04_ss07_05;

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);
INSERT INTO customers (name, email) VALUES
('Nguyen Van A', 'a@gmail.com'),
('Tran Thi B', 'b@gmail.com'),
('Le Van C', 'c@gmail.com'),
('Pham Thi D', 'd@gmail.com'),
('Hoang Van E', 'e@gmail.com');
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2024-01-10', 1500000),
(1, '2024-02-15', 2500000),
(2, '2024-01-20', 3000000),
(2, '2024-03-05', 1000000),
(3, '2024-02-01', 4000000),
(4, '2024-02-10', 2000000),
(5, '2024-03-01', 1200000);
SELECT name, email FROM customers WHERE id IN (SELECT customer_id FROM orders
GROUP BY customer_id HAVING SUM(total_amount) = (
SELECT MAX(total_spent)FROM (SELECT SUM(total_amount) AS total_spent FROM orders
GROUP BY customer_id) AS temp));
