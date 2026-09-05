-- ============================================================
--  SwiftBite_Analytics — 60 SQL PRACTICE QUESTIONS
--  Mix of Beginner → Advanced | Window Functions | CTEs | KPIs
-- ============================================================

USE SwiftBite_Analytics;

-- ────────────────────────────────────────────────────────────
-- ★ SECTION 1 — BEGINNER (SELECT, WHERE, ORDER BY, LIMIT)
-- ────────────────────────────────────────────────────────────

-- Q1. Show all restaurants in Bangalore.
SELECT restaurant_name, cuisine_type, restaurant_type, avg_rating
FROM restaurants
WHERE city = 'Bangalore'
ORDER BY avg_rating DESC;

-- Q2. List all pure-veg restaurants with a rating above 4.0.
SELECT restaurant_name, city, cuisine_type, avg_rating
FROM restaurants
WHERE is_pure_veg = 1 AND avg_rating > 4.0
ORDER BY avg_rating DESC;

-- Q3. Show the top 10 most-reviewed restaurants.
SELECT restaurant_name, city, cuisine_type, total_reviews, avg_rating
FROM restaurants
ORDER BY total_reviews DESC
LIMIT 10;

-- Q4. Find all Platinum-tier customers.
SELECT customer_name, city, age, signup_date
FROM customers
WHERE membership_tier = 'Platinum'
ORDER BY signup_date;

-- Q5. Show all orders placed on a weekend (Saturday=7, Sunday=1 in MySQL).
SELECT order_id, customer_id, restaurant_id, order_time, total_amount
FROM orders
WHERE DAYOFWEEK(order_time) IN (1, 7)
ORDER BY order_time DESC
LIMIT 50;

-- Q6. Find all cancelled orders and their cancellation reasons.
SELECT order_id, customer_id, restaurant_id, order_time, total_amount, cancel_reason
FROM orders
WHERE order_status = 'Cancelled'
ORDER BY order_time DESC;

-- Q7. Show menu items priced above ₹300.
SELECT item_name, cuisine_type, price, is_veg
FROM menu_items
WHERE price > 300
ORDER BY price DESC;

-- Q8. Count the total number of active delivery agents.
SELECT COUNT(*) AS active_agents
FROM delivery_agents
WHERE is_active = 1;

-- Q9. Find all orders where a promo code was used.
SELECT order_id, customer_id, promo_code, subtotal, discount_applied, total_amount
FROM orders
WHERE promo_code IS NOT NULL
ORDER BY discount_applied DESC;

-- Q10. Show all deliveries that were marked 'Very Late'.
SELECT d.delivery_id, d.order_id, da.agent_name, da.city,
       d.actual_time_min, d.promised_time_min, d.distance_km
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.agent_id
WHERE d.delivery_status = 'Very Late'
ORDER BY d.actual_time_min DESC;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 2 — INTERMEDIATE (GROUP BY, HAVING, Aggregates)
-- ────────────────────────────────────────────────────────────

-- Q11. Total revenue per city (Delivered orders only).
SELECT r.city,
       COUNT(o.order_id)                    AS total_orders,
       ROUND(SUM(o.total_amount), 2)        AS total_revenue,
       ROUND(AVG(o.total_amount), 2)        AS avg_order_value
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.city
ORDER BY total_revenue DESC;

-- Q12. Revenue and order count by cuisine type.
SELECT r.cuisine_type,
       COUNT(o.order_id)               AS total_orders,
       ROUND(SUM(o.total_amount), 2)   AS total_revenue,
       ROUND(AVG(o.total_amount), 2)   AS avg_order_value
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.cuisine_type
ORDER BY total_revenue DESC;

-- Q13. Most popular payment mode.
SELECT payment_mode,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY payment_mode
ORDER BY order_count DESC;

-- Q14. Hourly order distribution — peak ordering hours.
SELECT HOUR(order_time) AS order_hour,
       COUNT(*) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_count DESC;

