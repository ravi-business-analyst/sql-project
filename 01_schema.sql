-- SwiftBite Analytics: database structure
-- Made for MySQL 8.0 (window functions are used in the exercise).

DROP DATABASE IF EXISTS SwiftBite_Analytics;
CREATE DATABASE SwiftBite_Analytics;
USE SwiftBite_Analytics;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL,
    age TINYINT UNSIGNED,
    signup_date DATE NOT NULL,
    membership_tier ENUM('Basic', 'Silver', 'Gold', 'Platinum') NOT NULL DEFAULT 'Basic'
);

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(150) NOT NULL,
    city VARCHAR(60) NOT NULL,
    cuisine_type VARCHAR(80) NOT NULL,
    restaurant_type VARCHAR(80),
    is_pure_veg BOOLEAN NOT NULL DEFAULT FALSE,
    avg_rating DECIMAL(3,2),
    total_reviews INT UNSIGNED NOT NULL DEFAULT 0,
    avg_prep_time_min SMALLINT UNSIGNED,
    registered_date DATE NOT NULL
);

CREATE TABLE delivery_agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL,
    vehicle_type VARCHAR(30) NOT NULL,
    avg_rating DECIMAL(3,2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    cuisine_type VARCHAR(80) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    is_veg BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_menu_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    order_time DATETIME NOT NULL,
    order_status ENUM('Delivered', 'Cancelled', 'Preparing', 'Out for Delivery') NOT NULL,
    payment_mode VARCHAR(30),
    promo_code VARCHAR(40),
    subtotal DECIMAL(10,2) NOT NULL,
    discount_applied DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    cancel_reason VARCHAR(255),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_order_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    quantity SMALLINT UNSIGNED NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_item_menu FOREIGN KEY (item_id) REFERENCES menu_items(item_id),
    CONSTRAINT fk_item_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    agent_id INT NOT NULL,
    actual_time_min SMALLINT UNSIGNED NOT NULL,
    promised_time_min SMALLINT UNSIGNED NOT NULL,
    distance_km DECIMAL(6,2) NOT NULL,
    delivery_status ENUM('On Time', 'Late', 'Very Late') NOT NULL,
    agent_tip DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_delivery_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_delivery_agent FOREIGN KEY (agent_id) REFERENCES delivery_agents(agent_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    food_rating TINYINT UNSIGNED NOT NULL,
    delivery_rating TINYINT UNSIGNED NOT NULL,
    review_time DATETIME NOT NULL,
    CONSTRAINT chk_food_rating CHECK (food_rating BETWEEN 1 AND 5),
    CONSTRAINT chk_delivery_rating CHECK (delivery_rating BETWEEN 1 AND 5),
    CONSTRAINT fk_review_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_review_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE INDEX idx_orders_status_time ON orders(order_status, order_time);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_deliveries_agent ON deliveries(agent_id);
CREATE INDEX idx_reviews_restaurant_time ON reviews(restaurant_id, review_time);

