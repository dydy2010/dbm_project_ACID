INSERT INTO traffic_direction_site_mat
SELECT
    cs.counting_site_name,
    ms.direction,
    COALESCE(SUM(tm.vehicle_count), 0) AS direction_volume
FROM trafficmeasurement tm
JOIN measurementsite ms
    ON tm.measurement_site_id = ms.measurement_site_id
JOIN countingsite cs
    ON ms.counting_site_id = cs.counting_site_id
WHERE tm.timestamp >= '2023-01-01'
  AND tm.timestamp <  '2026-01-01'
GROUP BY cs.counting_site_name, ms.direction;