-- Q15. Top 10 restaurants by total revenue.
SELECT r.restaurant_name, r.city, r.cuisine_type,
       COUNT(o.order_id)              AS total_orders,
       ROUND(SUM(o.total_amount), 2)  AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine_type
ORDER BY total_revenue DESC
LIMIT 10;

-- Q16. Average food rating and delivery rating per city.
SELECT r.city,
       ROUND(AVG(rv.food_rating), 2)     AS avg_food_rating,
       ROUND(AVG(rv.delivery_rating), 2) AS avg_delivery_rating,
       COUNT(rv.review_id)               AS review_count
FROM reviews rv
JOIN restaurants r ON rv.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY avg_food_rating DESC;

-- Q17. Order cancellation rate by city.
SELECT r.city,
       COUNT(o.order_id) AS total_orders,
       SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
       ROUND(
           SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0
           / COUNT(o.order_id), 2
       ) AS cancellation_rate_pct
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY cancellation_rate_pct DESC;

-- Q18. Average delivery time by vehicle type.
SELECT da.vehicle_type,
       COUNT(d.delivery_id)              AS deliveries,
       ROUND(AVG(d.actual_time_min), 1)  AS avg_delivery_min,
       ROUND(AVG(d.distance_km), 1)      AS avg_distance_km
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.agent_id
GROUP BY da.vehicle_type
ORDER BY avg_delivery_min;

-- Q19. Restaurants with average food rating below 3.0 (needs attention).
SELECT r.restaurant_name, r.city, r.cuisine_type,
       ROUND(AVG(rv.food_rating), 2)  AS avg_food_rating,
       COUNT(rv.review_id)            AS review_count
FROM reviews rv
JOIN restaurants r ON rv.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine_type
HAVING avg_food_rating < 3.0
ORDER BY avg_food_rating;

-- Q20. Monthly order and revenue trend.
SELECT DATE_FORMAT(order_time, '%Y-%m')    AS year_month,
       COUNT(order_id)                      AS orders_placed,
       ROUND(SUM(total_amount), 2)          AS monthly_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY year_month
ORDER BY year_month;

-- Q21. Revenue by membership tier.
SELECT c.membership_tier,
       COUNT(DISTINCT c.customer_id)         AS customers,
       COUNT(o.order_id)                     AS total_orders,
       ROUND(SUM(o.total_amount), 2)         AS total_revenue,
       ROUND(AVG(o.total_amount), 2)         AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.membership_tier
ORDER BY total_revenue DESC;

-- Q22. Top 10 most ordered menu items.
SELECT mi.item_name, mi.cuisine_type, mi.price,
       SUM(oi.quantity)              AS total_units_ordered,
       ROUND(SUM(oi.line_total), 2)  AS total_revenue
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
GROUP BY mi.item_id, mi.item_name, mi.cuisine_type, mi.price
ORDER BY total_units_ordered DESC
LIMIT 10;

-- Q23. Delivery agents with more than 500 deliveries in the data.
SELECT da.agent_name, da.city, da.vehicle_type, da.avg_rating,
       COUNT(d.delivery_id) AS deliveries_in_db
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.agent_id
GROUP BY da.agent_id, da.agent_name, da.city, da.vehicle_type, da.avg_rating
HAVING deliveries_in_db > 500
ORDER BY deliveries_in_db DESC;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 3 — JOINS
-- ────────────────────────────────────────────────────────────

-- Q24. Full order detail: customer + restaurant + order.
SELECT c.customer_name, c.membership_tier, c.city AS customer_city,
       r.restaurant_name, r.cuisine_type,
       o.order_id, o.order_time, o.order_status, o.total_amount
FROM orders o
JOIN customers c    ON o.customer_id    = c.customer_id
JOIN restaurants r  ON o.restaurant_id  = r.restaurant_id
ORDER BY o.order_time DESC
LIMIT 50;

-- Q25. Customer name + what they ordered + which restaurant.
SELECT c.customer_name, r.restaurant_name, mi.item_name,
       oi.quantity, oi.line_total, o.order_status
