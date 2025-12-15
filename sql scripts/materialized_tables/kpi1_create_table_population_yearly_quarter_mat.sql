CREATE TABLE population_yearly_quarter_mat (
    year INT NOT NULL,
    city_district VARCHAR(100) NOT NULL,
    statistical_quarter VARCHAR(100) NOT NULL,
    population_total INT NOT NULL,
    PRIMARY KEY (year, city_district, statistical_quarter)
);
