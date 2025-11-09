-- 8. Revenue Impact: Estimate revenue loss from pre-crisis vs crisis (based on 
-- subtotal, discount, and delivery fee).
SELECT
	period,
	ROUND(SUM(subtotal_amount - discount_amount + delivery_fee):: NUMERIC, 2) AS total_revenue,
	COUNT(*) AS order_count
FROM orders
WHERE period IN ('Pre-Crisis', 'Crisis')
	AND is_cancelled = 'N'
GROUP BY 1
ORDER BY 1 DESC