FROM order_items oi
JOIN orders o       ON oi.order_id       = o.order_id
JOIN customers c    ON o.customer_id     = c.customer_id
JOIN restaurants r  ON oi.restaurant_id  = r.restaurant_id
JOIN menu_items mi  ON oi.item_id        = mi.item_id
ORDER BY o.order_time DESC
LIMIT 60;

-- Q26. Delivery performance: agent name, order, restaurant, delivery status.
SELECT da.agent_name, da.vehicle_type,
       r.restaurant_name, r.city,
       d.actual_time_min, d.promised_time_min, d.delivery_status,
       d.distance_km, d.agent_tip
FROM deliveries d
JOIN delivery_agents da ON d.agent_id      = da.agent_id
JOIN orders o           ON d.order_id       = o.order_id
JOIN restaurants r      ON o.restaurant_id  = r.restaurant_id
ORDER BY d.actual_time_min DESC
LIMIT 50;

-- Q27. Customers who have never placed a single order (LEFT JOIN).
SELECT c.customer_id, c.customer_name, c.city, c.membership_tier, c.signup_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q28. Restaurants that have never received a review.
SELECT r.restaurant_id, r.restaurant_name, r.city, r.cuisine_type
FROM restaurants r
LEFT JOIN reviews rv ON r.restaurant_id = rv.restaurant_id
WHERE rv.review_id IS NULL;

-- Q29. Agents who have never had a 'Very Late' delivery.
SELECT da.agent_id, da.agent_name, da.city, da.vehicle_type, da.avg_rating
FROM delivery_agents da
WHERE da.agent_id NOT IN (
    SELECT DISTINCT agent_id
    FROM deliveries
    WHERE delivery_status = 'Very Late'
)
AND da.is_active = 1
ORDER BY da.avg_rating DESC;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 4 — CASE WHEN
-- ────────────────────────────────────────────────────────────

-- Q30. Classify customers by total lifetime spend.
SELECT c.customer_name, c.membership_tier,
       ROUND(SUM(o.total_amount), 2) AS lifetime_spend,
       CASE
           WHEN SUM(o.total_amount) >= 20000 THEN 'Champion'
           WHEN SUM(o.total_amount) >= 8000  THEN 'Loyal'
           WHEN SUM(o.total_amount) >= 2000  THEN 'Regular'
           ELSE                                   'Occasional'
       END AS customer_value_tier
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.membership_tier
ORDER BY lifetime_spend DESC;

-- Q31. Classify menu items by profit margin.
SELECT item_name, cuisine_type, price, cost_price,
       ROUND((price - cost_price) * 100.0 / price, 1) AS margin_pct,
       CASE
           WHEN (price - cost_price) * 100.0 / price >= 60 THEN 'High Margin'
           WHEN (price - cost_price) * 100.0 / price >= 35 THEN 'Mid Margin'
           ELSE                                                   'Low Margin'
       END AS margin_tier
FROM menu_items
ORDER BY margin_pct DESC;

-- Q32. Tag each delivery as Fast / Normal / Slow.
SELECT d.delivery_id, da.agent_name, d.actual_time_min,
       CASE
           WHEN d.actual_time_min <= 25 THEN 'Fast'
           WHEN d.actual_time_min <= 45 THEN 'Normal'
           ELSE                               'Slow'
       END AS speed_tag
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.agent_id
ORDER BY d.actual_time_min;

-- Q33. Pivot: count of delivery statuses per city (single row per city).
SELECT r.city,
       SUM(CASE WHEN d.delivery_status = 'On Time'  THEN 1 ELSE 0 END) AS on_time,
       SUM(CASE WHEN d.delivery_status = 'Late'      THEN 1 ELSE 0 END) AS late,
       SUM(CASE WHEN d.delivery_status = 'Very Late' THEN 1 ELSE 0 END) AS very_late,
       COUNT(d.delivery_id)                                              AS total
