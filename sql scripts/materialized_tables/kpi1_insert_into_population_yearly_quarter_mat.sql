INSERT INTO population_yearly_quarter_mat
SELECT
    year,
    city_district,
    statistical_quarter,
    SUM(population_total) AS population_total
FROM v_population_yearly
GROUP BY year, city_district, statistical_quarter;
