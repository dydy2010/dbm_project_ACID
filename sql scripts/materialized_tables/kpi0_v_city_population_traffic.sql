CREATE OR REPLACE VIEW v_kpi0_city_population_traffic AS
SELECT
    p.year,
    p.population_city,
    t.avg_vehicle_count_city,
    ROUND(
        (t.avg_vehicle_count_city
         - LAG(t.avg_vehicle_count_city) OVER (ORDER BY p.year))
        / LAG(t.avg_vehicle_count_city) OVER (ORDER BY p.year) * 100,
        2
    ) AS traffic_growth_percent
FROM v_population_city_yearly p
LEFT JOIN traffic_city_yearly_mat t
       ON p.year = t.year
ORDER BY p.year;