FROM deliveries d
JOIN orders o      ON d.order_id      = o.order_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY total DESC;

-- Q34. Classify restaurants by average prep time.
SELECT restaurant_name, cuisine_type, city, avg_prep_time_min,
       CASE
           WHEN avg_prep_time_min <= 15 THEN 'Quick'
           WHEN avg_prep_time_min <= 30 THEN 'Standard'
           ELSE                               'Slow Kitchen'
       END AS prep_speed
FROM restaurants
ORDER BY avg_prep_time_min;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 5 — SUBQUERIES
-- ────────────────────────────────────────────────────────────

-- Q35. Customers who spent above the average customer lifetime spend.
SELECT c.customer_name, c.membership_tier, c.city,
       ROUND(SUM(o.total_amount), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.membership_tier, c.city
HAVING total_spent > (
    SELECT AVG(cust_total) FROM (
        SELECT SUM(total_amount) AS cust_total
        FROM orders
        WHERE order_status = 'Delivered'
        GROUP BY customer_id
    ) sub
)
ORDER BY total_spent DESC;

-- Q36. Top 5 restaurants by average order value.
SELECT restaurant_name, city, cuisine_type, avg_order_value
FROM (
    SELECT r.restaurant_id, r.restaurant_name, r.city, r.cuisine_type,
           ROUND(AVG(o.total_amount), 2) AS avg_order_value
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.order_status = 'Delivered'
    GROUP BY r.restaurant_id, r.restaurant_name, r.city, r.cuisine_type
) sub
ORDER BY avg_order_value DESC
LIMIT 5;

-- Q37. Agents whose average delivery time is below the overall average.
SELECT da.agent_name, da.city, da.vehicle_type,
       ROUND(AVG(d.actual_time_min), 1) AS avg_delivery_min
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.agent_id
GROUP BY da.agent_id, da.agent_name, da.city, da.vehicle_type
HAVING avg_delivery_min < (
    SELECT AVG(actual_time_min) FROM deliveries
)
ORDER BY avg_delivery_min;

-- Q38. Promo codes that generated above-average discount savings.
SELECT promo_code,
       COUNT(*) AS times_used,
       ROUND(SUM(discount_applied), 2) AS total_savings
FROM orders
WHERE promo_code IS NOT NULL
GROUP BY promo_code
HAVING total_savings > (
    SELECT AVG(promo_total)
    FROM (
        SELECT SUM(discount_applied) AS promo_total
        FROM orders
        WHERE promo_code IS NOT NULL
        GROUP BY promo_code
    ) sub
)
ORDER BY total_savings DESC;

-- Q39. Menu items that are ordered more than the average item.
SELECT mi.item_name, mi.cuisine_type, mi.price, total_orders
FROM (
    SELECT item_id, SUM(quantity) AS total_orders
    FROM order_items
    GROUP BY item_id
) item_orders
JOIN menu_items mi ON item_orders.item_id = mi.item_id
WHERE total_orders > (
    SELECT AVG(qty_total)
    FROM (SELECT SUM(quantity) AS qty_total FROM order_items GROUP BY item_id) sub
)
ORDER BY total_orders DESC;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 6 — DATE & TIME FUNCTIONS
-- ────────────────────────────────────────────────────────────

-- Q40. Year-wise revenue and order count.
SELECT YEAR(order_time)                    AS order_year,
       COUNT(order_id)                     AS total_orders,
       ROUND(SUM(total_amount), 2)         AS annual_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY order_year
ORDER BY order_year;

-- Q41. Which day of the week has the highest average order value?
SELECT DAYNAME(order_time)                 AS day_name,
       COUNT(*)                            AS orders,
       ROUND(AVG(total_amount), 2)         AS avg_order_value
FROM orders
WHERE order_status = 'Delivered'
GROUP BY day_name
ORDER BY avg_order_value DESC;

-- Q42. Quarter-wise cancellation rate.
SELECT YEAR(order_time) AS yr, QUARTER(order_time) AS qtr,
       COUNT(*) AS total,
       SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END) AS cancelled,
       ROUND(SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END)*100.0/COUNT(*),2)
           AS cancel_rate_pct
