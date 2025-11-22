USE traffic_population_zh;

CREATE TABLE Sex (
    sex_code INT PRIMARY KEY,
    sex VARCHAR(50)
);

CREATE TABLE Origin (
    origin_code INT PRIMARY KEY,
    origin VARCHAR(100)
);


CREATE TABLE Population (
    population_id INT PRIMARY KEY,
    reference_date_year INT,
    sex_code INT,
    origin_code INT,
    city_district INT,
    statistical_quarter VARCHAR(100),
    population_count INT,
    FOREIGN KEY (sex_code) REFERENCES Sex(sex_code),
    FOREIGN KEY (origin_code) REFERENCES Origin(origin_code)
);


CREATE TABLE Quarter (
    street_name VARCHAR(100) PRIMARY KEY,
    city_district INT,
    statistical_quarter INT
);

CREATE TABLE CountingSite (
    counting_site_id VARCHAR(50) PRIMARY KEY,
    counting_site_name VARCHAR(100),
    axis VARCHAR(100),
    east_coordinate FLOAT,
    north_coordinate FLOAT,
    signal_id VARCHAR(50)
);

CREATE TABLE MeasurementSite (
    measurement_site_id VARCHAR(50) PRIMARY KEY,
    measurement_site_name VARCHAR(100),
    direction VARCHAR(50),
    position_description VARCHAR(200),
    num_detectors INT,
    counting_site_id VARCHAR(50),
    FOREIGN KEY (counting_site_id) REFERENCES CountingSite(counting_site_id)
);

CREATE TABLE TrafficSignal (
    signal_id VARCHAR(50) PRIMARY KEY,
    signal_name VARCHAR(100)
);

CREATE TABLE TrafficMeasurement (
    measurement_id INT PRIMARY KEY,
    timestamp DATETIME,
    vehicle_count INT,
    vehicle_count_status VARCHAR(50),
    measurement_site_id VARCHAR(50),
    FOREIGN KEY (measurement_site_id) REFERENCES MeasurementSite(measurement_site_id)
);

-- ALTER TABLE CountingSite
-- ADD FOREIGN KEY (signal_id) REFERENCES TrafficSignal(signal_id);

-- CREATE INDEX idx_population_sex ON Population(sex_code);
-- CREATE INDEX idx_population_origin ON Population(origin_code);
-- CREATE INDEX idx_measurement_timestamp ON TrafficMeasurement(timestamp);
-- CREATE INDEX idx_measurement_site ON TrafficMeasurement(measurement_site_id);
-- CREATE INDEX idx_counting_site_signal ON CountingSite(signal_id);