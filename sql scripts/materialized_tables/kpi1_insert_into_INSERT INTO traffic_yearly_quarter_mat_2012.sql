INSERT INTO traffic_yearly_quarter_mat
SELECT
    year,
    city_district,
    statistical_quarter,
    COALESCE(SUM(yearly_vehicle_count), 0) AS vehicle_total
FROM v_traffic_yearly
WHERE year = 2012
GROUP BY year, city_district, statistical_quarter;
