-- OPTIMIZED VERSION: Replaced YEAR(tm.timestamp) with date range (SARGable predicate)
-- This allows the index on timestamp to be used instead of full table scan


WITH ranked_peak AS (
    SELECT
        sth.counting_site_id,
        sth.hour_of_day,
        sth.avg_volume,
        ROW_NUMBER() OVER (
            PARTITION BY sth.counting_site_id
            ORDER BY sth.avg_volume DESC
        ) AS rnCREATE OR REPLACE VIEW v_kpi2_bottlenecks AS
    FROM summary_traffic_hourly sth
)
SELECT
    cs.counting_site_name,
    CONCAT(LPAD(r.hour_of_day, 2, '0'), ':00') AS peak_hour,
    ROUND(r.avg_volume, 0) AS avg_volume,
    CASE
        WHEN r.avg_volume > 700 THEN 'Bottleneck'
        ELSE 'Normal'
    END AS status
FROM ranked_peak r
JOIN countingsite cs 
    ON r.counting_site_id = cs.counting_site_id
WHERE r.rn = 1
ORDER BY r.avg_volume DESC;
