
-- quick diagnostics: find NULL or zero population rows
SELECT 
    city_district,
    statistical_quarter,
    year,
    SUM(CASE WHEN population_total IS NULL THEN 1 ELSE 0 END) AS pop_null_rows,
    SUM(CASE WHEN population_total = 0 THEN 1 ELSE 0 END) AS pop_zero_rows
FROM v_population_yearly
WHERE year IN (2012, 2025)
GROUP BY city_district, statistical_quarter, year
ORDER BY city_district, statistical_quarter, year;

-- quick diagnostics: find NULL or zero traffic rows
SELECT 
    city_district,
    statistical_quarter,
    year,
    SUM(CASE WHEN yearly_vehicle_count IS NULL THEN 1 ELSE 0 END) AS traffic_null_rows,
    SUM(CASE WHEN yearly_vehicle_count = 0 THEN 1 ELSE 0 END) AS traffic_zero_rows
FROM v_traffic_yearly
WHERE year IN (2012, 2025)
GROUP BY city_district, statistical_quarter, year
ORDER BY city_district, statistical_quarter, year;

-- v3 same logic, but create a view with it, this is the end product and was used
CREATE OR REPLACE VIEW v_kpi1_quarter_stress_index AS
WITH pop AS (
    SELECT 
        year,
        city_district,
        statistical_quarter,
        SUM(population_total) AS population_total
    FROM v_population_yearly
    GROUP BY year, city_district, statistical_quarter
),
traffic AS (
    SELECT 
        year,
        city_district,
        statistical_quarter,
        SUM(yearly_vehicle_count) AS vehicle_total
    FROM v_traffic_yearly
    GROUP BY year, city_district, statistical_quarter
),
paired AS (
    SELECT 
        p2012.city_district,
        p2012.statistical_quarter,
        p2012.population_total AS pop_total_2012,
        p2025.population_total AS pop_total_2025,
        t2012.vehicle_total   AS vehicle_total_2012,
        t2025.vehicle_total   AS vehicle_total_2025
    FROM pop p2012
    JOIN pop p2025 
        ON p2025.city_district = p2012.city_district
       AND p2025.statistical_quarter = p2012.statistical_quarter
       AND p2025.year = 2025
    JOIN traffic t2012 
        ON t2012.city_district = p2012.city_district
       AND t2012.statistical_quarter = p2012.statistical_quarter
       AND t2012.year = 2012
    JOIN traffic t2025 
        ON t2025.city_district = p2012.city_district
       AND t2025.statistical_quarter = p2012.statistical_quarter
       AND t2025.year = 2025
    WHERE p2012.year = 2012
),
stress AS (
    SELECT
        city_district,
        statistical_quarter,
        pop_total_2012,
        pop_total_2025,
        vehicle_total_2012,
        vehicle_total_2025,
        CASE 
            WHEN pop_total_2012 IS NULL OR pop_total_2012 = 0 THEN NULL
            ELSE ROUND(
                (
                    (CASE WHEN pop_total_2025 IS NULL THEN 0 ELSE pop_total_2025 END) - pop_total_2012
                ) / pop_total_2012 * 100,
                1
            )
        END AS pop_growth_pct,
        CASE 
            WHEN vehicle_total_2012 IS NULL OR vehicle_total_2012 = 0 THEN NULL
            ELSE ROUND(
                (
                    (CASE WHEN vehicle_total_2025 IS NULL THEN 0 ELSE vehicle_total_2025 END) - vehicle_total_2012
                ) / vehicle_total_2012 * 100,
                1
            )
        END AS vehicle_growth_pct,
        CASE 
            WHEN (vehicle_total_2012 IS NULL OR vehicle_total_2012 = 0)
              OR (pop_total_2012 IS NULL OR pop_total_2012 = 0)
            THEN NULL
            ELSE ROUND(
                (
                    (
                        (CASE WHEN vehicle_total_2025 IS NULL THEN 0 ELSE vehicle_total_2025 END) - vehicle_total_2012
                    ) / vehicle_total_2012 * 100
                )
                -
                (
                    (
                        (CASE WHEN pop_total_2025 IS NULL THEN 0 ELSE pop_total_2025 END) - pop_total_2012
                    ) / pop_total_2012 * 100
                ),
                1
            )
        END AS stress_index_pct
    FROM paired
),
ranked AS (
    SELECT 
        s.*,
        NTILE(4) OVER (ORDER BY stress_index_pct) AS stress_quartile
    FROM stress s
)
SELECT
    city_district            AS district_id,
    statistical_quarter      AS quarter_name,
    pop_total_2012           AS population_2012,
    pop_total_2025           AS population_2025,
    vehicle_total_2012       AS traffic_2012,
    vehicle_total_2025       AS traffic_2025,
    pop_growth_pct           AS population_growth_pct,
    vehicle_growth_pct       AS traffic_growth_pct,
    stress_index_pct,
    CASE 
        WHEN stress_index_pct IS NULL THEN 'Insufficient data'
        WHEN stress_quartile = 4 THEN 'Commuter pressure'
        WHEN stress_quartile = 1 THEN 'Residential pressure'
        ELSE 'Balanced'
    END AS stress_classification
FROM ranked
ORDER BY district_id, quarter_name;
-- to view the result
SELECT *
FROM v_kpi1_quarter_stress_index
ORDER BY district_id, quarter_name
LIMIT 50;