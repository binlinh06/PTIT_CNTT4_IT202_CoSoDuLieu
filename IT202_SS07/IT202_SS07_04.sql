DROP DATABASE IF EXISTS ks24_cntt04_ss07_04;
CREATE DATABASE ks24_cntt04_ss07_04;
USE ks24_cntt04_ss07_04;

create table customers(
	id int auto_increment primary key,
    name varchar(255) not null,
    email varchar(255) not null
);

create table orders(
	id int auto_increment primary key,
    customer_id int,
    order_date date,
    total_amount decimal(10,2),
	foreign key (customer_id) references customers(id)
);

INSERT INTO customers (name, email) VALUES
('Nguyen Van A', 'a@gmail.com'),
('Tran Thi B', 'b@gmail.com'),
('Le Van C', 'c@gmail.com'),
('Pham Thi D', 'd@gmail.com'),
('Hoang Van E', 'e@gmail.com');

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2024-01-10', 1500000),
(1, '2024-01-15', 2000000),
(2, '2024-02-01', 1800000),
(3, '2024-02-05', 2200000),
(3, '2024-02-10', 900000),
(4, '2024-02-20', 3000000);

select name , (select count(*) from orders where orders.customer_id = customers.id) as 'total Orders' from customers