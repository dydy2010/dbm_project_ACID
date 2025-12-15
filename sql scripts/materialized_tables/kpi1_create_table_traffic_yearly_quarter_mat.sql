CREATE TABLE traffic_yearly_quarter_mat (
    year INT NOT NULL,
    city_district VARCHAR(100) NOT NULL,
    statistical_quarter VARCHAR(100) NOT NULL,
    vehicle_total BIGINT NOT NULL,
    PRIMARY KEY (year, city_district, statistical_quarter)
);
