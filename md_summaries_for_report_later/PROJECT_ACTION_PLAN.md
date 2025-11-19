# Database Project Action Plan - Urban Planning Analysis

## Project Overview
**Use Case**: Urban Planning Decision Support for Zürich  
**Datasets**: Population demographics (1998-2024) + Traffic counts (2024)  
**Team**: 4 members  
**Timeline**: 1.5 months  
**Goal**: Build database system with time series analysis for infrastructure planning

---

## Executive Summary: Your Datasets Assessment

### ✅ **VERDICT: GOOD FIT**

Your three datasets are **suitable for the project** with one important caveat:

**Strengths**:
- ✅ Large data volume (2M+ rows total) - excellent for performance optimization
- ✅ Rich time series data - perfect for trend/seasonal analysis
- ✅ Multiple dimensions - supports complex SQL queries
- ✅ Real-world relevance - genuine urban planning use case
- ✅ Meets 3NF normalization requirements

**Critical Gap**:
- ⚠️ **Cannot directly join** population ↔ traffic data (missing geographic link)
- ✅ **Solution**: 1-2 hours manual mapping work (109 stations to districts)

**Data Source Count**: 3-4 sources (meets "2+ independent sources" requirement)

---

## Key Findings

### 1. Database Schema - READY ✅

See `database_schema_design.sql` for complete schema with:
- **8 Dimension Tables**: Gender, Age, Origin, Districts, Quarters, Time, Stations, Measurement Points
- **2 Fact Tables**: Population, Traffic (combined 2M+ rows)
- **1 Bridge Table**: Station-to-District mapping (MUST BE CREATED)
- **3 Staging Tables**: For ETL process
- **2 Aggregate Tables**: For query performance
- **Views**: Pre-built analytical views

### 2. Foreign Keys - ANALYZED ✅

**Direct Joins (Work Automatically)**:
```
Population Data:
├── QuarCd → DimQuartier ✅
├── KreisCd → DimKreis ✅  
├── SexCd → DimGender ✅
├── AlterCd → DimAgeGroup ✅
└── DateKey → DimTime ✅

Traffic Data:
├── ZSID → DimTrafficStation ✅
├── MSID → DimMeasurementPoint ✅
└── DateKey → DimTime ✅
```

**Indirect Join (NEEDS BRIDGE TABLE)** ⚠️:
```
Population ←→ Traffic
    ❌ No direct key
    ✅ Solution: BridgeStationQuartier
        Maps: ZSID → QuarCd
```

### 3. External Data - NOT REQUIRED (but optional) ✅

**Minimum Viable Project**:
- ❌ No external data required
- ✅ Manual mapping table (1-2 hours work)

**Enhanced Project** (optional):
- ✅ Zürich district boundaries GeoJSON (500KB, free download)
- ✅ Enables automated spatial join
- ✅ URL: https://data.stadt-zuerich.ch/dataset/geo_statistische_quartiere

**Recommendation**: Start without external data, add GeoJSON only if time permits in Week 2-3.

---

## Project Timeline (6 Weeks)

### **Week 1: Setup & Schema** (10-12 hours)
**Goal**: Database infrastructure ready

**Tasks**:
- [ ] Set up VM server (Lab Services)
- [ ] Install MySQL + Workbench (following lab guide)
- [ ] Create database schema (`database_schema_design.sql`)
- [ ] Load raw data into staging tables
- [ ] **CRITICAL**: Create station-district mapping (divide among 4 people)
  - Person 1: Z001-Z027 (30 min)
  - Person 2: Z028-Z054 (30 min)
  - Person 3: Z055-Z081 (30 min)
  - Person 4: Z082-Z110 (30 min)

**Deliverables**:
- Running MySQL server accessible via VPN
- All staging tables loaded with data
- BridgeStationQuartier table populated

**Division of Labor**:
- Person 1 & 2: Server setup + data loading
- Person 3 & 4: Schema creation + mapping work

---

### **Week 2: ETL & Transformations** (8-10 hours)
**Goal**: Clean data in normalized tables

**Tasks**:
- [ ] Extract dimensions from staging (Gender, Age, Origin, Districts, Time)
- [ ] Transform and load fact tables (Population, Traffic)
- [ ] Create derived time dimension (holidays, weekends)
- [ ] Validate data quality (counts, nulls, duplicates)
- [ ] Create aggregate tables

**Deliverables**:
- All dimension tables populated
- Fact tables with 2M+ rows loaded
- ETL SQL scripts documented

**Division of Labor**:
- All 4: Pair programming on ETL (2 pairs)

---

