CREATE OR REPLACE VIEW v_kpi2_bottlenecks AS
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
    FROM traffic_hourly_site_mat
) peak
JOIN countingsite cs
    ON peak.counting_site_id = cs.counting_site_id
WHERE peak.rn = 1
ORDER BY peak.avg_volume DESC;
