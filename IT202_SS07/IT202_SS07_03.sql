DROP DATABASE IF EXISTS ks24_cntt04_ss07_03;
CREATE DATABASE ks24_cntt04_ss07_03;
USE ks24_cntt04_ss07_03;

create table orders(
	id int auto_increment primary key,
    customer_id int ,
    order_date date,
    total_amount decimal(10,2)
);

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2024-01-10', 1500000),
(2, '2024-01-15', 2500000),
(3, '2024-02-01', 1800000),
(4, '2024-02-10', 3200000),
(5, '2024-02-20', 900000);

select * from orders where total_amount > (select avg(total_amount) from orders);