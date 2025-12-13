-- ============================================================
-- SUMMARY TABLE FOR KPI2 (Bottlenecks)
-- Run this script to refresh the pre-aggregated hourly averages
-- before recreating the v_kpi2_bottlenecks view.
-- ============================================================

USE traffic_population_zh;

CREATE TABLE IF NOT EXISTS summary_traffic_hourly (
    counting_site_id     VARCHAR(50) NOT NULL,
    hour_of_day          TINYINT     NOT NULL,
    avg_volume           DECIMAL(14,4) NOT NULL,
    PRIMARY KEY (counting_site_id, hour_of_day)
);

TRUNCATE TABLE summary_traffic_hourly;

INSERT INTO summary_traffic_hourly (counting_site_id, hour_of_day, avg_volume)
SELECT
    cs.counting_site_id,
    HOUR(tm.timestamp) AS hour_of_day,
    AVG(tm.vehicle_count) AS avg_volume
FROM trafficmeasurement tm
JOIN measurementsite ms
    ON tm.measurement_site_id = ms.measurement_site_id
JOIN countingsite cs
    ON ms.counting_site_id = cs.counting_site_id
WHERE tm.timestamp >= '2023-01-01'
  AND tm.timestamp < '2026-01-01'
GROUP BY cs.counting_site_id, HOUR(tm.timestamp);
