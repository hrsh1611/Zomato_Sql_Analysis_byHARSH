USE zomato_project;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@customer_id, @customer_name, @reg_date)
SET 
customer_id = @customer_id,
customer_name = @customer_name,
reg_date = STR_TO_DATE(@reg_date, '%m/%d/%Y');

select*from customers limit 5;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/restaurants.csv'
INTO TABLE restaurants
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/riders.csv'
INTO TABLE riders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@rider_id, @rider_name, @sign_up_date)
SET
rider_id = @rider_id,
rider_name = @rider_name,
sign_up_date = STR_TO_DATE(@sign_up_date, '%m/%d/%Y');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id, @customer_id, @restaurant_id, @order_item, @order_date, @order_time, @order_status, @total_amount)
SET
order_id = @order_id,
customer_id = @customer_id,
restaurant_id = @restaurant_id,
order_item = @order_item,
order_date = STR_TO_DATE(@order_date, '%m/%d/%Y'),
order_time = @order_time,
order_status = @order_status,
total_amount = @total_amount;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/deliveries.csv'
INTO TABLE deliveries
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    o.order_id,
    c.customer_name,
    r.restaurant_name,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
LIMIT 10;
#What % of customers never place a second order after their first purchase?

WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    ROUND(
        SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS pct_one_time_customers
FROM customer_orders;
 
/* Only 1% customers didn't return after their 1st purchase which indicates high retention.However, this seems unrealistic and likely reflects a dataset bias towards repeat users*/

/* QUE2 - How much of total revenue contribution is made by top 5% customers?*/

WITH customer_revenue AS (
    SELECT 
        customer_id,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT 
        customer_id,
        revenue,
        NTILE(20) OVER (ORDER BY revenue DESC) AS bucket
    FROM customer_revenue
)
SELECT 
    ROUND(
        SUM(CASE WHEN bucket = 1 THEN revenue END) * 100.0 / SUM(revenue),
        2
    ) AS top_5pct_revenue_contribution
FROM ranked_customers;

/* Top 5% customers contribute to 8.85% of total revenue, which indicates that revenue is fairly distributed and not highly dependent on top customers only */

/* QUE3- What is the average time (in days) between two consecutive orders for each customer? */

WITH ordered_data AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date
    FROM orders
),
date_diff_calc AS (
    SELECT 
        customer_id,
        DATEDIFF(order_date, prev_order_date) AS days_between_orders
    FROM ordered_data
    WHERE prev_order_date IS NOT NULL
)
SELECT 
    ROUND(AVG(days_between_orders), 2) AS avg_days_between_orders
FROM date_diff_calc;
/* On average, customers take around 81.46 days between consecutive orders, whihc indicates low ordering frequency and potential scope to improve engagement */

/* QUE4- What percentage of orders are cancelled? */

SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_pct
FROM orders;
/* Around 9.83% of the orders are cancelled, which is a noticeable number and could point towards issues like delays, availability, or customer drop-offs */

/* QUE5- Which are the top 5 restaurants by total revenue? */
SELECT 
    r.restaurant_name,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM orders o
JOIN restaurants r 
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC
LIMIT 5;
/* A few restaurants like Nehas Bistro and Abhas Dhaba are clearly leading in revenue, showing that a small set of outlets are driving a big portion of overall sales */

/* QUE6- What is the average order value (AOV)? */

SELECT 
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders;
/* On average, customers are spending around 215 per order, which gives a decent idea of typical order size on the platform */

/* QUE7- Which day of the week has the highest number of orders? */
SELECT 
    DAYNAME(order_date) AS day_name,
    COUNT(*) AS total_orders
FROM orders
GROUP BY day_name
ORDER BY total_orders DESC
LIMIT 1;
/* Orders peak on Wednesdays with 14,572 orders, showing a clear mid-week spike in customer activity compared to other days */

/* QUE7- What is the percentage of orders delivered on time? */
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    ROUND(
        SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS delivery_success_rate_pct
FROM orders;
/* Around 90.17% of the orders were successfully delivered, which shows the delivery process is quite reliable with only a small share facing issues */

/* QUE9 - Who are the top 5 customers by total spending? */
SELECT 
    c.customer_name,
    ROUND(SUM(o.total_amount), 2) AS total_spent
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 5;
/* Top spenders include Gautam Mane (₹8503), Balveer Patla (₹7725), Avni Ramaswamy (₹7695), Tristan Hayer (₹6940), and Pushti Kakar (₹6818), but overall revenue isn’t heavily concentrated, as even the top 5% contribute only 8.85% */

/* QUE10 - Which city generates the highest revenue? */
SELECT 
    r.city,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM orders o
JOIN restaurants r 
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY total_revenue DESC
LIMIT 1;
/* Mumbai brings in the highest revenue at 1,934,426, which clearly shows stronger demand and higher order activity compared to other cities */
