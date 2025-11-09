-- 6. Ratings Fluctuation: Track average customer rating month-by-month. Which months saw the sharpest drop?
WITH monthly_ratings AS(
	SELECT
		DATE_TRUNC('month', o.order_timestamp) AS Month,
		ROUND(AVG(r.rating):: NUMERIC, 2) AS avg_rating,
		COUNT(*) AS Total_ratings
	FROM fact_orders o
	JOIN fact_ratings r ON o.order_id = r.order_id
	GROUP BY 1
),
rating_changes AS(
	SELECT
		Month,
		avg_rating,
		LAG(avg_rating) OVER(ORDER BY Month) AS prev_month_rating,
		ROUND((avg_rating - LAG(avg_rating) OVER(ORDER BY Month)) :: NUMERIC, 2) AS rating_change
	FROM monthly_ratings
)
SELECT *
FROM rating_changes
ORDER BY rating_change
LIMIT 5;

'''
📉 June 2025: Sharpest Drop (-1.91)
- Ratings plummeted from 4.49 to 2.58.
- This coincides with the start of the crisis period, suggesting:
- Delivery delays
- Service disruptions
- Customer frustration
📉 April 2025: Moderate Drop (-0.45)
- Possibly early signs of operational strain or seasonal demand spikes.
📉 August & September 2025: Continued Decline
- Ratings stayed low and dropped further, indicating sustained customer dissatisfaction during the crisis.
📉 February 2025: Minor Dip
- Could be due to post-holiday fatigue or weather-related delays.
🧠 Business Implications
- June marks a critical turning point in customer sentiment.
- You may want to:
- Investigate operational issues in June (e.g., staffing, delivery times, cancellations).
- Cross-reference with SLA compliance and cancellation spikes.
- Flag this period for stakeholder review or recovery campaigns.
'''