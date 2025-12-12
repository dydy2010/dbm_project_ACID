CREATE VIEW v_population_city_yearly AS
SELECT
    YEAR(p.reference_date_year) AS year,
    SUM(p.population_count) AS population_city
FROM population p
JOIN (
    SELECT 
        YEAR(reference_date_year) AS year,
        MAX(reference_date_year) AS latest_date
    FROM population
    GROUP BY YEAR(reference_date_year)
) latest
    ON YEAR(p.reference_date_year) = latest.year
   AND p.reference_date_year = latest.latest_date
GROUP BY YEAR(p.reference_date_year)
ORDER BY year;
