# Metabase Map Visualization for KPI2 (Bottlenecks)

This section documents the implementation of geographic map visualizations in Metabase for the KPI2 Bottleneck analysis. The work enables both pin-based and region-based map views of traffic bottlenecks across Zurich's statistical quarters.

---

## Overview

To enhance the analytical capabilities of the Metabase dashboard, we implemented map visualizations that display KPI2 (Bottleneck) data geographically. This allows urban planners to:

1. **Identify spatial patterns** of traffic congestion across Zurich
2. **Compare bottleneck intensity** between different quarters (Quartiere)
3. **Visualize aggregated metrics** at the quarter level using official Zurich administrative boundaries

---

## Technical Implementation

### Data Model Extension

Two new SQL views were created to support map visualization:

#### View 1: `v_map_kpi2_bottlenecks_geo` (Site-Level)

This view enriches the existing `v_kpi2_bottlenecks` view with geographic information:

```sql
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
```

**Purpose:** Enables pin map visualization with individual counting sites plotted by latitude/longitude.

#### View 2: `v_map_kpi2_quarter_geo` (Quarter-Level Aggregation)

This view aggregates bottleneck data to the quarter level for region map visualization:

```sql
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
```

**Purpose:** Enables region map visualization with quarters colored by aggregated metrics (number of bottlenecks or average traffic volume).

---

## GeoJSON Integration

### Custom Map Configuration

To display Zurich's administrative quarter boundaries, a custom GeoJSON map was uploaded to Metabase:

- **Source file:** `stzh.adm_statistische_quartiere_v.json`
- **Origin:** City of Zurich Open Data Portal (opendata.swiss)
- **Geometry type:** Polygon (34 statistical quarters)

### Key GeoJSON Properties

| Property | Description | Example |
|----------|-------------|---------|
| `qname` | Quarter name (German) | "Höngg", "Mühlebach" |
| `qnr` | Quarter number | 101, 82 |
| `kname` | District name | "Kreis 10", "Kreis 8" |
| `knr` | District number | 10, 8 |

### Metabase Custom Map Settings

In Metabase Admin → Settings → Maps → Custom maps:

- **Map name:** `zurich_map_geojson`
- **Region identifier property:** `qname`
- **Display name property:** `qname`

**Critical:** The `quarter_name` column in the SQL view must exactly match the `qname` values in the GeoJSON (including German umlauts: ö, ü, ä).

---

## Metabase Visualization Setup

### Region Map (Quarter-Level)

1. **Data source:** `v_map_kpi2_quarter_geo`
2. **Visualization type:** Map → Region map
3. **Settings:**
   - Region map: `zurich_map_geojson`
   - Region field: `quarter_name`
   - Metric field: `n_bottlenecks` or `avg_volume_quarter`

**[INSERT SCREENSHOT: Region map showing Zurich quarters colored by bottleneck count]**

### Pin Map (Site-Level)

1. **Data source:** `v_map_kpi2_bottlenecks_geo`
2. **Visualization type:** Map → Pin map
3. **Settings:**
   - Latitude: `latitude`
   - Longitude: `longitude`
   - Color by: `status` (Bottleneck vs Normal)

**[INSERT SCREENSHOT: Pin map showing individual counting sites]**

---

## Quarter Name Matching

A critical step was ensuring exact name matching between the database and GeoJSON. Both sources contain the same 34 statistical quarters:

| Quarter Name | Kreis |
|--------------|-------|
| Affoltern | 11 |
| Albisrieden | 9 |
| Alt-Wiedikon | 3 |
| Altstetten | 9 |
| City | 1 |
| Enge | 2 |
| Escher Wyss | 5 |
| Fluntern | 7 |
| Friesenberg | 3 |
| Gewerbeschule | 5 |
| Hard | 4 |
| Hirslanden | 7 |
| Hirzenbach | 12 |
| Hochschulen | 1 |
| Höngg | 10 |
| Hottingen | 7 |
| Langstrasse | 4 |
| Leimbach | 2 |
| Lindenhof | 1 |
| Mühlebach | 8 |
| Oberstrass | 6 |
| Oerlikon | 11 |
| Rathaus | 1 |
| Saatlen | 12 |
| Schwamendingen-Mitte | 12 |
| Seebach | 11 |
| Seefeld | 8 |
| Sihlfeld | 3 |
| Unterstrass | 6 |
| Weinegg | 8 |
| Werd | 4 |
| Wipkingen | 10 |
| Witikon | 7 |
| Wollishofen | 2 |

---

## Files Created

| File | Location | Purpose |
|------|----------|---------|
| `kpi2_map_views.sql` | `sql scripts/` | SQL script to create map views |
| `stzh.adm_statistische_quartiere_v.json` | `data/result data/geojson/data/` | GeoJSON for Zurich quarters |

---

## Analytical Value

The map visualizations provide urban planners with:

1. **Spatial awareness:** Quickly identify which quarters have the most traffic bottlenecks
2. **Pattern recognition:** Detect clusters of congestion (e.g., central districts vs. peripheral areas)
3. **Comparative analysis:** Compare bottleneck intensity across all 34 quarters at a glance
4. **Drill-down capability:** From region map overview to individual site details via pin map

This geographic layer complements the tabular and chart-based KPI displays, enabling a more intuitive understanding of Zurich's traffic patterns for urban planning decisions.
