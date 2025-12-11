CREATE OR REPLACE VIEW v_kpi1_quarter_stress_index_new AS
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
        t2012.vehicle_total   AS traffic_2012,
        t2025.vehicle_total   AS traffic_2025
    FROM pop p2012
    LEFT JOIN pop p2025 
        ON p2025.city_district = p2012.city_district
       AND p2025.statistical_quarter = p2012.statistical_quarter
       AND p2025.year = 2025
    LEFT JOIN traffic t2012 
        ON t2012.city_district = p2012.city_district
       AND t2012.statistical_quarter = p2012.statistical_quarter
       AND t2012.year = 2012
    LEFT JOIN traffic t2025 
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

        -- FIXED traffic 2012
        CASE
            WHEN statistical_quarter = 'Langstrasse'          AND traffic_2012 IS NULL THEN 12019095
            WHEN statistical_quarter = 'Oberstrass'           AND traffic_2012 IS NULL THEN 8143882
            WHEN statistical_quarter = 'Witikon'              AND traffic_2012 IS NULL THEN 912447
            WHEN statistical_quarter = 'Weinegg'              AND traffic_2012 IS NULL THEN 887316
            WHEN statistical_quarter = 'Albisrieden'          AND traffic_2012 IS NULL THEN 10381552
            WHEN statistical_quarter = 'Saatlen'              AND traffic_2012 IS NULL THEN 648512
            WHEN statistical_quarter = 'Schwamendingen-Mitte' AND traffic_2012 IS NULL THEN 534118
            ELSE traffic_2012
        END AS traffic_2012_fixed,

        -- FIXED traffic 2025
        CASE
            WHEN statistical_quarter = 'Langstrasse'          AND traffic_2025 IS NULL THEN 9874663
            WHEN statistical_quarter = 'Oberstrass'           AND traffic_2025 IS NULL THEN 9112940
            WHEN statistical_quarter = 'Albisrieden'          AND traffic_2025 IS NULL THEN 5982344   
            WHEN statistical_quarter = 'Schwamendingen-Mitte' AND traffic_2025 IS NULL THEN 608327
            ELSE traffic_2025
        END AS traffic_2025_fixed
    FROM paired
),
ranked AS (
    SELECT
        city_district,
        statistical_quarter,
        pop_total_2012,
        pop_total_2025,
        traffic_2012_fixed,
        traffic_2025_fixed,

        -- population growth
        CASE 
            WHEN pop_total_2012 IS NULL OR pop_total_2012 = 0
                THEN NULL
            ELSE ROUND((pop_total_2025 - pop_total_2012) / pop_total_2012 * 100, 1)
        END AS pop_growth_pct,

        -- traffic growth
        CASE 
            WHEN traffic_2012_fixed IS NULL OR traffic_2012_fixed = 0
                THEN NULL
            ELSE ROUND((traffic_2025_fixed - traffic_2012_fixed) / traffic_2012_fixed * 100, 1)
        END AS traffic_growth_pct,

        -- stress index
        CASE 
            WHEN pop_total_2012 IS NULL OR pop_total_2012 = 0
              OR traffic_2012_fixed IS NULL OR traffic_2012_fixed = 0
                THEN NULL
            ELSE ROUND(
                ((traffic_2025_fixed - traffic_2012_fixed) / traffic_2012_fixed * 100) -
                ((pop_total_2025 - pop_total_2012) / pop_total_2012 * 100),
                1
            )
        END AS stress_index_pct,

        NTILE(4) OVER (ORDER BY 
            CASE 
                WHEN pop_total_2012 IS NULL OR pop_total_2012 = 0
                     OR traffic_2012_fixed IS NULL OR traffic_2012_fixed = 0
                    THEN NULL
                ELSE ROUND(
                    ((traffic_2025_fixed - traffic_2012_fixed) / traffic_2012_fixed * 100) -
                    ((pop_total_2025 - pop_total_2012) / pop_total_2012 * 100),
                    1
                )
            END
        ) AS stress_quartile
    FROM stress
)
SELECT
    city_district AS district_id,
    statistical_quarter AS quarter_name,
    pop_total_2012 AS population_2012,
    pop_total_2025 AS population_2025,
    traffic_2012_fixed AS traffic_2012,
    traffic_2025_fixed AS traffic_2025,
    pop_growth_pct AS population_growth_pct,
    traffic_growth_pct AS traffic_growth_pct,
    stress_index_pct,
    CASE 
        WHEN stress_index_pct IS NULL THEN 'Insufficient data'
        WHEN stress_quartile = 4 THEN 'Commuter pressure'
        WHEN stress_quartile = 1 THEN 'Residential pressure'
        ELSE 'Balanced'
    END AS stress_classification
FROM ranked
ORDER BY district_id, quarter_name;
