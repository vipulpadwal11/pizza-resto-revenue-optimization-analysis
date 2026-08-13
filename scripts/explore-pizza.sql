SELECT * FROM pizza_sales;


--total revenue
SELECT 
    SUM(total_price) AS total_revenue
FROM pizza_sales;


--total orders
SELECT 
    COUNT(DISTINCT(order_id)) AS total_orders
FROM pizza_sales



-- TOP 10
SELECT TOP 10 *
FROM pizza_sales
ORDER BY quantity DESC;

SELECT TOP 10 *
FROM pizza_sales
ORDER BY total_price DESC;


-- Check for NULL values
SELECT
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN order_time IS NULL THEN 1 ELSE 0 END) AS order_time_nulls,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_nulls,
    SUM(CASE WHEN total_price IS NULL THEN 1 ELSE 0 END) AS total_price_nulls,
    SUM(CASE WHEN pizza_size IS NULL THEN 1 ELSE 0 END) AS pizza_size_nulls,
    SUM(CASE WHEN pizza_category IS NULL THEN 1 ELSE 0 END) AS pizza_category_nulls,
    SUM(CASE WHEN pizza_ingredients IS NULL THEN 1 ELSE 0 END) AS pizza_ingredients_nulls,
    SUM(CASE WHEN pizza_name IS NULL THEN 1 ELSE 0 END) AS pizza_name_nulls
FROM pizza_sales;



--explore and know the data
--Order by AOV
SELECT
    pizza_category,
    pizza_size,
    COUNT(*) AS total_rows,
    SUM(quantity) AS total_qauntity,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    MIN(unit_price) AS min_price,
    MAX(unit_price) AS max_price,
    SUM(total_price) AS revenue,
    AVG(total_price) AS avg_item_value
FROM pizza_sales
GROUP BY pizza_category, pizza_size
ORDER BY avg_item_value DESC; --AOV


--Order by revenue
SELECT
    pizza_category,
    pizza_size,
    COUNT(*) AS total_rows,
    SUM(quantity) AS total_qauntity,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    MIN(unit_price) AS min_price,
    MAX(unit_price) AS max_price,
    SUM(total_price) AS revenue,
    AVG(total_price) AS avg_item_value
FROM pizza_sales
GROUP BY pizza_category, pizza_size
ORDER BY revenue DESC; --revenue