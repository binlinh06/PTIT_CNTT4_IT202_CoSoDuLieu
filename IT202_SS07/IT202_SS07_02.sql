DROP DATABASE IF EXISTS ks24_cntt04_ss07_02;
CREATE DATABASE ks24_cntt04_ss07_02;
USE ks24_cntt04_ss07_02;

create table products(
	id int auto_increment primary key,
    name varchar(255) not null,
    price DECIMAL(10,2) not null
);

create table order_items(
	order_id int,
    product_id int,
    quantity int not null,
    primary key(order_id,product_id),
    foreign key (product_id) references products(id)
);
INSERT INTO products (name, price) VALUES
('Laptop Dell', 18000000),
('iPhone 14', 22000000),
('Samsung Galaxy S23', 20000000),
('Tai nghe Bluetooth', 1500000),
('Chuột không dây', 500000),
('Bàn phím cơ', 1200000),
('Màn hình 24 inch', 3500000);
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 4, 2),
(2, 2, 1),
(2, 5, 1),
(3, 3, 1),
(3, 6, 1),
(4, 7, 2);

select * from products where id in (select distinct product_id from order_items);