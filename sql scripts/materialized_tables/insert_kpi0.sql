INSERT INTO traffic_city_yearly_mat
SELECT
    YEAR(tm.timestamp) AS year,
    CAST(AVG(tm.vehicle_count) AS DECIMAL(12,2)) AS avg_vehicle_count_city
FROM trafficmeasurement tm
WHERE tm.timestamp >= '2012-01-01'
  AND tm.timestamp <  '2026-01-01'
GROUP BY YEAR(tm.timestamp);
