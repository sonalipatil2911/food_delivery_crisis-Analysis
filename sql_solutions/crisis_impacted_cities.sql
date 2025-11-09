-- 2. Which top 5 city groups experienced the highest percentage decline in orders
-- during the crisis period compared to the pre-crisis period?

WITH orders_by_city_period AS(
	SELECT
		c.city,
		CASE
			WHEN o.order_timestamp BETWEEN '2025-01-01' AND '2025-05-31' THEN 'Pre_crisis'
			WHEN o.order_timestamp BETWEEN '2025-06-01' AND '2025-09-30' THEN 'Crisis'
			ELSE NULL
		END AS period,
		COUNT(*) AS order_count
	FROM fact_orders o
	JOIN dim_customer c ON o.customer_id = c.customer_id
	WHERE o.order_timestamp BETWEEN '2025-01-01' AND '2025-09-30'
	GROUP BY 1, 2
),
pivoted AS(
	SELECT
		city,
		MAX(CASE WHEN period = 'Pre_crisis' THEN order_count ELSE 0 END) AS pre_crisis_orders,
		MAX(CASE WHEN period = 'Crisis' THEN order_count ELSE 0 END) AS crisis_orders
	FROM orders_by_city_period
	GROUP BY 1
),
with_decline AS(
	SELECT 
		city,
		pre_crisis_orders,
		crisis_orders,
		ROUND(
			CASE 
				WHEN pre_crisis_orders = 0 THEN NULL
				ELSE 100.0 * (pre_crisis_orders - crisis_orders) / pre_crisis_orders
			END, 2
			) AS percent_decline
		FROM pivoted
)
SELECT * FROM with_decline
ORDER BY percent_decline DESC -- NULLs LAST
LIMIT 5;

