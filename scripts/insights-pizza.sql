--1. Revenue % contribution by category
SELECT
    pizza_category,
    CAST(SUM(total_price) AS DECIMAL(12,2)) AS revenue,
    CAST(
        ROUND(
            100.0 * SUM(total_price) /
            SUM(SUM(total_price)) OVER (),
            2
        ) AS DECIMAL(5,2)
    ) AS revenue_contribution_pct
FROM pizza_sales
GROUP BY pizza_category
ORDER BY revenue DESC;



--2. Revenue contribution by pizza size
 SELECT
    pizza_size,
    SUM(total_price) AS revenue,
    CAST(
        ROUND(
            100.0 * SUM(total_price) /
            SUM(SUM(total_price)) OVER (),
            2
        ) AS DECIMAL(5,2)
    ) AS revenue_contribution_pct
FROM pizza_sales
GROUP BY pizza_size
ORDER BY revenue DESC;



--3. quantity contribution by size.
SELECT
    pizza_size,
    SUM(quantity) AS units_sold,
    CAST(
        ROUND(
              100.0 * SUM(quantity)/
              SUM(SUM(quantity)) OVER(), 2
              ) AS DECIMAL(5,2)
     ) AS quantity_contribution_pct
FROM pizza_sales
GROUP BY pizza_size
ORDER BY units_sold DESC;



--4. Identify the category-size combinations driving revenue engine
SELECT
    pizza_category,
    pizza_size,
    SUM(total_price) AS revenue,
    CAST(
         ROUND(
                100.0 * SUM(total_price) / 
                SUM(SUM(total_price)) OVER(), 2
               ) AS DECIMAL(5, 2)
   ) AS category_size_combo_pct
FROM pizza_sales
GROUP BY pizza_category, pizza_size
ORDER BY revenue DESC;




--5. Find peak operating hours for staffing and inventory planning
SELECT
    DATEPART(HOUR, order_time) AS order_hour,
    COUNT(DISTINCT order_id) AS orders,
    SUM(total_price) AS revenue
FROM pizza_sales
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_hour;



--6. Analyze day-of-week performance
SELECT
    DATENAME(WEEKDAY, order_date) AS day_name,
    COUNT(DISTINCT order_id) AS orders,
    SUM(total_price) AS revenue
FROM pizza_sales
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY CASE DATENAME(WEEKDAY, order_date)
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
END;



--7. Evaluate monthly revenue trends
--Is the business growing, seasonal, or declining?
SELECT
    MONTH(order_date) AS month,
    DATENAME(MONTH, order_date) AS month_name,
    COUNT(DISTINCT order_id) AS orders,
    SUM(total_price) AS revenue
FROM pizza_sales
GROUP BY MONTH(order_date), DATENAME(MONTH, order_date)
ORDER BY month;



--8. top 10 pizzas by revenue and quantity.
SELECT TOP 10
    pizza_name,
    SUM(quantity) AS units_sold,
    SUM(total_price) AS revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY revenue DESC;


--9. Which sizes drive the lunch and dinner peaks?
SELECT
    DATEPART(HOUR, order_time) AS order_hour,
    pizza_size,
    SUM(quantity) AS units_sold,
    SUM(total_price) AS revenue
FROM pizza_sales
WHERE DATEPART(HOUR, order_time) IN (12,18)
GROUP BY DATEPART(HOUR, order_time), pizza_size
ORDER BY order_hour, revenue DESC;


--10. Measure weekend vs weekday AOV (average order value).
SELECT
    CASE
        WHEN DATENAME(WEEKDAY, order_date) IN ('Saturday','Sunday')
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT order_id) AS orders,
    SUM(total_price) AS revenue,
    CAST(
        SUM(total_price) * 1.0 /
        COUNT(DISTINCT order_id)
        AS DECIMAL(10,2)
    ) AS AOV
FROM pizza_sales
GROUP BY CASE
    WHEN DATENAME(WEEKDAY, order_date) IN ('Saturday','Sunday')
        THEN 'Weekend'
    ELSE 'Weekday'
END;




--11. Pareto analysis of revenue concentration
WITH pizza_revenue AS (
    SELECT
        pizza_name,
        SUM(total_price) AS revenue
    FROM pizza_sales
    GROUP BY pizza_name
),
pareto AS (
    SELECT
        pizza_name,
        revenue,
        CAST(
            ROUND(
                100.0 * revenue / SUM(revenue) OVER (),
                2
            ) AS DECIMAL(5,2)
        ) AS revenue_pct,
        CAST(
            ROUND(
                100.0 * SUM(revenue) OVER (
                    ORDER BY revenue DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) / SUM(revenue) OVER (),
                2
            ) AS DECIMAL(5,2)
        ) AS cumulative_revenue_pct
    FROM pizza_revenue
)
SELECT
    pizza_name,
    revenue,
    revenue_pct,
    cumulative_revenue_pct
FROM pareto
ORDER BY revenue DESC;





--12. Estimate revenue concentration risk from top-selling pizzas
WITH pizza_revenue AS (
    SELECT
        pizza_name,
        SUM(total_price) AS revenue
    FROM pizza_sales
    GROUP BY pizza_name
)
SELECT TOP 10
    pizza_name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM pizza_revenue
ORDER BY revenue DESC;