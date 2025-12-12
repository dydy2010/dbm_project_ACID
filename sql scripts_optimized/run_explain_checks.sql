-- ============================================================
-- EXPLAIN queries for KPI views
-- Run this script manually in MySQL Workbench after deploying the
-- optimized views and indexes. Review the "type" and "key" columns
-- in the EXPLAIN output to confirm indexes are being used.
-- ============================================================

USE traffic_population_zh;

-- KPI2 bottlenecks view
EXPLAIN SELECT *
FROM v_kpi2_bottlenecks
LIMIT 10;

-- KPI3 dominant direction view
EXPLAIN SELECT *
FROM v_kpi3_dominant_direction
LIMIT 10;

-- Base traffic aggregation (feeds KPI1)
EXPLAIN SELECT *
FROM v_traffic_yearly
WHERE year = 2025;

-- KPI1 stress index view (checks joins on population + traffic)
EXPLAIN SELECT *
FROM v_kpi1_quarter_stress_index_new
WHERE district_id = 1
LIMIT 10;