FROM orders
GROUP BY yr, qtr
ORDER BY yr, qtr;

-- Q43. Average time gap (hours) between order placed and review submitted.
SELECT ROUND(AVG(TIMESTAMPDIFF(HOUR, o.order_time, rv.review_time)), 1)
           AS avg_hours_to_review
FROM reviews rv
JOIN orders o ON rv.order_id = o.order_id;

-- Q44. Restaurants registered in 2024 and their current avg rating.
SELECT restaurant_name, city, cuisine_type, registered_date, avg_rating
FROM restaurants
WHERE YEAR(registered_date) = 2024
ORDER BY avg_rating DESC;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 7 — WINDOW FUNCTIONS
-- ────────────────────────────────────────────────────────────

-- Q45. Rank customers by total spend (RANK).
SELECT c.customer_name, c.membership_tier, c.city,
       ROUND(SUM(o.total_amount), 2) AS total_spent,
       RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.membership_tier, c.city
ORDER BY spend_rank
LIMIT 20;

-- Q46. Rank restaurants within each city by revenue (DENSE_RANK).
SELECT city, restaurant_name, cuisine_type, total_revenue,
       DENSE_RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS city_rank
FROM (
    SELECT r.city, r.restaurant_name, r.cuisine_type,
           ROUND(SUM(o.total_amount), 2) AS total_revenue
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.order_status = 'Delivered'
    GROUP BY r.city, r.restaurant_id, r.restaurant_name, r.cuisine_type
) sub
ORDER BY city, city_rank;

-- Q47. Running cumulative revenue by month.
SELECT year_month, monthly_revenue,
       SUM(monthly_revenue) OVER (ORDER BY year_month) AS cumulative_revenue
FROM (
    SELECT DATE_FORMAT(order_time, '%Y-%m')  AS year_month,
           ROUND(SUM(total_amount), 2)        AS monthly_revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY year_month
) monthly
ORDER BY year_month;

-- Q48. Month-over-month revenue growth % using LAG.
SELECT year_month, monthly_revenue,
       LAG(monthly_revenue) OVER (ORDER BY year_month) AS prev_month,
       ROUND(
           (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY year_month))
           * 100.0
           / NULLIF(LAG(monthly_revenue) OVER (ORDER BY year_month), 0)
       , 2) AS mom_growth_pct
FROM (
    SELECT DATE_FORMAT(order_time, '%Y-%m') AS year_month,
           ROUND(SUM(total_amount), 2)       AS monthly_revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY year_month
) m;

-- Q49. Top 3 customers per city by lifetime spend (ROW_NUMBER).
SELECT *
FROM (
    SELECT c.city, c.customer_name, c.membership_tier,
           ROUND(SUM(o.total_amount), 2) AS lifetime_spend,
           ROW_NUMBER() OVER (
               PARTITION BY c.city
               ORDER BY SUM(o.total_amount) DESC
           ) AS city_rank
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.city, c.customer_id, c.customer_name, c.membership_tier
) ranked
WHERE city_rank <= 3
ORDER BY city, city_rank;

-- Q50. Each agent's delivery count vs. city average (OVER PARTITION).
SELECT agent_name, city, vehicle_type, agent_deliveries,
       ROUND(AVG(agent_deliveries) OVER (PARTITION BY city), 1) AS city_avg_deliveries,
       ROUND(agent_deliveries - AVG(agent_deliveries) OVER (PARTITION BY city), 1) AS vs_city_avg
FROM (
    SELECT da.agent_id, da.agent_name, da.city, da.vehicle_type,
           COUNT(d.delivery_id) AS agent_deliveries
    FROM deliveries d
    JOIN delivery_agents da ON d.agent_id = da.agent_id
    GROUP BY da.agent_id, da.agent_name, da.city, da.vehicle_type
) agent_stats
ORDER BY city, agent_deliveries DESC;

