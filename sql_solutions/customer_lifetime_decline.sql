-- 10.Customer Lifetime Decline: Which high-value customers (top 5% by total 
-- spend before the crisis) showed the largest drop in order frequency and ratings 
-- during the crisis? What common patterns (e.g., location, cuisine preference, 
-- delivery delays) do they share

-- 1. Identify Top 5% Customers by Pre-Crisis Spend
WITH pre_crisis_spend AS(
	SELECT
		customer_id,
		SUM(subtotal_amount - discount_amount + delivery_fee) AS Total_spending
	FROM orders
	WHERE period = 'Pre-Crisis' AND is_cancelled != 'Y'
	GROUP BY 1
),
top_5percent AS(
	SELECT
		customer_id
	FROM pre_crisis_spend
	WHERE Total_spending >= (
		SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_spending)
 FROM pre_crisis_spend
	)
),

-- Compare order frequency and ratings Pre vs Crisis
customer_metrics AS(
	SELECT
		o.customer_id,
		o.period,
		COUNT(*) AS order_count,
		AVG(r.rating) AS avg_rating
	FROM orders o
	JOIN fact_ratings r ON o.order_id = r.order_id
	WHERE o.is_cancelled = 'N'
		AND o.period IN ('Pre-Crisis', 'Crisis')
		AND o.customer_id IN  (SELECT customer_id FROM top_5percent)
	GROUP BY 1, 2
),
pivoted_metrics AS(
	SELECT
		customer_id,
		MAX(CASE WHEN period = 'Pre-Crisis' THEN order_count END) AS Pre_orders,
		MAX(CASE WHEN period = 'Crisis' THEN order_count END) AS crisis_orders,
		MAX(CASE WHEN period = 'Pre-Crisis' THEN avg_rating END) AS Pre_rating,
		MAX(CASE WHEN period = 'Crisis' THEN avg_rating END) AS crisis_rating
	FROM customer_metrics
	GROUP BY 1
)
SELECT 
	c.customer_id,
	COALESCE(pm.pre_orders, 0) - COALESCE(pm.crisis_orders, 0) AS order_drop,
	ROUND((COALESCE(pm.Pre_rating, 0) - COALESCE(pm.crisis_rating, 0))::NUMERIC, 2) AS rating_drop,

--Common Patterns
-- join this result with:
-- dim_customer → to analyze location
-- orders → to extract cuisine preference (via restaurant_id)
-- delivery_performance → to assess delivery delays

    c.city,
    r.cuisine_type,
    AVG(dp.actual_delivery_time_mins - dp.expected_delivery_time_mins) AS avg_delay
FROM pivoted_metrics pm
JOIN dim_customer c ON pm.customer_id = c.customer_id
JOIN orders o ON pm.customer_id = o.customer_id AND o.period = 'Crisis'
JOIN dim_restaurant r ON o.restaurant_id = r.restaurant_id
JOIN fact_delivery_performance dp ON o.order_id = dp.order_id
GROUP BY c.city, r.cuisine_type, c.customer_id, pm.pre_orders, pm.crisis_orders, pm.Pre_rating, pm.crisis_rating
ORDER BY avg_delay DESC;


-- Insights:
-- Which high-value customers dropped off most
-- Whether they were highly satisfied before
-- If they share traits like:
-- Specific cities or regions
-- Preference for certain cuisines
-- Longer delivery delays during crisis