### **Week 3: Analysis Queries** (10-12 hours)
**Goal**: 8+ keyword SQL queries for decision support

**Required Analysis Examples**:
```sql
-- 1. Population Growth Trend by District (2020-2024)
SELECT 
    q.QuarLang,
    YEAR(t.FullDate) AS Year,
    SUM(f.AnzBestWir) AS TotalPopulation,
    LAG(SUM(f.AnzBestWir)) OVER (PARTITION BY q.QuarLang ORDER BY YEAR(t.FullDate)) AS PrevYear,
    ROUND((SUM(f.AnzBestWir) - LAG(SUM(f.AnzBestWir)) OVER (PARTITION BY q.QuarLang ORDER BY YEAR(t.FullDate))) 
          / LAG(SUM(f.AnzBestWir)) OVER (PARTITION BY q.QuarLang ORDER BY YEAR(t.FullDate)) * 100, 2) AS GrowthRate
FROM FactPopulation f
JOIN DimQuartier q ON f.QuarCd = q.QuarCd
JOIN DimTime t ON f.DateKey = t.DateKey
WHERE t.Year >= 2020
GROUP BY q.QuarLang, YEAR(t.FullDate)
HAVING SUM(f.AnzBestWir) > 1000
ORDER BY GrowthRate DESC
LIMIT 10;
-- Keywords: SELECT, FROM, JOIN, ON, WHERE, GROUP BY, HAVING, ORDER BY, LIMIT, 
--           LAG, OVER, PARTITION BY, SUM, ROUND (15 keywords ✅)

-- 2. Traffic Per Capita by District (2024)
SELECT 
    q.QuarLang AS District,
    AVG(pop.AnzBestWir) AS AvgPopulation,
    SUM(t.AnzFahrzeuge) AS TotalTraffic,
    ROUND(SUM(t.AnzFahrzeuge) / AVG(pop.AnzBestWir), 2) AS TrafficPerCapita
FROM FactTraffic t
JOIN DimMeasurementPoint mp ON t.MSID = mp.MSID
JOIN BridgeStationQuartier bsq ON mp.ZSID = bsq.ZSID
JOIN DimQuartier q ON bsq.QuarCd = q.QuarCd
LEFT JOIN FactPopulation pop ON q.QuarCd = pop.QuarCd AND YEAR(t.MessungDatZeit) = 2024
WHERE t.AnzFahrzeugeStatus = 'Gemessen' AND bsq.QuarCd IS NOT NULL
GROUP BY q.QuarLang
ORDER BY TrafficPerCapita DESC;
-- Keywords: SELECT, FROM, JOIN, LEFT JOIN, ON, WHERE, GROUP BY, ORDER BY,
--           SUM, AVG, ROUND, YEAR (12 keywords ✅)

-- 3. Hourly Traffic Patterns (Weekday vs Weekend)
SELECT 
    t.HourOfDay,
    CASE WHEN dt.IsWeekend THEN 'Weekend' ELSE 'Weekday' END AS DayType,
    AVG(t.AnzFahrzeuge) AS AvgVehicles,
    STDDEV(t.AnzFahrzeuge) AS StdDev
FROM FactTraffic t
JOIN DimTime dt ON t.DateKey = dt.DateKey
WHERE t.AnzFahrzeugeStatus = 'Gemessen'
GROUP BY t.HourOfDay, dt.IsWeekend
ORDER BY DayType, t.HourOfDay;
-- Keywords: SELECT, FROM, JOIN, ON, WHERE, GROUP BY, ORDER BY,
--           CASE, WHEN, THEN, ELSE, END, AVG, STDDEV (14 keywords ✅)
```

**Deliverables**:
- 5-8 complex analytical queries
- Each query 8+ keywords
- Results exported to CSV for visualization

**Division of Labor**:
- Each person: 2 queries
- Peer review each other's work

---

### **Week 4: Performance Optimization** (8-10 hours)
**Goal**: 3+ optimization techniques with measurable improvement

**Required Optimizations**:
1. **Indexing**:
   ```sql
   CREATE INDEX idx_pop_date_quartier ON FactPopulation(DateKey, QuarCd);
   CREATE INDEX idx_traffic_datetime ON FactTraffic(MessungDatZeit);
   CREATE INDEX idx_traffic_station_date ON FactTraffic(MSID, DateKey);
   ```

2. **Partitioning** (optional, advanced):
   ```sql
   -- Partition traffic by year
   ALTER TABLE FactTraffic 
   PARTITION BY RANGE (YEAR(MessungDatZeit)) (
       PARTITION p2024 VALUES LESS THAN (2025)
   );
   ```

