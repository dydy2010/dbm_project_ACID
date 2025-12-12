# SQL Performance Optimization Plan for KPI Views

This document outlines a step-by-step strategy to optimize the KPI views used in Metabase dashboards, based on the SQL Performance lecture materials.

---

## 1. Overview of KPI Views to Optimize

| View | Purpose | Performance Risk |
|------|---------|------------------|
| `v_traffic_yearly` | Yearly traffic by site/quarter | **High** – scans millions of rows, uses `YEAR()` function |
| `v_traffic_city_yearly` | City-level yearly traffic avg | **High** – same base table scan |
| `v_population_yearly` | Yearly population by quarter | **Medium** – uses `YEAR()` in JOIN conditions |
| `v_population_city_yearly` | City-level yearly population | **Medium** – same issue |
| `v_kpi0_city_population_traffic` | KPI0 combined view | **Low** – reads from lightweight views |
| `v_kpi1_quarter_stress_index_new` | KPI1 stress index | **Medium** – depends on `v_traffic_yearly` and `v_population_yearly` |
| `v_kpi2_bottlenecks` | KPI2 peak-hour bottlenecks | **High** – uses `YEAR()` and `HOUR()` functions |
| `v_kpi3_dominant_direction` | KPI3 directional imbalance | **High** – uses `YEAR()` function |

---

## 2. Key Optimization Strategies from Lecture

### 2.1 Write SARGable Predicates (Search ARGument able)

**Problem:** Using functions on indexed columns prevents index usage.

**Bad (non-SARGable):**
```sql
WHERE YEAR(tm.timestamp) BETWEEN 2023 AND 2025
```

**Good (SARGable):**
```sql
WHERE tm.timestamp >= '2023-01-01' AND tm.timestamp < '2026-01-01'
```

**Why:** The optimizer can use an index on `timestamp` with range predicates but NOT when wrapped in `YEAR()`.

---

### 2.2 Create Indexes on Join and Filter Columns

**Lecture guideline:** Index columns used in:
- WHERE clauses
- JOIN conditions
- GROUP BY clauses

**Key columns to index:**
- `TrafficMeasurement.timestamp`
- `TrafficMeasurement.measurement_site_id`
- `MeasurementSite.counting_site_id`
- `Population.reference_date_year`
- `Population.city_district`
- `Population.statistical_quarter`
- `Quarter.street_name`

---

### 2.3 Avoid Implicit Type Conversions

Ensure join keys use consistent data types. For example:
- `counting_site_id` should be VARCHAR(50) in both `MeasurementSite` and `CountingSite`
- `city_district` should be INT in both `Population` and `Quarter`

---

### 2.4 Use EXPLAIN to Verify Index Usage

After creating indexes, run:
```sql
EXPLAIN SELECT * FROM v_traffic_yearly LIMIT 10;
```

Look for:
- **Good:** `ref`, `range`, `index` access types
- **Bad:** `ALL` (full table scan)

---

## 3. Step-by-Step Implementation Plan

### Step 1: Create Indexes on Base Tables

**Option A: Add indexes directly to existing table creation scripts**

Modify these files to include index creation after table definitions:

| Script File | Add Indexes For |
|-------------|----------------|
| `sql scripts/Traffic_sql/3_create_tables_traffic.sql` | TrafficMeasurement, MeasurementSite |
| `sql scripts/Population_sql/3_create_table_population.sql` | Population |
| `sql scripts/Quarter_sql/3_create_table_quarter.sql` | Quarter |

**Option B: Create a new dedicated index script (recommended)**

Create a new file: `sql scripts/9_create_indexes_performance.sql`

This keeps index creation separate from table creation, making it easier to manage.

**Index SQL to add:**

```sql
USE traffic_population_zh;

-- ============================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- Run this AFTER all tables are created and data is loaded
-- ============================================================

-- TrafficMeasurement indexes (largest table, most critical)
-- Used in: v_traffic_yearly, v_kpi2_bottlenecks, v_kpi3_dominant_direction
CREATE INDEX idx_tm_timestamp ON TrafficMeasurement(timestamp);
CREATE INDEX idx_tm_measurement_site_id ON TrafficMeasurement(measurement_site_id);
CREATE INDEX idx_tm_composite ON TrafficMeasurement(measurement_site_id, timestamp);

-- MeasurementSite indexes
-- Used in: all traffic views (JOIN condition)
CREATE INDEX idx_ms_counting_site_id ON MeasurementSite(counting_site_id);

-- Population indexes
-- Used in: v_population_yearly, v_population_city_yearly, v_kpi1
CREATE INDEX idx_pop_reference_date ON Population(reference_date_year);
CREATE INDEX idx_pop_district_quarter ON Population(city_district, statistical_quarter);
CREATE INDEX idx_pop_composite ON Population(city_district, statistical_quarter, reference_date_year);

-- Quarter indexes
-- Used in: v_traffic_yearly (JOIN on street_name)
CREATE INDEX idx_quarter_street ON Quarter(street_name);
CREATE INDEX idx_quarter_district ON Quarter(city_district);
```

**Note:** MySQL automatically creates indexes on PRIMARY KEY and FOREIGN KEY columns, but composite indexes for common query patterns must be added manually.

**Execution order:** Run this script AFTER running all table creation scripts (step 3) and data loading scripts (step 8).

---

### Step 2: Rewrite Views with SARGable Predicates

