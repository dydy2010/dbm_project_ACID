LOAD DATA LOCAL INFILE 'C:\\Users\\labadmin\\Downloads\\population_data_cleaned_final.csv'
INTO TABLE stg_population_lookup
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @dummy_reference_date_year,
    sex_code,
    sex,
    origin_code,
    origin,
    @dummy_city_district,
    @dummy_statistical_quarter,
    @dummy_population_count
);
