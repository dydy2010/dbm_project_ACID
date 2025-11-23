INSERT INTO MeasurementSite (
    measurement_site_id,
    measurement_site_name,
    direction,
    position_description,
    num_detectors,
    counting_site_id
)
SELECT
    measurement_site_id,

    -- deterministic name per measurement site
    MIN(measurement_site_name) AS measurement_site_name,

    -- choose one stable direction (e.g. "outbound")
    MIN(direction) AS direction,

    -- choose consistent position description
    MIN(position_description) AS position_description,

    -- numeric: pick smallest valid detector count
    MIN(CAST(num_detectors AS UNSIGNED)) AS num_detectors,

    -- foreign key to CountingSite
    MIN(counting_site_id) AS counting_site_id

FROM stg_traffic_data

-- ensures exactly one record per measurement_site_id
GROUP BY measurement_site_id;
