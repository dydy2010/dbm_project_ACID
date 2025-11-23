INSERT INTO TrafficMeasurement (
    measurement_site_id,
    timestamp,
    vehicle_count,
    vehicle_count_status
)
SELECT
    measurement_site_id,
    STR_TO_DATE(timestamp, '%Y-%m-%dT%H:%i:%s'),
    ROUND(vehicle_count),
    vehicle_count_status
FROM stg_traffic_data;
