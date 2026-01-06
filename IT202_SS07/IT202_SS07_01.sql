DROP DATABASE IF EXISTS ks24_cntt04_ss07_01;
CREATE DATABASE ks24_cntt04_ss07_01;
USE ks24_cntt04_ss07_01;

CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
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
('Hoang Van E', 'e@gmail.com'),
('Vu Thi F', 'f@gmail.com'),
('Do Van G', 'g@gmail.com');
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2024-01-10', 1500000),
(1, '2024-02-15', 2300000),
(2, '2024-03-05', 1200000),
(3, '2024-03-20', 3400000),
(4, '2024-04-01', 980000),
(5, '2024-04-10', 1750000),
(6, '2024-04-18', 2100000);

select * from customers where id in (select distinct customer_id from orders);

-- Mở rộng :Đưa thêm thông tin tổng số đơn hàng của mỗi khách hàng 
-- C1: join thông thường
select c.*,count(od.id) as 'Total orders' from customers c
join orders od on c.id = od.customer_id
group by c.id;
-- C2:Truy vấn lồng
select *,(select count(id) from orders where customer_id = customers.id)
as 'Total orders' from customers
