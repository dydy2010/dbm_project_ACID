CREATE TABLE traffic_direction_site_mat (
    counting_site_name VARCHAR(150) NOT NULL,
    direction VARCHAR(50) NOT NULL,
    direction_volume BIGINT NOT NULL,
    PRIMARY KEY (counting_site_name, direction)
);