3. **Materialized Views** (simulated):
   ```sql
   -- Create aggregate table
   CREATE TABLE AggPopulationMonthly AS
   SELECT QuarCd, YEAR(t.FullDate) AS Year, MONTH(t.FullDate) AS Month,
          SexCd, SUM(AnzBestWir) AS TotalPopulation
   FROM FactPopulation f
   JOIN DimTime t ON f.DateKey = t.DateKey
   GROUP BY QuarCd, YEAR(t.FullDate), MONTH(t.FullDate), SexCd;
   ```

4. **Query Rewriting**:
   - Subquery → JOIN optimization
   - Derived table elimination

**Measurement**:
```sql
-- Before optimization
SET profiling = 1;
SELECT ... -- your slow query
SHOW PROFILES;

-- After optimization (index/aggregate table)
SELECT ... -- optimized query
SHOW PROFILES;

-- Document: 2.4s → 0.3s (8x faster) ✅
```

**Deliverables**:
- 3+ optimization techniques implemented
- Before/after execution times documented
- Screenshots of EXPLAIN output

**Division of Labor**:
- Person 1 & 2: Indexing + measurement
- Person 3 & 4: Aggregate tables + query rewriting

---

### **Week 5: Visualization & Decision Rule** (8-10 hours)
**Goal**: Metabase dashboard with interactive parameters

**Tasks**:
- [ ] Install Metabase on VM server
- [ ] Connect to MySQL database
- [ ] Create dashboards:
  - Population growth trends (line chart)
  - Traffic heatmap (hour x day)
  - District comparison (bar chart)
  - Combined traffic-per-capita metric (map or bars)
- [ ] Add filters: Date range, District, Age group
- [ ] Define decision rule with thresholds

**Decision Rule Example**:
```
KEY FIGURE: Infrastructure Priority Score
= (Population Growth Rate × 0.4) + (Traffic per Capita × 0.6)

RULE:
IF Priority Score > 80 THEN "HIGH - Invest in public transport"
ELSIF Priority Score > 50 THEN "MEDIUM - Monitor trends"
ELSE "LOW - Maintain current infrastructure"

APPLY TO: Fictitious urban planner selecting district for 2026 budget
```

**Deliverables**:
- 3-4 interactive dashboards
- Screenshots in report
- Access credentials for evaluators

**Division of Labor**:
- Person 1 & 2: Dashboard design + SQL queries
- Person 3 & 4: Decision rule implementation + user scenario

---

### **Week 6: Report Writing** (12-15 hours)
**Goal**: 30-40 page report following template

**Template Sections** (from `3 Template Project Report DBM.docx`):
1. Introduction & Context (2-3 pages)
2. Project Idea & Use Case (3-4 pages)
3. Data Model & Database Schema (5-6 pages)
   - Source data analysis with examples
   - ER diagram (conceptual model)
   - DDL code (physical schema)
4. Loading & Transforming Data (4-5 pages)
   - ETL process description
   - LOAD DATA INFILE examples
   - Transformation SQL
5. Analyzing & Evaluating Data (6-8 pages)
   - All analytical queries with results
   - Interpretation of findings
6. Efficiency & Query Performance (4-5 pages)
   - Optimization techniques
   - Before/after measurements
7. Visualization & Decision Support (5-6 pages)
   - Dashboard screenshots
   - Decision rule application
   - User scenario walkthrough
8. Conclusions & Lessons Learned (3-4 pages)
   - 4 required insights (database, project mgmt, teamwork, AI tools)

**Division of Labor**:
- Person 1: Sections 1-2 + final editing
- Person 2: Sections 3-4 + SQL code review
- Person 3: Sections 5-6 + screenshot capture
- Person 4: Sections 7-8 + formatting

---

## Critical Success Factors

### ✅ Must-Haves (Pass/Fail)
1. **Online accessible MySQL server** with provided credentials
2. **BridgeStationQuartier** table populated (enables combined analysis)
3. **8+ SQL keyword queries** that actually calculate decision metrics
4. **3+ documented optimizations** with measurable improvements
5. **Interactive Metabase dashboard** with working parameters
6. **Report < 40 pages** submitted on time

### ⚠️ Common Pitfalls to Avoid
1. ❌ Skipping the station-district mapping → cannot combine datasets
2. ❌ Waiting until Week 5 to start report → time crunch
3. ❌ Optimizing trivial queries → no measurable improvement
4. ❌ Complex visualizations → focus on clarity over beauty
5. ❌ Not documenting AI tool usage → required for evaluation

---

## Time-Saving Strategies

