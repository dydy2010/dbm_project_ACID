CREATE TABLE traffic_hourly_site_mat (
    counting_site_id VARCHAR(10) NOT NULL,
    hour INT NOT NULL,
    avg_volume DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (counting_site_id, hour)
);
