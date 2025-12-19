-- =========================================================================
-- KPI2 MAP VIEWS FOR METABASE
-- Created: 2025-12-19
-- Purpose: Enable region map visualization for KPI2 (Bottlenecks) in Metabase
-- =========================================================================

USE traffic_population_zh;

-- -------------------------------------------------------------------------
-- VIEW 1: KPI2 Bottlenecks with Geography (for PIN MAP)
-- Adds kreis + quarter_name + lat/lon to each bottleneck site
-- -------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_map_kpi2_bottlenecks_geo AS
SELECT
    k.counting_site_name,
    q.city_district        AS kreis,
    q.statistical_quarter  AS quarter_name,
    k.peak_hour,
    k.avg_volume,
    k.status,
    cs.east_coordinate,
    cs.north_coordinate,
    w.latitude,
    w.longitude
FROM v_kpi2_bottlenecks k
LEFT JOIN Quarter q
       ON q.street_name = k.counting_site_name
LEFT JOIN CountingSite cs
       ON cs.counting_site_name = k.counting_site_name
LEFT JOIN CountingSite_WGS84 w
       ON w.counting_site_name = k.counting_site_name;

-- -------------------------------------------------------------------------
-- VIEW 2: KPI2 Aggregated by Quarter (for REGION MAP with Zurich GeoJSON)
-- One row per quarter with aggregated bottleneck metrics
-- Matches GeoJSON qname property for Metabase region map
-- -------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_map_kpi2_quarter_geo AS
SELECT
    q.city_district                   AS kreis,
    q.statistical_quarter             AS quarter_name,
    COUNT(*)                          AS n_sites,
    ROUND(AVG(k.avg_volume), 0)       AS avg_volume_quarter,
    SUM(CASE WHEN k.status = 'Bottleneck' THEN 1 ELSE 0 END) AS n_bottlenecks
FROM v_kpi2_bottlenecks k
JOIN Quarter q
  ON q.street_name = k.counting_site_name
GROUP BY
    q.city_district,
    q.statistical_quarter;

-- =========================================================================
-- VERIFICATION QUERIES
-- Run these after creating the views to confirm they work correctly
-- =========================================================================

-- Check the pin map view (site-level with coordinates)
-- SELECT * FROM v_map_kpi2_bottlenecks_geo LIMIT 10;

-- Check the region map view (quarter-level aggregation)
-- SELECT * FROM v_map_kpi2_quarter_geo ORDER BY n_bottlenecks DESC LIMIT 10;

-- Count rows to verify data
-- SELECT COUNT(*) AS n_rows_pin FROM v_map_kpi2_bottlenecks_geo;
-- SELECT COUNT(*) AS n_rows_region FROM v_map_kpi2_quarter_geo;

-- =========================================================================
-- METABASE CONFIGURATION NOTES
-- =========================================================================
-- 
-- For Region Map (v_map_kpi2_quarter_geo):
--   1. Custom map GeoJSON: stzh.adm_statistische_quartiere_v.json
--   2. Region identifier property in GeoJSON: qname
--   3. Region field in Metabase: quarter_name
--   4. Metric field: n_bottlenecks or avg_volume_quarter
--
-- For Pin Map (v_map_kpi2_bottlenecks_geo):
--   1. Latitude column: latitude
--   2. Longitude column: longitude
--   3. Color by: status (Bottleneck vs Normal)
-- =========================================================================
