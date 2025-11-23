USE traffic_population_zh;

CREATE TABLE stg_population_data (
    reference_date_year      VARCHAR(50),
    sex_code                 VARCHAR(50),
    sex                      VARCHAR(50),
    origin_code              VARCHAR(50),
    origin                   VARCHAR(255),
    city_district            VARCHAR(50),
    statistical_quarter      VARCHAR(255),
    population_count         VARCHAR(50)
);
