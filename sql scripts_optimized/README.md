# SQL Scripts - Optimized Version

This folder contains **performance-optimized** versions of the KPI view scripts.

---

## What was changed?

Only the following scripts were modified with **SARGable predicates** (replacing `YEAR()` function with date range filters):

| Script | Original Location | Change Made |
|--------|-------------------|-------------|
| `Traffic_sql/v_traffic_yearly.sql` | `sql scripts/Traffic_sql/` | Added WHERE clause with date range (2012-2025) |
| `Traffic_sql/v_kpi2_bottlenecks.sql` | `sql scripts/Traffic_sql/` | Replaced `YEAR(tm.timestamp) BETWEEN 2023 AND 2025` with date range |
| `Traffic_sql/v_kpi3_dominant_direction.sql` | `sql scripts/Traffic_sql/` | Replaced `YEAR(tm.timestamp) BETWEEN 2023 AND 2025` with date range |

## New script added

| Script | Purpose |
|--------|---------|
| `9_create_indexes_performance.sql` | Creates indexes on TrafficMeasurement, Population, Quarter tables to speed up queries |

---

## How to run on VM (step by step)

1. **First**, run all table creation and data loading scripts from the original `sql scripts/` folder
2. **Then**, run the index script to improve query speed:
   ```
   9_create_indexes_performance.sql
   ```
3. **Finally**, run the optimized view scripts from this folder:
   - `Traffic_sql/v_traffic_yearly.sql`
   - `Traffic_sql/v_kpi2_bottlenecks.sql`
   - `Traffic_sql/v_kpi3_dominant_direction.sql`

---

## Which views to use in Metabase?

### KPI Views (main dashboard views)

| KPI | View Name | Script Location | Metabase Visualization |
|-----|-----------|-----------------|------------------------|
| **KPI0** | `v_kpi0_city_population_traffic` | `sql scripts/Quarter_sql/` (original) | **Line chart**: X-axis = year, Y-axis = population and traffic, show growth trend over time |
| **KPI1** | `v_kpi1_quarter_stress_index_new` | `sql scripts/pressure_index_calcualation/` (original) | **Table** with color coding by stress_classification, or **Bar chart** grouped by district |
| **KPI2** | `v_kpi2_bottlenecks` | `sql scripts_optimized/Traffic_sql/` (optimized) | **Table**: show site name, peak hour, volume, status. Filter by status = 'Bottleneck' |
| **KPI3** | `v_kpi3_dominant_direction` | `sql scripts_optimized/Traffic_sql/` (optimized) | **Bar chart**: X-axis = site name, Y-axis = dominance_share, color by classification |

### Base Views (used by KPI views, not directly in dashboard)

| View Name | Script Location | Purpose |
|-----------|-----------------|---------|
| `v_traffic_yearly` | `sql scripts_optimized/Traffic_sql/` (optimized) | Aggregates traffic data by year, used by KPI1 |
| `v_traffic_city_yearly` | `sql scripts/Traffic_sql/` (original) | City-level traffic average, used by KPI0 |
| `v_population_yearly` | `sql scripts/Population_sql/` (original) | Population by quarter and year, used by KPI1 |
| `v_population_city_yearly` | `sql scripts/Population_sql/` (original) | City-level population, used by KPI0 |

---

## Quick summary: Which folder to use?

| View | Use Optimized? | Folder |
|------|----------------|--------|
| `v_traffic_yearly` | **Yes** | `sql scripts_optimized/Traffic_sql/` |
| `v_kpi2_bottlenecks` | **Yes** | `sql scripts_optimized/Traffic_sql/` |
| `v_kpi3_dominant_direction` | **Yes** | `sql scripts_optimized/Traffic_sql/` |
| All other views | No | `sql scripts/` (original folder) |

---

## Original scripts (backup)

The original (unmodified) scripts remain in `sql scripts/` folder. Use those if you encounter any issues with the optimized versions.

---

## Why these changes improve performance?

- **SARGable predicates**: Using `timestamp >= '2023-01-01'` instead of `YEAR(timestamp) = 2023` allows MySQL to use indexes on the timestamp column. This is much faster because the database can jump directly to the right rows instead of scanning every row.
- **Indexes**: Like a book index, they help MySQL find data quickly without reading the entire table.
- See `materials_for_report_later/sql_performance_optimization_plan.md` for full technical details