### Quick Wins
1. **Use provided infrastructure** (Lab Services VM) → saves 2-3 days
2. **Manual mapping** instead of spatial join → saves 2-4 hours
3. **Reuse course SQL patterns** → saves 3-5 hours
4. **Template-based report** → saves 5-8 hours
5. **Pair programming** → faster debugging, shared knowledge

### Automation Opportunities
1. **ETL Scripts**: Write once, run many times for testing
2. **Data Quality Checks**: SQL scripts for validation
3. **Performance Tests**: Bash script to run all queries with timing
4. **Report Generation**: SQL→CSV→Excel→Charts (semi-automated)

### Parallel Work Streams
- **Week 1-2**: Schema (2 people) || Data Loading (2 people)
- **Week 3**: Analysis queries (all 4, independent tasks)
- **Week 4**: Optimization (2 pairs, different techniques)
- **Week 6**: Report writing (4 sections, parallel work)

---

## Risk Assessment & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Station mapping incomplete | HIGH | Low | Divide work clearly, 30 min each |
| Server crashes before demo | HIGH | Medium | Weekly backups, document everything |
| Query performance too slow | MEDIUM | Medium | Start optimization in Week 3, not Week 4 |
| Metabase connection issues | MEDIUM | Low | Test connection Week 4, troubleshoot early |
| Report page limit exceeded | LOW | Medium | Write concisely, use appendices for code |

---

## Resources & References

### Provided Files
- ✅ `database_schema_design.sql` - Complete DDL ready to execute
- ✅ `KEY_MATCHING_ANALYSIS.md` - Deep dive into join problem & solutions
- ✅ `MANUAL_MAPPING_GUIDE.md` - Step-by-step mapping instructions
- ✅ `PROJECT_ACTION_PLAN.md` - This file

### External Tools
- **Map Viewer**: https://map.geo.admin.ch (for coordinate lookup)
- **MySQL Workbench**: https://dev.mysql.com/downloads/workbench/
- **Metabase**: https://www.metabase.com/docs/latest/
- **VPN**: HSLU Pulse Secure (campus network access)

### Documentation
- **Lab Guide**: `2 Database Project Virtual Machine Infrastructure Lab Services.pdf`
- **Requirements**: `Module Examinations FS25 students.pdf`
- **Report Template**: `3 Template Project Report DBM.docx`

---

## Next Steps (This Week)

### Immediate Actions (Next 3 Days)
1. [ ] **Reserve VM server** via ILIAS Excel sheet (all 4 team members add names)
2. [ ] **Install VPN** and test university network connection
3. [ ] **Connect to VM** via Remote Desktop (one person first, then all)
4. [ ] **Install MySQL** following lab guide (together or Person 1 leads)

### By End of Week 1
5. [ ] **Execute schema creation**: Run `database_schema_design.sql`
6. [ ] **Load CSV files** into staging tables (LOAD DATA INFILE)
7. [ ] **Complete station mapping**: 4 people × 30 min each = 2 hours total
8. [ ] **First checkpoint**: Can you join population + traffic data via bridge table?

### Success Metrics (Week 1)
- ✅ All 4 team members can access VM
- ✅ MySQL running with all tables created
- ✅ Staging tables loaded (2M+ rows)
- ✅ BridgeStationQuartier has ~90+ mapped stations
- ✅ Can run a simple query joining population + traffic

---

## Summary

**Your datasets ARE SUITABLE** for this project with **one manageable task**: creating the station-to-district mapping (1-2 hours total team effort).

**Key Advantages**:
- ✅ Large data volume (great for optimization demos)
- ✅ Real-world relevance (actual Zürich open data)
- ✅ Natural time series analysis opportunities
- ✅ Clear urban planning use case
- ✅ No external dependencies required

**Success Formula**:
1. Complete station mapping early (Week 1) ← **CRITICAL**
2. Follow timeline (don't skip optimization week)
3. Divide work clearly (4 people × clear tasks)
4. Start report incrementally (don't wait until Week 6)
5. Test Metabase connection early (Week 4, not Week 5)

**Confidence Level**: 85% - You can successfully complete this project with these datasets! 🎯

---

## Questions?

Before proceeding, ensure clarity on:
- [ ] Do we understand why station-district mapping is needed?
- [ ] Are we comfortable with 1-2 hours manual work?
- [ ] Is the timeline realistic given other courses?
- [ ] Does everyone understand their Week 1 tasks?

If yes to all → **You're ready to start!** 🚀

---

_Document created: 2024  
Last updated: [Current Date]  
For: DBM Database Project FS25  
Team: [Your Team Name]_
