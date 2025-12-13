-- OPTIMIZED VERSION: Adds WHERE clause to limit the scan range and let the
-- timestamp index work when computing the city-level yearly traffic average.

CREATE OR REPLACE VIEW v_traffic_city_yearly AS
SELECT
    year,
    AVG(site_avg) AS avg_vehicle_count_city
FROM (
    SELECT
        cs.counting_site_id,
        YEAR(tm.timestamp) AS year,
        AVG(tm.vehicle_count) AS site_avg
    FROM trafficmeasurement tm
    JOIN measurementsite ms 
        ON tm.measurement_site_id = ms.measurement_site_id
    JOIN countingsite cs
        ON ms.counting_site_id = cs.counting_site_id
    WHERE tm.timestamp >= '2012-01-01'
      AND tm.timestamp < '2026-01-01'
    GROUP BY cs.counting_site_id, YEAR(tm.timestamp)
) s
GROUP BY year
ORDER BY year;
