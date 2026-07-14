CREATE DATABASE Brazil_Ecommerce;
GO

USE Brazil_Ecommerce;
GO
CREATE TABLE products
(
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100) NULL,
    product_name_lenght INT NULL,
    product_description_lenght INT NULL,
    product_photos_qty INT NULL,
    product_weight_g FLOAT NULL,
    product_length_cm FLOAT NULL,
    product_height_cm FLOAT NULL,
    product_width_cm FLOAT NULL
);

select count(distinct customer_id) as total_customers from customers;
select count(*) as total_order_items from order_items;
select count(*) as total_orders from orders;
select count(*) as total_products from products;
select count(*) as total_sellers from sellers;
SELECT ROUND(SUM(payment_value),2) AS Total_Revenue FROM order_payments;
SELECT ROUND(AVG(payment_value),2) AS Average_Order_Value FROM order_payments;
/* Monthly Sales Trend*/
SELECT
    YEAR(order_purchase_timestamp) AS Year,
    MONTH(order_purchase_timestamp) AS Month,
    ROUND(SUM(payment_value),2) AS Revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY
YEAR(order_purchase_timestamp),
MONTH(order_purchase_timestamp)
ORDER BY Year,Month;
/*Top 10 Product Categories by Revenue*/
SELECT TOP 10
    p.product_category_name,
    ROUND(SUM(op.payment_value),2) AS Revenue
FROM order_items oi
JOIN products p
ON oi.product_id=p.product_id
JOIN order_payments op
ON oi.order_id=op.order_id
GROUP BY p.product_category_name
ORDER BY Revenue DESC;

/*Top 10 Sellers by Revenue*/
SELECT TOP 10
    s.seller_id,
    ROUND(SUM(op.payment_value),2) Revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id=oi.seller_id
JOIN order_payments op
ON oi.order_id=op.order_id
GROUP BY s.seller_id
ORDER BY Revenue DESC;
/*Top 10 States by Revenue*/
SELECT TOP 10
    c.customer_state,
    ROUND(SUM(op.payment_value),2) Revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_payments op
ON o.order_id=op.order_id
GROUP BY c.customer_state
ORDER BY Revenue DESC;

/*Order Status Distribution*/
SELECT
    order_status,
    COUNT(*) Total_Orders
FROM orders
GROUP BY order_status
ORDER BY Total_Orders DESC;
/*Average Delivery Days*/
SELECT
AVG(DATEDIFF(day,
order_purchase_timestamp,
order_delivered_customer_date)) AS Avg_Delivery_Days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
/*Repeat Customers*/
SELECT
COUNT(*) AS Repeat_Customers
FROM
(
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id)>1
)t;
/*Average Freight Cost*/
SELECT
ROUND(AVG(freight_value),2) Avg_Freight
FROM order_items;
/*Top 10 Cities by Orders*/
SELECT TOP 10
c.customer_city,
COUNT(o.order_id) Total_Orders
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.customer_city
ORDER BY Total_Orders DESC;
/*Payment Method Analysis */
SELECT
payment_type,
COUNT(*) Total_Payments,
ROUND(SUM(payment_value),2) Revenue
FROM order_payments
GROUP BY payment_type
ORDER BY Revenue DESC;

/* monthly sales using cte*/
WITH MonthlySales AS
(
SELECT
YEAR(o.order_purchase_timestamp) AS Year,
MONTH(o.order_purchase_timestamp) AS Month,
SUM(op.payment_value) Revenue
FROM orders o
JOIN order_payments op
ON o.order_id=op.order_id
GROUP BY YEAR(o.order_purchase_timestamp),
MONTH(o.order_purchase_timestamp)
)
SELECT *
FROM MonthlySales;
/* running total using window function*/
SELECT
MONTH(o.order_purchase_timestamp) Month,
SUM(op.payment_value) Revenue,
SUM(SUM(op.payment_value))
OVER(ORDER BY MONTH(o.order_purchase_timestamp))
Running_Total
FROM orders o
JOIN order_payments op
ON o.order_id=op.order_id
GROUP BY MONTH(o.order_purchase_timestamp);
/* repeat customers using customer_unique_id and the total orders they placed*/
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS Total_Orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY Total_Orders DESC;
/* repeat customers using customer_unique_id*/
SELECT
    COUNT(*) AS Repeat_Customers
FROM
(
    SELECT
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
) AS RepeatCustomer;