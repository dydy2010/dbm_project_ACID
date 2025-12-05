-- KPI 1 – Efficiency Improved Version

USE traffic_population_zh;

/* ---------------------------------------------------------------------------
   STEP 1 – Add helper indexes (run once, then comment out to avoid duplicates)
   ---------------------------------------------------------------------------
   run the new indexes one time is enough, then commented out, otherwise there will be duplicate errors
*/

-- CREATE INDEX idx_tm_site_year ON TrafficMeasurement (measurement_site_id, timestamp);
-- CREATE INDEX idx_ms_counting ON MeasurementSite (counting_site_id, measurement_site_id);
-- CREATE INDEX idx_population_year_quarter ON Population (reference_date_year, statistical_quarter);

/* ---------------------------------------------------------------------------
   STEP 2 – Only get the two target years (2012 & 2025) into a cache table, 
   we dont need other years to calculate the growth
   ---------------------------------------------------------------------------
*/

DROP TABLE IF EXISTS kpi1_quarter_year_cache;
CREATE TABLE kpi1_quarter_year_cache
AS
SELECT
    year,
    city_district,
    statistical_quarter,
    SUM(population_total) AS population_total,
    SUM(vehicle_total)    AS vehicle_total
FROM (
    SELECT 
        year,
        city_district,
        statistical_quarter,
        population_total,
        0 AS vehicle_total
    FROM v_population_yearly
    WHERE year IN (2012, 2025)

    UNION ALL -- we can also use join but complicated to join exactly the same elements

    SELECT 
        year,
        city_district,
        statistical_quarter,
        0 AS population_total,
        yearly_vehicle_count AS vehicle_total
    FROM v_traffic_yearly
    WHERE year IN (2012, 2025)
) raw_yearly
GROUP BY year, city_district, statistical_quarter;

CREATE INDEX idx_cache_year_quarter
ON kpi1_quarter_year_cache (year, city_district, statistical_quarter);

/* ---------------------------------------------------------------------------
   STEP 3 – Create a faster view on top of the cache table
   ---------------------------------------------------------------------------
  create several temp tables to calculate the index step by step
*/

CREATE OR REPLACE VIEW v_kpi1_efficiency_improved AS
WITH paired AS (
    SELECT
        y2012.city_district,
        y2012.statistical_quarter,
        y2012.population_total AS population_2012,
        y2025.population_total AS population_2025,
        y2012.vehicle_total    AS traffic_2012,
        y2025.vehicle_total    AS traffic_2025
    FROM kpi1_quarter_year_cache y2012
    JOIN kpi1_quarter_year_cache y2025
      ON y2025.city_district       = y2012.city_district
     AND y2025.statistical_quarter = y2012.statistical_quarter
    WHERE y2012.year = 2012
      AND y2025.year = 2025
),
stress AS (
    SELECT
        city_district,
        statistical_quarter,
        population_2012,
        population_2025,
        traffic_2012,
        traffic_2025,
        ROUND(((population_2025 - population_2012) / population_2012) * 100, 1) AS population_growth_pct,
        ROUND(((traffic_2025    - traffic_2012)    / traffic_2012)    * 100, 1) AS traffic_growth_pct,
        ROUND(
            ((traffic_2025    - traffic_2012)    / traffic_2012)    * 100
          - ((population_2025 - population_2012) / population_2012) * 100,
            1
        ) AS stress_index_pct
    FROM paired
)
SELECT
    city_district        AS district_id,
    statistical_quarter  AS quarter_name,
    population_2012,
    population_2025,
    traffic_2012,
    traffic_2025,
    population_growth_pct,
    traffic_growth_pct,
    stress_index_pct,
    CASE
        WHEN NTILE(4) OVER (ORDER BY stress_index_pct) = 4 THEN 'Commuter pressure'
        WHEN NTILE(4) OVER (ORDER BY stress_index_pct) = 1 THEN 'Residential pressure'
        ELSE 'Balanced'
    END AS stress_classification
FROM stress;

/* ---------------------------------------------------------------------------
   STEP 4 Quick check
   ---------------------------------------------------------------------------
*/

SELECT *
FROM v_kpi1_efficiency_improved
ORDER BY district_id, quarter_name
LIMIT 50;
