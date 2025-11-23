USE traffic_population_zh;

CREATE TABLE TrafficSignal (
    signal_id        INT PRIMARY KEY,
    signal_name      VARCHAR(255)
);

CREATE TABLE CountingSite (
    counting_site_id      VARCHAR(50) PRIMARY KEY,
    counting_site_name    VARCHAR(255),
    axis                  VARCHAR(255),
    east_coordinate       FLOAT,
    north_coordinate      FLOAT,
    signal_id             INT,
    FOREIGN KEY (signal_id) REFERENCES TrafficSignal(signal_id)
);

CREATE TABLE MeasurementSite (
    measurement_site_id     VARCHAR(50) PRIMARY KEY,
    measurement_site_name   VARCHAR(255),
    direction               VARCHAR(50),
    position_description    VARCHAR(255),
    num_detectors           INT,
    counting_site_id        VARCHAR(50),
    FOREIGN KEY (counting_site_id) REFERENCES CountingSite(counting_site_id)
);

CREATE TABLE TrafficMeasurement (
    traffic_measurement_id   INT AUTO_INCREMENT PRIMARY KEY,
    measurement_site_id      VARCHAR(50),
    timestamp                DATETIME,
    vehicle_count            INT,
    vehicle_count_status     VARCHAR(50),
    FOREIGN KEY (measurement_site_id) REFERENCES MeasurementSite(measurement_site_id)
);
