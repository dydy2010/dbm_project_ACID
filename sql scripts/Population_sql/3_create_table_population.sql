USE traffic_population_zh;

CREATE TABLE Population (
    reference_date_year     DATETIME,
    sex_code                VARCHAR(50),
    sex                     VARCHAR(50),
    origin_code             VARCHAR(50),
    origin                  VARCHAR(255),
    city_district           INT,
    statistical_quarter     VARCHAR(255),
    population_count        INT
);
