-- 5. Delivery SLA: Measure average delivery time across phases. Did SLA 
-- compliance worsen significantly in the crisis period?

SELECT
  o.period,
  -- - Average delivery time per phase
  ROUND(AVG(dp.actual_delivery_time_mins), 2) AS avg_delivery_time,

-- - SLA compliance rate (% of orders delivered on time)
  ROUND(100.0 * AVG(
    CASE
      WHEN dp.actual_delivery_time_mins <= dp.expected_delivery_time_mins THEN 1
      ELSE 0
    END
  ), 2) AS sla_compliance_rate,

  --  Total order volume for context
  COUNT(*) AS order_count
FROM orders o
JOIN fact_delivery_performance dp ON o.order_id = dp.order_id
WHERE o.period IN ('Pre-Crisis', 'Crisis')
  AND o.is_cancelled != 'Y'
GROUP BY o.period
ORDER BY o.period DESC;

'''
Average Delivery Time Increased
- From 39.52 mins to 60.14 mins → a jump of over 20 minutes.
- This suggests slower fulfillment, likely due to:
- Fewer available delivery partners
- Higher traffic or logistical disruptions
- Increased order volume or complexity
2. SLA Compliance Dropped Sharply
- From 43.60% to 12.31% → a 71.8% relative drop.
- Indicates that most orders during the crisis were not delivered within the expected time window.
- This could reflect:
- Overpromised delivery estimates
- Operational strain
- Poor partner allocation or routing delays
3. Order Volume Declined
- From 106,255 to 30,906 → a 70.9% drop.
- Fewer orders may reflect:
- Reduced customer demand
- Service disruptions
- Cancellation spikes

🧠 Business Implications
- SLA failure during the crisis could lead to:
- Lower customer satisfaction
- Increased refunds or complaints
- Reputation damage
- You may want to:
- Recalibrate SLA targets
- Improve partner dispatch logic
- Flag high-risk zones or time slots
'''