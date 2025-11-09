-- 7. Sentiment Insights: During the crisis period, identify the most frequently 
-- occurring negative keywords in customer review texts. (Hint: Use a Word Cloud 
-- visual in Power BI to visualize the findings.)
WITH crisis_reviews AS (
  SELECT
    LOWER(review_text) AS review_text
  FROM fact_ratings
  WHERE review_text IS NOT NULL
    AND review_timestamp BETWEEN '2025-06-01' AND '2025-09-30'
),
keyword_counts AS (
  SELECT 'late' AS keyword, COUNT(*) AS frequency
  FROM crisis_reviews WHERE review_text LIKE '%late%'
  UNION ALL
  SELECT 'cold', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%cold%'
  UNION ALL
  SELECT 'rude', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%rude%'
  UNION ALL
  SELECT 'missing', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%missing%'
  UNION ALL
  SELECT 'slow', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%slow%'
  UNION ALL
  SELECT 'bad', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%bad%'
  UNION ALL
  SELECT 'worst', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%worst%'
  UNION ALL
  SELECT 'unhappy', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%unhappy%'
  UNION ALL
  SELECT 'disappointed', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%disappointed%'
  UNION ALL
  SELECT 'delay', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%delay%'
  UNION ALL
  SELECT 'dirty', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%dirty%'
  UNION ALL
  SELECT 'wrong', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%wrong%'
  UNION ALL
  SELECT 'cancelled', COUNT(*) FROM crisis_reviews WHERE review_text LIKE '%cancelled%'
)
SELECT *
FROM keyword_counts
ORDER BY frequency DESC;