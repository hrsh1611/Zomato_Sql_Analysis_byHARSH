
-- ZOMATO PROJECT(Harsh): DATA IMPORT & TABLE CREATION


-- Step 1: Drop existing database (for clean run)
DROP DATABASE IF EXISTS zomato_project;

-- Step 2: Create new database
CREATE DATABASE zomato_project;

-- Step 3: Use database
USE zomato_project;


-- Step 4: Create Table

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(150),
    city VARCHAR(100),
    cuisine VARCHAR(100)
);

CREATE TABLE riders (
    rider_id INT PRIMARY KEY,
    rider_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATETIME,
    order_amount DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    order_id INT,
    rider_id INT,
    delivery_time INT,
    delivery_status VARCHAR(50),

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);

-- Step 5: Import Data (tablewise)

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

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
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/deliveries.csv'
INTO TABLE deliveries
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================
-- Step 6: Verify Data
-- ============================================

SELECT * FROM customers LIMIT 5;
SELECT * FROM restaurants LIMIT 5;
SELECT * FROM riders LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM deliveries LIMIT 5;

-- END 