-- Q51. Running average food rating per restaurant over time (ROWS UNBOUNDED).
SELECT rv.restaurant_id,
       r.restaurant_name,
       rv.review_time,
       rv.food_rating,
       ROUND(
           AVG(rv.food_rating) OVER (
               PARTITION BY rv.restaurant_id
               ORDER BY rv.review_time
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ), 2
       ) AS running_avg_food_rating
FROM reviews rv
JOIN restaurants r ON rv.restaurant_id = r.restaurant_id
ORDER BY rv.restaurant_id, rv.review_time
LIMIT 100;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 8 — CTEs
-- ────────────────────────────────────────────────────────────

-- Q52. CTE: High-value customers and their favourite cuisine.
WITH customer_spend AS (
    SELECT o.customer_id,
           ROUND(SUM(o.total_amount), 2) AS total_spent
    FROM orders o
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
    HAVING total_spent >= 10000
),
fav_cuisine AS (
    SELECT o.customer_id,
           r.cuisine_type,
           COUNT(*) AS order_count,
           ROW_NUMBER() OVER (
               PARTITION BY o.customer_id
               ORDER BY COUNT(*) DESC
           ) AS rn
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id, r.cuisine_type
)
SELECT c.customer_name, c.membership_tier, c.city,
       cs.total_spent,
       fc.cuisine_type AS favourite_cuisine
FROM customer_spend cs
JOIN customers c     ON cs.customer_id = c.customer_id
JOIN fav_cuisine fc  ON cs.customer_id = fc.customer_id AND fc.rn = 1
ORDER BY cs.total_spent DESC;

-- Q53. CTE: Identify the best and worst delivery agent per city.
WITH agent_stats AS (
    SELECT da.city, da.agent_id, da.agent_name, da.vehicle_type,
           COUNT(d.delivery_id)              AS total_deliveries,
           ROUND(AVG(d.actual_time_min), 1)  AS avg_time,
           ROUND(AVG(d.agent_tip), 2)        AS avg_tip,
           SUM(CASE WHEN d.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0
               / NULLIF(COUNT(*), 0)         AS on_time_rate
    FROM deliveries d
    JOIN delivery_agents da ON d.agent_id = da.agent_id
    GROUP BY da.city, da.agent_id, da.agent_name, da.vehicle_type
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY on_time_rate DESC) AS best_rank,
           RANK() OVER (PARTITION BY city ORDER BY on_time_rate ASC)  AS worst_rank
    FROM agent_stats
)
SELECT city, agent_name, vehicle_type, total_deliveries,
       avg_time, ROUND(on_time_rate, 1) AS on_time_pct,
       CASE WHEN best_rank  = 1 THEN 'Best in City'
            WHEN worst_rank = 1 THEN 'Needs Improvement'
            ELSE 'Average'
       END AS performance_label
FROM ranked
WHERE best_rank = 1 OR worst_rank = 1
ORDER BY city;

-- Q54. CTE: Restaurants with declining ratings (avg this year < avg last year).
WITH yearly_ratings AS (
    SELECT rv.restaurant_id,
           YEAR(rv.review_time)          AS yr,
           ROUND(AVG(rv.food_rating), 2) AS avg_rating
    FROM reviews rv
    GROUP BY rv.restaurant_id, yr
),
compared AS (
    SELECT a.restaurant_id,
           a.avg_rating AS rating_2024,
           b.avg_rating AS rating_2025
    FROM yearly_ratings a
    JOIN yearly_ratings b ON a.restaurant_id = b.restaurant_id
                          AND a.yr = 2024 AND b.yr = 2025
)
SELECT r.restaurant_name, r.city, r.cuisine_type,
       c.rating_2024, c.rating_2025,
       ROUND(c.rating_2025 - c.rating_2024, 2) AS rating_change
