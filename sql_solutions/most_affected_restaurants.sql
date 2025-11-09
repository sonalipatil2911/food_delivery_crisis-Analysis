
-- 3. Among restaurants with at least 50 pre-crisis orders, which top 10 high-volume 
-- restaurants experienced the largest percentage decline in order counts during the crisis period?

WITH orders_by_restaurant_period AS(
	SELECT
		o.restaurant_id,
		CASE
			WHEN o.order_timestamp BETWEEN '2025-01-01' AND '2025-05-31' THEN 'Pre_crisis'
			WHEN o.order_timestamp BETWEEN '2025-06-01' AND '2025-09-30' THEN 'Crisis'
		END AS period,
		COUNT(*) AS order_count
	FROM fact_orders o
	GROUP BY 1, 2
),
pivoted AS(
	SELECT
		restaurant_id,
		MAX(CASE WHEN period = 'Pre_crisis' THEN order_count ELSE 0 END) AS pre_crisis_orders,
		MAX(CASE WHEN period = 'Crisis' THEN order_count ELSE 0 END) AS crisis_orders
	FROM orders_by_restaurant_period
	GROUP BY 1
),
with_decline AS(
	SELECT
		r.restaurant_id,
		r.restaurant_name,
		p.pre_crisis_orders,
		p.crisis_orders,
		ROUND(
			CASE WHEN pre_crisis_orders = 0 THEN NULL
			ELSE 100.0 * (p.pre_crisis_orders - p.crisis_orders) / p.pre_crisis_orders
			END, 2
		) AS percent_decline		
	FROM pivoted p
	JOIN dim_restaurant r ON p.restaurant_id = r.restaurant_id
	WHERE pre_crisis_orders >= 10
)
SELECT * FROM with_decline
ORDER BY percent_decline DESC NULLs LAST
LIMIT 10;