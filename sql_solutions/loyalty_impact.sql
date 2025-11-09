-- 9. Loyalty Impact: Among customers who placed five or more orders before the 
-- crisis, determine how many stopped ordering during the crisis, and out of those, 
-- how many had an average rating above 4.5?

WITH pre_crisis_customers AS(
	SELECT customer_id
	FROM orders
	WHERE period = 'Pre-Crisis'
	GROUP BY 1
	HAVING COUNT(*) >= 5
),
crisis_orders AS(
	SELECT customer_id
	FROM orders
	WHERE period = 'Crisis'
	GROUP BY 1
),
churned_customers AS(
	SELECT
		pc.customer_id
	FROM pre_crisis_customers pc
	LEFT JOIN crisis_orders co ON pc.customer_id = co.customer_id
	WHERE co.customer_id IS NULL
	-- - After the LEFT JOIN, if a customer from pre_crisis_customers did not place any crisis-period orders, then co.customer_id will be NULL.
    -- So this condition filters for customers who stopped ordering during the crisis.

),
ratings_above_4 AS(
	SELECT customer_id
	FROM fact_ratings
	GROUP BY 1
	HAVING AVG(rating) > 4.5
)
SELECT
	COUNT(*) AS Total_churned_customers,
	COUNT(*) FILTER (WHERE cc.customer_id IN (SELECT customer_id FROM ratings_above_4)) AS high_rating_churned_customers
FROM churned_customers cc;

'''
- total_churned_customers: Customers who were loyal before the crisis but stopped ordering during it.
- high_rating_churned_customers: Of those, how many were highly satisfied (avg rating > 4.5).
'''