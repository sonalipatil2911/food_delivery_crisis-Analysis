-- Primary Analysis (Based on Available data):
-- 1. Monthly Orders: Compare total orders across pre-crisis (Jan–May 2025) vs crisis 
--(Jun–Sep 2025). How severe is the decline?

-- Once you have the totals, you can calculate the percentage decline like this:
WITH order_totals AS (
  SELECT 
	period,
	COUNT(order_id) AS Total_orders
  FROM orders
  WHERE period IS NOT NULL 
  	AND order_timestamp BETWEEN '2025-01-01' AND '2025-09-30'
  GROUP BY 1
)
SELECT
  pre.total_orders AS pre_crisis_orders,
  crisis.total_orders AS crisis_orders,
  ROUND(((pre.total_orders - crisis.total_orders) * 100.0 / pre.total_orders)::numeric, 2) AS percent_decline
FROM order_totals pre
JOIN order_totals crisis ON crisis.period = 'Crisis'
WHERE pre.period = 'Pre-Crisis';


-- This tells how severely order volume dropped during the crisis. 
-- A 68.98% decline would signal major operational or customer experience issues.