FROM compared c
JOIN restaurants r ON c.restaurant_id = r.restaurant_id
WHERE c.rating_2025 < c.rating_2024
ORDER BY rating_change;


-- ────────────────────────────────────────────────────────────
-- ★ SECTION 9 — BUSINESS KPI DASHBOARD
-- ────────────────────────────────────────────────────────────

-- Q55. On-time delivery rate overall and by city.
SELECT r.city,
       COUNT(d.delivery_id) AS total_deliveries,
       ROUND(
           SUM(CASE WHEN d.delivery_status = 'On Time' THEN 1 ELSE 0 END) * 100.0
           / COUNT(d.delivery_id), 2
       ) AS on_time_rate_pct
FROM deliveries d
JOIN orders o      ON d.order_id      = o.order_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY on_time_rate_pct DESC;

-- Q56. Average revenue per customer by membership tier and city.
SELECT c.membership_tier, c.city,
       COUNT(DISTINCT c.customer_id)        AS customers,
       ROUND(AVG(cust_total.total), 2)      AS avg_revenue_per_customer
FROM customers c
JOIN (
    SELECT customer_id, SUM(total_amount) AS total
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
) cust_total ON c.customer_id = cust_total.customer_id
GROUP BY c.membership_tier, c.city
ORDER BY avg_revenue_per_customer DESC;

-- Q57. Promo code effectiveness: usage, savings, and revenue lost.
SELECT promo_code,
       COUNT(*)                           AS times_used,
       ROUND(SUM(discount_applied), 2)   AS total_discount_given,
       ROUND(SUM(total_amount), 2)        AS revenue_after_discount,
       ROUND(SUM(subtotal), 2)            AS revenue_before_discount
FROM orders
WHERE promo_code IS NOT NULL
  AND order_status = 'Delivered'
GROUP BY promo_code
ORDER BY total_discount_given DESC;

-- Q58. Agent tip analysis: which vehicle type earns more tips?
SELECT da.vehicle_type,
       COUNT(d.delivery_id)          AS deliveries,
       ROUND(SUM(d.agent_tip), 2)    AS total_tips,
       ROUND(AVG(d.agent_tip), 2)    AS avg_tip,
       ROUND(MAX(d.agent_tip), 2)    AS max_tip
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.agent_id
GROUP BY da.vehicle_type
ORDER BY avg_tip DESC;

-- Q59. Repeat customer rate — customers who ordered more than once.
SELECT
    COUNT(DISTINCT customer_id)                                             AS total_customers_ordered,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)                      AS repeat_customers,
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(DISTINCT customer_id), 2
    )                                                                       AS repeat_rate_pct
FROM (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
) cust_orders;

-- Q60. Full platform health snapshot (single-row KPI summary).
SELECT
    (SELECT COUNT(*) FROM customers)                                 AS total_customers,
    (SELECT COUNT(*) FROM restaurants)                               AS total_restaurants,
    (SELECT COUNT(*) FROM delivery_agents WHERE is_active=1)         AS active_agents,
    (SELECT COUNT(*) FROM orders)                                    AS total_orders,
    (SELECT ROUND(SUM(total_amount),2) FROM orders
     WHERE order_status='Delivered')                                 AS total_revenue,
    (SELECT ROUND(AVG(total_amount),2) FROM orders
     WHERE order_status='Delivered')                                 AS avg_order_value,
    (SELECT ROUND(AVG(actual_time_min),1) FROM deliveries)           AS avg_delivery_min,
    (SELECT ROUND(AVG(food_rating),2) FROM reviews)                  AS platform_food_rating,
    (SELECT ROUND(
        SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END)*100.0
        /COUNT(*), 2) FROM orders)                                   AS cancellation_rate_pct,
    (SELECT ROUND(
        SUM(CASE WHEN delivery_status='On Time' THEN 1 ELSE 0 END)*100.0
        /COUNT(*), 2) FROM deliveries)                               AS on_time_rate_pct;

-- ============================================================
-- END OF PRACTICE QUESTIONS
-- ============================================================

