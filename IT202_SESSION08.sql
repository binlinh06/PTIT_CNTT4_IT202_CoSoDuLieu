CREATE DATABASE Session08;
USE Session08;

CREATE TABLE customers(
	customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    email varchar(100) unique not null,
    phone varchar(10) unique not null
);

CREATE TABLE categories(
	category_id int primary key auto_increment,
    category_name varchar(255) not null unique
);

CREATE TABLE products(
	product_id int primary key auto_increment,
    product_name varchar(255) not null unique,
    price decimal(10,0) not null check(price>0),
    category_id int not null,
    foreign key (category_id) references categories(category_id)
);

CREATE TABLE orders(
	order_id int primary key auto_increment,
    customer_id int not null,
    order_date datetime default(current_date()) not null,
    status enum('pending','completed','cancel') default('pending')
);

CREATE TABLE order_items(
	order_item_id int primary key auto_increment,
    order_id int not null,
    product_id int not null,
    quantity int not null check(quantity>0),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

INSERT INTO categories (category_name) VALUES
('Electronics'),
('Clothing'),
('Home & Kitchen'),
('Books'),
('Sports'),
('Beauty');

INSERT INTO products (product_name, price, category_id) VALUES
('Smartphone X', 7500000, 1),
('T-Shirt Basic', 150000, 2),
('Blender Pro', 1200000, 3),
('Learning SQL Book', 250000, 4),
('Football', 300000, 5),
('Skincare Set', 450000, 6);

INSERT INTO customers (customer_name, email, phone) VALUES
('Nguyễn Văn A', 'nva@example.com', '0912345670'),
('Trần Thị B', 'ttb@example.com', '0912345671'),
('Lê Văn C', 'lvc@example.com', '0912345672'),
('Phạm Thị D', 'ptd@example.com', '0912345673'),
('Hoàng Minh E', 'hme@example.com', '0912345674'),
('Vũ Thị F', 'vtf@example.com', '0912345675');

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2024-08-01 10:15:00', 'completed'),
(2, '2024-08-03 14:20:00', 'pending'),
(3, '2024-08-05 09:30:00', 'completed'),
(4, '2024-08-07 16:45:00', 'cancel'),
(5, '2024-08-10 11:00:00', 'completed'),
(6, '2024-08-12 13:10:00', 'pending');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1), 
(1, 4, 2),  
(2, 2, 3),  
(3, 3, 1), 
(5, 5, 2),  
(6, 6, 1); 

-- PHẦN A – TRUY VẤN DỮ LIỆU CƠ BẢN
-- Lấy danh sách tất cả danh mục sản phẩm trong hệ thống.
SELECT * FROM categories;

-- Lấy danh sách đơn hàng có trạng thái là COMPLETED
SELECT * FROM orders 
WHERE status = 'completed';

-- Lấy danh sách sản phẩm và sắp xếp theo giá giảm dần
SELECT * FROM products
ORDER BY price DESC;

-- Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
SELECT * FROM products
ORDER BY price DESC
LIMIT 5 OFFSET 2;

-- PHẦN B – TRUY VẤN NÂNG CAO
-- Lấy danh sách sản phẩm kèm tên danh mục
SELECT p.product_id, p.product_name, p.price, c.category_name FROM products p
JOIN categories c ON p.category_id = c.category_id
ORDER BY p.product_name;

-- Lấy danh sách đơn hàng
SELECT o.order_id, o.order_date, c.customer_name, o.status FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- Tính tổng số lượng sản phẩm trong từng đơn hàng
SELECT oi.order_id, SUM(oi.quantity) AS total_quantity FROM order_items oi
GROUP BY oi.order_id
ORDER BY oi.order_id;

-- Thống kê số đơn hàng của mỗi khách hàng
SELECT o.customer_id, c.customer_name, COUNT(*) AS order_count FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
ORDER BY order_count DESC;

-- Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
SELECT o.customer_id, c.customer_name, COUNT(*) AS order_count FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING COUNT(*) >= 2
ORDER BY order_count DESC;

-- Thống kê giá trung bình, thấp nhất và cao nhất của sản phẩm theo danh mục
SELECT p.category_id, c.category_name, AVG(p.price) AS avg_price, MIN(p.price) AS min_price, MAX(p.price) AS max_price FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.category_id, c.category_name
ORDER BY c.category_name;

-- PHẦN C – TRUY VẤN LỒNG (SUBQUERY)
-- Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT product_id, product_name, price FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Lấy danh sách khách hàng đã từng đặt ít nhất một đơn hàng
SELECT customer_id, customer_name, email, phone FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders);

-- Lấy đơn hàng có tổng số lượng sản phẩm lớn nhất
SELECT oi_totals.order_id, oi_totals.total_quantity 
FROM (
	SELECT order_id, SUM(quantity) AS total_quantity 
	FROM order_items 
	GROUP BY order_id) AS oi_totals
WHERE oi_totals.total_quantity = (
	SELECT MAX(total_quantity) 
	FROM (
		SELECT order_id, SUM(quantity) AS total_quantity 
		FROM order_items 
        GROUP BY order_id
	  ) AS totals
);

-- Lấy tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất
SELECT DISTINCT customer_name
FROM customers
WHERE customer_id IN (
  SELECT o.customer_id FROM orders o
  WHERE o.order_id IN (
    SELECT order_id FROM order_items
    WHERE product_id IN (
      SELECT product_id FROM products
      WHERE category_id = (
        SELECT category_id FROM (
          SELECT category_id FROM products
          GROUP BY category_id
          ORDER BY AVG(price) DESC
          LIMIT 1
        ) AS top_cat
      )
    )
  )
);

-- Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng
SELECT o.customer_id,
	(SELECT customer_name 
	FROM customers 
	WHERE customer_id = o.customer_id) AS customer_name,
	SUM(per_order.qty_per_order) AS total_quantity
FROM orders o
JOIN (
  SELECT order_id, SUM(quantity) AS qty_per_order
  FROM order_items
  GROUP BY order_id
) AS per_order ON o.order_id = per_order.order_id
GROUP BY o.customer_id;

-- Viết lại truy vấn lấy sản phẩm có giá cao nhất
SELECT product_id, product_name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);
