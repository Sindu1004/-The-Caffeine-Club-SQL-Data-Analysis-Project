/*THE CAFFEINE CLUB – COMPLETE SQL PROJECT*/

-- 1. DATABASE
CREATE DATABASE IF NOT EXISTS the_caffeine_club;
USE the_caffeine_club;

-- 2. TABLES

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(50) NOT NULL,
    visit_type VARCHAR(20),        -- New / Returning
    signup_date DATE
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(50) NOT NULL,
    category VARCHAR(30),          -- Tea, Coffee, Juices, Milkshakes, Snacks, Meals
    cost_price DECIMAL(6,2),
    selling_price DECIMAL(6,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    order_time TIME,
    total_amount DECIMAL(8,2),
    payment_mode VARCHAR(20),      -- UPI / Cash / Card
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    item_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- 3. DATA INSERTION

-- Customers
INSERT INTO customers (customer_name, visit_type, signup_date) VALUES
('Rahul','New','2025-01-05'),
('Anita','Returning','2025-01-02'),
('Suresh','Returning','2025-01-03'),
('Meena','New','2025-01-06'),
('Karthik','Returning','2025-01-07');

-- Menu Items
INSERT INTO menu_items VALUES
(101,'Masala Tea','Tea',10,20),
(102,'Ginger Tea','Tea',12,25),
(103,'Green Tea','Tea',15,30),
(104,'Filter Coffee','Coffee',15,30),
(105,'Cold Coffee','Coffee',30,70),
(106,'Fresh Juice','Juices',25,60),
(107,'Milkshake','Milkshakes',35,80),
(108,'Veg Puff','Snacks',15,30),
(109,'Samosa','Snacks',12,25),
(110,'Biscuits','Snacks',8,15),
(111,'Veg Sandwich','Meals',35,75),
(112,'Veg Biryani','Meals',80,150);

-- Orders
INSERT INTO orders (customer_id, order_date, order_time, total_amount, payment_mode) VALUES
(1,'2025-01-06','09:20:00',135,'UPI'),
(2,'2025-01-06','10:10:00',55,'Cash'),
(3,'2025-01-07','13:45:00',230,'Card'),
(4,'2025-01-07','19:30:00',80,'UPI'),
(5,'2025-01-08','12:15:00',150,'UPI');

-- Order Details
INSERT INTO order_details (order_id, item_id, quantity) VALUES
(1,101,1),
(1,109,2),
(2,102,2),
(3,112,1),
(3,105,1),
(4,107,1),
(5,111,1);

-- =========================================
-- ANALYTICS QUERIES
-- =========================================

-- DAILY SALES SUMMARY
SELECT 
    o.order_date,
    COUNT(DISTINCT o.customer_id) AS no_of_customers,
    COUNT(DISTINCT o.order_id) AS no_of_sales,
    SUM(od.quantity) AS items_sold,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- ITEM-WISE DAILY SALES
SELECT 
    o.order_date,
    m.item_name,
    SUM(od.quantity) AS items_sold
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN menu_items m ON od.item_id = m.item_id
GROUP BY o.order_date, m.item_name
ORDER BY o.order_date, items_sold DESC;

-- WEEKLY SALES SUMMARY
SELECT 
    YEAR(order_date) AS year,
    WEEK(order_date, 1) AS week,
    COUNT(order_id) AS no_of_sales,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY year, week
ORDER BY year, week;

-- MONTHLY SALES SUMMARY
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(order_id) AS no_of_sales,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY year, month
ORDER BY year, month;

-- PROFIT PER ITEM
SELECT 
    m.item_name,
    SUM(od.quantity * (m.selling_price - m.cost_price)) AS profit
FROM order_details od
JOIN menu_items m ON od.item_id = m.item_id
GROUP BY m.item_name
ORDER BY profit DESC;

-- SALES TREND (INCREASE / DECREASE)
SELECT 
    order_date,
    daily_revenue,
    daily_revenue - LAG(daily_revenue) 
        OVER (ORDER BY order_date) AS revenue_change
FROM (
    SELECT 
        order_date,
        SUM(total_amount) AS daily_revenue
    FROM orders
    GROUP BY order_date
) t;

-- TOP 3 PROFITABLE ITEMS
SELECT *
FROM (
    SELECT 
        m.item_name,
        SUM(od.quantity * (m.selling_price - m.cost_price)) AS profit,
        RANK() OVER (
            ORDER BY SUM(od.quantity * (m.selling_price - m.cost_price)) DESC
        ) AS rank_no
    FROM order_details od
    JOIN menu_items m ON od.item_id = m.item_id
    GROUP BY m.item_name
) ranked_items
WHERE rank_no <= 3;
