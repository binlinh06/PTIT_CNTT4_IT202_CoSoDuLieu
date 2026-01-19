-- Phần I : Thiết kế CSDL
-- Câu 1 - Phân tích yêu cầu và vẽ sơ đồ ERD
DROP DATABASE IF EXISTS quanlybanhang;

-- Câu 2 
-- 2.1 Tạo CSDL
CREATE DATABASE quanlybanhang;
USE quanlybanhang;

-- 2.2 Tạo bảng Customers
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255)
);

-- 2.2 Tạo bảng Products
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

-- 2.2 Tạo bảng Employees
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    birthday DATE,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    revenue DECIMAL(10,2) DEFAULT 0
);

-- 2.2 Tạo bảng Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 2.2 Tạo bảng OrderDetails
CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Câu 3 - Chỉnh sửa cấu trúc bảng

-- 3.1 Thêm cột email vào Customers
ALTER TABLE Customers
ADD email VARCHAR(100) NOT NULL UNIQUE;

-- 3.2 Xóa cột birthday khỏi Employees
ALTER TABLE Employees
DROP COLUMN birthday;

-- PHẦN 2: TRUY VẤN DỮ LIỆU
-- Câu 4 - Chèn dữ liệu

-- Customers
INSERT INTO Customers (customer_name, phone, address, email) VALUES
('Nguyen Van A', '0901111111', 'Ha Noi', 'a@gmail.com'),
('Tran Thi B', '0902222222', 'Hai Phong', 'b@gmail.com'),
('Le Van C', '0903333333', 'Da Nang', 'c@gmail.com'),
('Pham Thi D', '0904444444', 'Hue', 'd@gmail.com'),
('Hoang Van E', '0905555555', 'HCM', 'e@gmail.com');

-- Products
INSERT INTO Products (product_name, price, quantity, category) VALUES
('Laptop Dell', 1200.00, 50, 'Laptop'),
('iPhone 14', 1000.00, 200, 'Phone'),
('Chuột Logitech', 25.00, 500, 'Accessory'),
('Bàn phím cơ', 80.00, 300, 'Accessory'),
('Màn hình LG', 300.00, 150, 'Monitor');

-- Employees
INSERT INTO Employees (employee_name, position, salary) VALUES
('Nguyen NV1', 'Sale', 800),
('Nguyen NV2', 'Sale', 900),
('Nguyen NV3', 'Manager', 1500),
('Nguyen NV4', 'Sale', 850),
('Nguyen NV5', 'Sale', 870);

-- Orders
INSERT INTO Orders (customer_id, employee_id) VALUES
(1,1),
(2,2),
(3,3),
(1,4),
(2,5);

-- OrderDetails
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1,1,2,1200),
(1,3,5,25),
(2,2,3,1000),
(3,4,10,80),
(4,5,4,300);

-- Câu 5 - Truy vấn cơ bản

-- 5.1 Lấy danh sách tất cả khách hàng từ bảng Customers. Thông tin gồm : mã khách hàng, tên khách hàng, email, số điện thoại và địa chỉ
SELECT customer_id, customer_name, email, phone, address
FROM Customers;

-- 5.2 Sửa thông tin của sản phẩm có product_id = 1 theo yêu cầu : product_name=“Laptop Dell XPS” và price = 99.99
UPDATE Products
SET product_name = 'Laptop Dell XPS',
    price = 99.99
WHERE product_id = 1;

-- 5.3 Lấy thông tin những đơn đặt hàng gồm : mã đơn hàng, tên khách hàng, tên nhân viên, tổng tiền và ngày đặt hàng.
SELECT o.order_id,
       c.customer_name,
       e.employee_name,
       o.total_amount,
       o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id;

-- CÂU 6 – TRUY VẤN ĐẦY ĐỦ

-- 6.1 Đếm số lượng đơn hàng của mỗi khách hàng. Thông tin gồm : mã khách hàng, tên khách hàng, tổng số đơn
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 6.2 Thống kê tổng doanh thu của từng nhân viên trong năm hiện tại. Thông tin gồm : mã nhân viên, tên nhân viên, doanh thu
SELECT e.employee_id, e.employee_name, SUM(o.total_amount) AS revenue
FROM Employees e
JOIN Orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY e.employee_id, e.employee_name;

