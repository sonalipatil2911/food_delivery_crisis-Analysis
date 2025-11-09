-- 4. Cancellation Analysis: What is the cancellation rate trend pre-crisis vs crisis, 
-- and which cities are most affected?
WITH cancellation_by_city_period AS(
	SELECT 
		c.city,
		CASE
			WHEN o.order_timestamp BETWEEN '2025-01-01' AND '2025-05-31' THEN 'Pre_crisis'
			WHEN o.order_timestamp BETWEEN '2025-06-01' AND '2025-09-30' THEN 'Crisis'
		END AS period,
		COUNT(*) FILTER (WHERE o.is_cancelled = 'Y') AS cancelled_orders,
		COUNT(*) AS total_orders
	FROM fact_orders o
	JOIN dim_customer c ON o.customer_id = c.customer_id
	GROUP BY 1, 2
),
pivoted AS(
	SELECT 
		city,
		MAX(CASE WHEN period = 'Pre_crisis' THEN cancelled_orders ELSE 0 END) AS pre_cancelled,
		MAX(CASE WHEN period = 'Pre_crisis' THEN total_orders ELSE 0 END) AS pre_total_orders,
		MAX(CASE WHEN period = 'Crisis' THEN cancelled_orders ELSE 0 END) AS crisis_cancelled,
		MAX(CASE WHEN period = 'Crisis' THEN total_orders ELSE 0 END) AS crisis_total_orders
	FROM cancellation_by_city_period
	GROUP BY 1
),
with_rates AS(
	SELECT
		city,
		ROUND(100.0 * pre_cancelled / NULLIF(pre_total_orders, 0), 2) AS pre_crisis_rate,
		ROUND(100.0 * crisis_cancelled / NULLIF(crisis_total_orders, 0), 2) AS crisis_rate,
		ROUND(100.0 * crisis_cancelled / NULLIF(crisis_total_orders, 0) - 100.0 * pre_cancelled / NULLIF(pre_total_orders, 0), 2) AS rate_change
	FROM pivoted
)
SELECT *	
FROM with_rates
ORDER BY rate_change DESC NULLS LAST
LIMIT 10;