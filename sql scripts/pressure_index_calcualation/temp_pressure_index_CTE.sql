-- quick check (took longer than i thought)
USE traffic_population_zh;
SELECT * FROM v_population_yearly LIMIT 10;
SELECT * FROM v_traffic_yearly LIMIT 10;
-- v1 check kres(city_district level growth and index)
WITH pop AS (
    SELECT year, city_district, SUM(population_total) AS population_total
    FROM v_population_yearly
    GROUP BY year, city_district
)
SELECT 
    p2012.city_district,
    p2012.population_total AS pop_2012,
    p2025.population_total AS pop_2025,
    ROUND(((p2025.population_total - p2012.population_total) / p2012.population_total) * 100, 1) AS pop_growth_pct
FROM pop p2012
JOIN pop p2025 
    ON p2025.city_district = p2012.city_district 
    AND p2025.year = 2025
WHERE p2012.year = 2012
ORDER BY city_district;

-- v2 Quarter level growth and index calculation, first run to see result, if good make it into a view
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
        p2012.population_total AS pop_2012,
        p2025.population_total AS pop_2025,
        t2012.vehicle_total   AS traffic_2012,
        t2025.vehicle_total   AS traffic_2025
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
        pop_2012,
        pop_2025,
        traffic_2012,
        traffic_2025,
        ROUND(((pop_2025 - pop_2012) / pop_2012) * 100, 1) AS population_growth_pct,
        ROUND(((traffic_2025 - traffic_2012) / traffic_2012) * 100, 1) AS traffic_growth_pct,
        ROUND(
            ((traffic_2025 - traffic_2012) / traffic_2012) * 100
            - ((pop_2025 - pop_2012) / pop_2012) * 100, 
            1
        ) AS stress_index_pct
    FROM paired
),
ranked AS (
    SELECT 
        s.*,
        NTILE(4) OVER (ORDER BY stress_index_pct) AS quartile
    FROM stress s
)
SELECT
    *,
    CASE 
        WHEN quartile = 4 THEN 'Commuter pressure'        -- top 25%
        WHEN quartile = 1 THEN 'Residential pressure'     -- bottom 25%
        ELSE 'Balanced'
    END AS classification
FROM ranked
ORDER BY city_district, statistical_quarter;

-- v3 same logic, but create a view with it, this is the end product and was used
CREATE OR REPLACE VIEW v_quarter_stress_index AS
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
        ROUND(((pop_total_2025 - pop_total_2012) / pop_total_2012) * 100, 1) AS pop_growth_pct,
        ROUND(((vehicle_total_2025 - vehicle_total_2012) / vehicle_total_2012) * 100, 1) AS vehicle_growth_pct,
        ROUND(
            ((vehicle_total_2025 - vehicle_total_2012) / vehicle_total_2012) * 100
            - ((pop_total_2025 - pop_total_2012) / pop_total_2012) * 100, 
            1
        ) AS stress_index_pct
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
        WHEN stress_quartile = 4 THEN 'Commuter pressure'
        WHEN stress_quartile = 1 THEN 'Residential pressure'
        ELSE 'Balanced'
    END AS stress_classification
FROM ranked
ORDER BY district_id, quarter_name;