-- 6.3 Thống kê những sản phẩm có số lượng đặt hàng lớn hơn 100 trong tháng hiện tại.Thông tin gồm : mã sản phẩm, tên sản phẩm, số lượt đặt và sắp xếp theo số lượng giảm dần
SELECT p.product_id, p.product_name,
       SUM(od.quantity) AS total_quantity
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.order_id
JOIN Products p ON od.product_id = p.product_id
WHERE MONTH(o.order_date) = MONTH(CURDATE())
  AND YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY p.product_id, p.product_name
HAVING total_quantity > 100
ORDER BY total_quantity DESC;

-- CÂU 7 – TRUY VẤN NÂNG CAO

-- 7.1 Lấy danh sách khách hàng chưa từng đặt hàng. Thông tin gồm : mã khách hàng và tên khách hàng
SELECT c.customer_id, c.customer_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 7.2 Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT *
FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- 7.3 Tìm những khách hàng có mức chi tiêu cao nhất. Thông tin gồm : mã khách hàng,
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING total_spent = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(total_amount) AS total
        FROM Orders
        GROUP BY customer_id
    ) t
);

-- Câu 8 - Tạo view	

-- 8.1 Tạo view có tên view_order_list hiển thị thông tin đơn hàng gồm : mã đơn hàng, tên khách hàng, tên nhân viên, tổng tiền và ngày đặt. Các bản ghi sắp xếp theo thứ tự ngày đặt mới nhất
CREATE VIEW view_order_list AS
SELECT o.order_id,
       c.customer_name,
       e.employee_name,
       o.total_amount,
       o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC;

-- 8.2 Tạo view có tên view_order_detail_product hiển thị chi tiết đơn hàng gồm : Mã chi tiết đơn hàng, tên sản phẩm, số lượng và giá tại thời điểm mua. Thông tin sắp xếp theo số lượng giảm dần
CREATE VIEW view_order_detail_product AS
SELECT od.order_detail_id,
       p.product_name,
       od.quantity,
       od.unit_price
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
ORDER BY od.quantity DESC;

-- Câu 9 - Tạo thủ tục lưu trữ
DELIMITER $$

-- 9.1 Tạo thủ tục có tên proc_insert_employee nhận vào các thông tin cần thiết (trừ mã nhân viên và tổng doanh thu) , thực hiện thêm mới dữ liệu vào bảng nhân viên và trả về mã nhân viên vừa mới thêm.
CREATE PROCEDURE proc_insert_employee (
    IN p_name VARCHAR(100),
    IN p_position VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    OUT p_employee_id INT
)
BEGIN
    INSERT INTO Employees(employee_name, position, salary)
    VALUES (p_name, p_position, p_salary);

    SET p_employee_id = LAST_INSERT_ID();
END$$

-- 9.2 Tạo thủ tục có tên proc_get_orderdetails lọc những chi tiết đơn hàng dựa theo mã đặt hàng.
CREATE PROCEDURE proc_get_orderdetails (IN p_order_id INT)
BEGIN
    SELECT *
    FROM OrderDetails
    WHERE order_id = p_order_id;
END$$

-- 9.3 Tạo thủ tục có tên proc_cal_total_amount_by_order nhận vào tham số là mã đơn hàng và trả về số lượng loại sản phẩm trong đơn hàng đó.
CREATE PROCEDURE proc_cal_total_amount_by_order (
    IN p_order_id INT,
    OUT total_products INT
)
BEGIN
    SELECT COUNT(DISTINCT product_id)
    INTO total_products
    FROM OrderDetails
    WHERE order_id = p_order_id;
END$$

DELIMITER ;
-- Câu 10 - Tạo trigger

DELIMITER $$

CREATE TRIGGER trigger_after_insert_order_details
BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE stock INT;

    SELECT quantity INTO stock
    FROM Products
    WHERE product_id = NEW.product_id;

    IF stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số lượng sản phẩm trong kho không đủ';
    ELSE
        UPDATE Products
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END$$

DELIMITER ;
-- Câu 11 - Quản lý transaction

DELIMITER $$

CREATE PROCEDURE proc_insert_order_details (
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Kiểm tra tồn tại đơn hàng
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'không tồn tại mã hóa đơn';
    END IF;

    -- Thêm chi tiết đơn hàng
    INSERT INTO OrderDetails(order_id, product_id, quantity, unit_price)
    VALUES (p_order_id, p_product_id, p_quantity, p_price);

    -- Cập nhật tổng tiền
    UPDATE Orders
    SET total_amount = total_amount + (p_quantity * p_price)
    WHERE order_id = p_order_id;

    COMMIT;
END$$

DELIMITER ;
