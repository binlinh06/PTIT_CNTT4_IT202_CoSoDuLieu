DROP DATABASE IF EXISTS ks24_cntt04_ss06_01;
CREATE DATABASE ks24_cntt04_ss06_01;
USE ks24_cntt04_ss06_01;

Create table Customers (
	customer_id int auto_increment primary key,
    full_name varchar(255) not null,
    city varchar(255) not null
);

Create table Orders (
	order_id int auto_increment primary key,
    customer_id int not null,
	order_date DATE NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers (full_name, city) VALUES
('Nguyễn Văn A', 'Hà Nội'),
('Trần Thị B', 'TP.HCM'),
('Lê Văn C', 'Đà Nẵng'),
('Phạm Thị D', 'Hà Nội'),
('Hoàng Văn E', 'Cần Thơ');
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2024-09-01', 'completed'),
(1, '2024-09-05', 'pending'),
(2, '2024-09-02', 'completed'),
(3, '2024-09-03', 'cancelled'),
(4, '2024-09-04', 'completed'),
(5, '2024-09-06', 'pending');

select o.order_id ,c.full_name,c.city,o.order_date,o.status 
from Orders o join Customers c on o.customer_id = c.customer_id;

SELECT c.customer_id,c.full_name,COUNT(o.order_id) AS total_orders
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

SELECT  c.customer_id, c.full_name, COUNT(o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) >= 1;	