#### 2a. `v_kpi2_bottlenecks` – Replace `YEAR()` with range

**File to modify:** `sql scripts/Traffic_sql/v_kpi2_bottlenecks.sql`

**Line 29 – Before:**
```sql
WHERE YEAR(tm.timestamp) BETWEEN 2023 AND 2025
```

**After:**
```sql
WHERE tm.timestamp >= '2023-01-01' AND tm.timestamp < '2026-01-01'
```

---

#### 2b. `v_kpi3_dominant_direction` – Same fix

**File to modify:** `sql scripts/Traffic_sql/v_kpi3_dominant_direction.sql`

**Line 12 – Before:**
```sql
WHERE YEAR(tm.timestamp) BETWEEN 2023 AND 2025
```

**After:**
```sql
WHERE tm.timestamp >= '2023-01-01' AND tm.timestamp < '2026-01-01'
```

---

#### 2c. `v_traffic_yearly` – Add year filter

**File to modify:** `sql scripts/Traffic_sql/v_traffic_yearly.sql`

The `YEAR()` function in SELECT and GROUP BY is unavoidable for yearly aggregation. However, add a WHERE clause to reduce scanned rows:

**Add after line 18 (after the last JOIN, before GROUP BY):**
```sql
WHERE trafficmeasurement.timestamp >= '2012-01-01' 
  AND trafficmeasurement.timestamp < '2026-01-01'
```

---

#### 2d. `v_population_yearly` and `v_population_city_yearly`

**Files:**
- `sql scripts/Population_sql/v_population_yearly.sql`
- `sql scripts/Population_sql/v_population_city_yearly.sql`

These use `YEAR(reference_date_year)` in JOIN conditions. The population table is much smaller than traffic (~thousands vs millions of rows), so the performance impact is lower. **No changes required** unless you observe slow queries.

---

### Step 3: Apply Changes to View Scripts

**Summary of files to modify:**

| File | Change | Line(s) |
|------|--------|--------|
| `sql scripts/Traffic_sql/v_kpi2_bottlenecks.sql` | Replace `YEAR()` with date range | Line 29 |
| `sql scripts/Traffic_sql/v_kpi3_dominant_direction.sql` | Replace `YEAR()` with date range | Line 12 |
| `sql scripts/Traffic_sql/v_traffic_yearly.sql` | Add WHERE clause for year range | After line 18 |

**After modifying, re-run these view creation scripts on the VM to apply changes.**

---

### Step 4: Verify with EXPLAIN

After applying changes, run EXPLAIN on each view:

```sql
EXPLAIN SELECT * FROM v_kpi2_bottlenecks LIMIT 10;
EXPLAIN SELECT * FROM v_kpi3_dominant_direction LIMIT 10;
EXPLAIN SELECT * FROM v_traffic_yearly WHERE year = 2025 LIMIT 10;
```

Check that:
- Access type is NOT `ALL`
- `rows` estimate is reasonable (not millions for simple queries)
- Key column shows index being used

---

### Step 5: Consider Materialized Summary Tables (Advanced)

If views are still slow after indexing and SARGable rewrites, consider creating **summary tables** that pre-aggregate data:

```sql
CREATE TABLE summary_traffic_yearly AS
SELECT
    YEAR(tm.timestamp) AS year,
    cs.counting_site_id,
    cs.counting_site_name,
    q.city_district,
    q.statistical_quarter,
    SUM(tm.vehicle_count) AS yearly_vehicle_count
FROM trafficmeasurement tm
JOIN measurementsite ms ON tm.measurement_site_id = ms.measurement_site_id
JOIN countingsite cs ON ms.counting_site_id = cs.counting_site_id
JOIN quarter q ON cs.counting_site_name = q.street_name
GROUP BY YEAR(tm.timestamp), cs.counting_site_id, cs.counting_site_name, 
         q.city_district, q.statistical_quarter;
```

Then create indexes on this summary table and point your KPI views at it instead of the raw `trafficmeasurement` table.

**Trade-off:** Summary tables must be refreshed when new data arrives.

---

## 4. Summary Checklist

| Step | Action | File to Modify | Status |
|------|--------|----------------|--------|
| 1 | Create index script | Create `sql scripts/9_create_indexes_performance.sql` | ☐ Pending |
| 2 | Rewrite v_kpi2_bottlenecks with SARGable WHERE | `sql scripts/Traffic_sql/v_kpi2_bottlenecks.sql` | ☐ Pending |
| 3 | Rewrite v_kpi3_dominant_direction with SARGable WHERE | `sql scripts/Traffic_sql/v_kpi3_dominant_direction.sql` | ☐ Pending |
| 4 | Add year filter to v_traffic_yearly | `sql scripts/Traffic_sql/v_traffic_yearly.sql` | ☐ Pending |
| 5 | Run EXPLAIN on all KPI views | Run in MySQL Workbench | ☐ Pending |
| 6 | (Optional) Create summary tables | Create new script if needed | ☐ Pending |

---

## 5. Expected Outcome

After applying these optimizations:
- Metabase queries on KPI views should return in **seconds** instead of minutes
- EXPLAIN output should show **index range scans** instead of full table scans
- Dashboard refresh will be faster and won't time out

---

## 6. References

- Lecture: *5.1 Presentation SQL Performance*
- MySQL Workbench Chapter 6 – Performance
- Exercise: *5.5 Exercise SQL Performance V2*
