-- OPTIMIZED VERSION: Replaced YEAR(tm.timestamp) with date range (SARGable predicate)
-- This allows the index on timestamp to be used instead of full table scan

CREATE VIEW v_kpi2_bottlenecks AS
SELECT
    cs.counting_site_name,
    CONCAT(LPAD(peak.hour, 2, '0'), ':00') AS peak_hour,
    ROUND(peak.avg_volume, 0) AS avg_volume,
    CASE
        WHEN peak.avg_volume > 700 THEN 'Bottleneck'
        ELSE 'Normal'
    END AS status
FROM (
    SELECT
        counting_site_id,
        hour,
        avg_volume,
        ROW_NUMBER() OVER (
            PARTITION BY counting_site_id
            ORDER BY avg_volume DESC
        ) AS rn
    FROM (
        SELECT
            cs.counting_site_id,
            HOUR(tm.timestamp) AS hour,
            AVG(tm.vehicle_count) AS avg_volume
        FROM trafficmeasurement tm
        JOIN measurementsite ms 
            ON tm.measurement_site_id = ms.measurement_site_id
        JOIN countingsite cs
            ON ms.counting_site_id = cs.counting_site_id
        WHERE tm.timestamp >= '2023-01-01' AND tm.timestamp < '2026-01-01'
        GROUP BY cs.counting_site_id, HOUR(tm.timestamp)
    ) hourly_avgs
) peak
JOIN countingsite cs 
    ON peak.counting_site_id = cs.counting_site_id
WHERE peak.rn = 1
ORDER BY peak.avg_volume DESC;
