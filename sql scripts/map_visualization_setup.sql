-- =========================================================================
-- MAP VISUALIZATION SETUP
-- Run this script in MySQL Workbench after loading the CSV data
-- =========================================================================

USE traffic_population_zh;

-- =========================================================================
-- STEP 1: Create table for Quarter Centroids (WGS84 coordinates)
-- =========================================================================
-- First, load the CSV file 'quarter_centroids_wgs84.csv' into this table

DROP TABLE IF EXISTS Quarter_Centroids_WGS84;

CREATE TABLE Quarter_Centroids_WGS84 (
    quarter_code VARCHAR(20) PRIMARY KEY,
    quarter_name VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL
);

-- After creating the table, load the CSV using:
-- Option A: Use MySQL Workbench Table Data Import Wizard (right-click table -> Table Data Import Wizard)
-- Option B: Use LOAD DATA (adjust path to your CSV location):
/*
LOAD DATA LOCAL INFILE 'C:\\path\\to\\quarter_centroids_wgs84.csv'
INTO TABLE Quarter_Centroids_WGS84
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(quarter_code, quarter_name, latitude, longitude);
*/

-- =========================================================================
-- STEP 2: Create table for Counting Site Coordinates (WGS84)
-- =========================================================================
-- IMPORTANT: Do NOT do approximate conversion in SQL.
-- Instead, convert LV95 -> WGS84 in Python (pyproj) and import the resulting CSV.
-- Expected CSV columns: counting_site_id, counting_site_name, latitude, longitude

DROP TABLE IF EXISTS CountingSite_WGS84;

CREATE TABLE CountingSite_WGS84 (
    counting_site_id VARCHAR(50) PRIMARY KEY,
    counting_site_name VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL
);

-- Load the CSV using:
-- Option A: Table Data Import Wizard
-- Option B: LOAD DATA (adjust path):
/*
LOAD DATA LOCAL INFILE 'C:\\path\\to\\counting_sites_wgs84.csv'
INTO TABLE CountingSite_WGS84
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(counting_site_id, counting_site_name, latitude, longitude);
*/

-- =========================================================================
-- STEP 3: Map View A - Quarter Stress Index Map
-- =========================================================================
-- To avoid interfering with existing KPI views, we build a SMALL cache table
-- from your exported KPI 1 quarter results (34 rows), then join to coordinates.

DROP TABLE IF EXISTS kpi1_quarter_stress_cache;

CREATE TABLE kpi1_quarter_stress_cache (
    district_id INT NULL,
    quarter_name VARCHAR(255) NOT NULL,
    population_2012 INT NULL,
    population_2025 INT NULL,
    traffic_2012 DECIMAL(18, 2) NULL,
    traffic_2025 DECIMAL(18, 2) NULL,
    population_growth_pct DECIMAL(10, 2) NULL,
    traffic_growth_pct DECIMAL(10, 2) NULL,
    stress_index_pct DECIMAL(10, 2) NULL,
    stress_classification VARCHAR(100) NULL
);

-- Load your KPI 1 quarter stress results using Table Data Import Wizard
-- from 'quarter_stress_index.xlsx' (save as CSV first).

CREATE INDEX idx_kpi1_quarter_name ON kpi1_quarter_stress_cache (quarter_name);

CREATE OR REPLACE VIEW v_map_kpi1_quarter_stress AS
SELECT
    s.district_id,
    s.quarter_name,
    s.population_2012,
    s.population_2025,
    s.traffic_2012,
    s.traffic_2025,
    s.population_growth_pct,
    s.traffic_growth_pct,
    s.stress_index_pct,
    s.stress_classification,
    q.latitude,
    q.longitude
FROM kpi1_quarter_stress_cache s
JOIN Quarter_Centroids_WGS84 q
  ON q.quarter_name = s.quarter_name
WHERE s.quarter_name <> 'City';

-- =========================================================================
-- STEP 4: Materialized cache for Bottleneck data (for fast Metabase queries)
-- =========================================================================
-- If you have a KPI 2 view, materialize it here
-- Adjust the source view name to match yours

DROP TABLE IF EXISTS kpi2_bottlenecks_cache;

-- Option A: If you have a bottleneck view already:
/*
CREATE TABLE kpi2_bottlenecks_cache AS
SELECT * FROM v_kpi2_bottlenecks;
*/

-- Option B: Create from your exported Excel data structure:
CREATE TABLE kpi2_bottlenecks_cache (
    counting_site_name VARCHAR(255),
    peak_hour VARCHAR(10),
    avg_volume DECIMAL(12, 2),
    status VARCHAR(50)
);

-- Load your bottleneck data using Table Data Import Wizard
-- from 'bottleneck_and_peakhour.xlsx' (save as CSV first)

CREATE INDEX idx_kpi2_name ON kpi2_bottlenecks_cache (counting_site_name);

-- =========================================================================
-- STEP 5: Map View B - Bottleneck Map
-- =========================================================================

CREATE OR REPLACE VIEW v_map_kpi2_bottlenecks AS
SELECT
    b.counting_site_name,
    b.peak_hour,
    b.avg_volume,
    b.status,
    c.latitude,
    c.longitude
FROM kpi2_bottlenecks_cache b
LEFT JOIN CountingSite_WGS84 c
  ON c.counting_site_name = b.counting_site_name;

-- =========================================================================
-- STEP 6: Quick verification queries
-- =========================================================================

-- Check quarter coordinates loaded correctly
SELECT * FROM Quarter_Centroids_WGS84 LIMIT 5;

-- Check counting site coordinates
SELECT * FROM CountingSite_WGS84 LIMIT 5;

-- Check map view A (quarter stress)
SELECT * FROM v_map_kpi1_quarter_stress LIMIT 5;

-- Check map view B (bottlenecks) - shows NULL coords for unmatched sites
SELECT * FROM v_map_kpi2_bottlenecks LIMIT 10;

-- Find bottleneck sites that don't have coordinates (name mismatch)
SELECT counting_site_name, status 
FROM v_map_kpi2_bottlenecks 
WHERE latitude IS NULL;

-- Find quarter names that don't match the official centroid table
SELECT s.quarter_name
FROM kpi1_quarter_stress_cache s
LEFT JOIN Quarter_Centroids_WGS84 q
  ON q.quarter_name = s.quarter_name
WHERE q.quarter_name IS NULL;
