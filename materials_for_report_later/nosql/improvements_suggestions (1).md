# DBM Project: Problems & Improvements

This document identifies issues, improvements, and low-hanging fruit for Team ACID's DBM project report.

---

## 🚨 CRITICAL ISSUES

### Critical Issue 1: Missing NoSQL Requirement

### The Problem
The project assignment explicitly requires NoSQL implementation in Section 6:
- Connect Metabase to **both** SQL and NoSQL databases
- Show interactive visualization for **both** SQL and NoSQL
- Demonstrate that SQL and NoSQL outputs are **the same**

Your report has **zero NoSQL content**. This is probably the biggest point deduction risk.

### The Solution: MongoDB (Easiest Option)

Since you have CSVs and limited NoSQL experience, MongoDB is your best choice because:
1. You can directly import CSVs with one command
2. Query syntax is relatively intuitive
3. Metabase has built-in MongoDB support

### Step-by-Step MongoDB Implementation

#### Step 1: Install MongoDB on your VM
```bash
# On your Windows VM, download MongoDB Community Server
# Or use MongoDB Atlas (free cloud tier) - even easier
```

#### Step 2: Import your CSVs into MongoDB
```bash
# Import traffic data
mongoimport --db traffic_population_zh --collection traffic_measurements --type csv --headerline --file traffic_data_cleaned_final.csv

# Import population data  
mongoimport --db traffic_population_zh --collection population --type csv --headerline --file population_data_cleaned_final.csv

# Import quarter data
mongoimport --db traffic_population_zh --collection quarters --type csv --headerline --file quarter_data_cleaned_final.csv
```

#### Step 3: Write equivalent queries for ONE KPI (minimum)
You don't need all KPIs in NoSQL - just demonstrate equivalence for at least one.

**Example: KPI 0 - City-level yearly traffic average**

SQL version (you have this):
```sql
SELECT YEAR(timestamp) AS year, AVG(vehicle_count) AS avg_count
FROM trafficmeasurement
GROUP BY YEAR(timestamp);
```

MongoDB equivalent:
```javascript
db.traffic_measurements.aggregate([
  {
    $group: {
      _id: { $year: "$timestamp" },
      avg_count: { $avg: "$vehicle_count" }
    }
  },
  { $sort: { "_id": 1 } }
])
```

#### Step 4: Connect Metabase to MongoDB
1. In Metabase Admin → Databases → Add Database
2. Select "MongoDB"
3. Enter connection details (host, port, database name)
4. Save and sync

#### Step 5: Create ONE visualization in Metabase from MongoDB
- Create a "Question" using the MongoDB data source
- Show the same KPI 0 chart
- Screenshot it

#### Step 6: Add to Report
Add a new section (maybe "6.2 NoSQL Implementation" or similar):

```markdown
## NoSQL Implementation with MongoDB

To demonstrate database technology flexibility, we implemented an equivalent 
analysis pipeline using MongoDB as a document-oriented NoSQL database.

### Data Loading
The cleaned CSV files were imported into MongoDB using mongoimport...

### Equivalent Query: KPI 0 Citywide Traffic Trend
[Show the MongoDB aggregation query]

### Metabase Connection
[Screenshot of MongoDB connection in Metabase]

### Visualization Comparison
[Side-by-side screenshots showing SQL and MongoDB produce the same results]

The outputs are identical, confirming that our analytical logic is 
database-agnostic and could be deployed on either SQL or NoSQL infrastructure.
```

**Time estimate**: 2-4 hours if MongoDB is new to you, 1-2 hours if you've seen it before.

---

### Critical Issue 2: Missing Parameterized Queries in Metabase

**The Problem**

The requirement explicitly states:
> "Display the analysis results interactively in the BI tool using database queries, **i.e., with parameters**"

Your current Metabase screenshots show static dashboards. There's no demonstration of:
- User-selectable filters (e.g., choose a year, choose a district)
- Parameter inputs that change the visualization
- Interactive drill-down capabilities

**The Solution** (30-60 minutes):

#### Step 1: Add a Filter to Your Dashboard
In Metabase, go to your KPI 1 visualization (Stress Index by District):
1. Click "Edit dashboard"
2. Click "Add a filter" → Choose "ID" or "Category"
3. Map it to `city_district` column
4. Save the dashboard

Now users can filter to see only specific districts.

#### Step 2: Create a Parameterized Question
Create a new "Question" in Metabase with a variable:
```sql
SELECT * FROM v_kpi1_quarter_stress_index_new
WHERE city_district = {{district_filter}}
```

When you type `{{district_filter}}`, Metabase automatically creates a parameter input.

#### Step 3: Screenshot the Interactivity
Take screenshots showing:
1. The filter dropdown in the dashboard
2. The result changing when a different filter value is selected

#### Step 4: Add to Report
In Section 11 (Visualization), add:

```markdown
### Interactive Dashboard Features

The Metabase dashboard supports interactive exploration through parameterized 
filters. Users can select specific districts or time periods to focus the 
analysis on areas of interest.

[Screenshot: Dashboard with district filter dropdown visible]

Figure X shows the stress index filtered to District 5 (Industriequartier). 
This interactivity allows urban planners to drill down into specific areas 
without requiring SQL knowledge.
```

---

### Critical Issue 3: Missing Raw Data Examples

**The Problem**

The requirement states:
> "Analyze the structure and content of the source data **using data examples**"

You describe column names and types well, but you don't show actual sample rows from the raw data. A professor wants to see: "Here's what 3 rows of the original CSV look like."

**The Solution** (15 minutes):

Add a small sample data table in Chapter 3 after describing each dataset.

**Example for Traffic Data** (add after line ~74):

```markdown
### Sample Raw Data

The following excerpt shows three representative rows from the raw traffic CSV:

| MSID | MSName | ZSID | ZSName | MessungDatZeit | AnzFahrzeuge | AnzFahrzeugeStatus |
|------|--------|------|--------|----------------|--------------|-------------------|
| M001 | Unknown | Z123 | Seestrasse | 2023-05-15T08:00:00 | 342 | Measured |
| M001 | Unknown | Z123 | Seestrasse | 2023-05-15T09:00:00 | 456 | Measured |
| M002 | Unknown | Z124 | Hardbrücke | 2023-05-15T08:00:00 | 891 | Measured |

These raw records illustrate the hourly measurement granularity and the 
relationship between measurement sites (MSID) and counting sites (ZSID).
```

Do the same for Population and Quarter datasets - just 2-3 sample rows each.

---

### Critical Issue 4: Missing Data Source URLs

**The Problem**

You mention "opendata.ch" and "City of Zurich's open data portal" but don't provide the **exact URLs** to your datasets. The project assignment shows example URLs like `https://data.stadt-zuerich.ch/dataset/...` - you should cite these properly.

**The Solution** (10 minutes):

Add a "Data Sources" subsection in Chapter 3:

```markdown
## Data Sources

The following open data sources were used in this project:

1. **Traffic Count Data (MIV Verkehrszählung)**  
   URL: https://data.stadt-zuerich.ch/dataset/sid_dav_verkehrszaehlung_miv_od2031  
   Description: Hourly vehicle counts from automated counting sites since 2012

2. **Population Data (Bevölkerungsbestand)**  
   URL: https://data.stadt-zuerich.ch/dataset/bev_monat_bestand_quartier_geschl_ag_herkunft_od3250  
   Description: Monthly population by district, quarter, sex, and origin

3. **Quarter/Address Data**  
   URL: [your actual URL]  
   Description: Geographic mapping of addresses to statistical quarters

These three datasets represent independent data collection processes maintained 
by different departments of the City of Zurich, satisfying the requirement for 
2+ independent but integrable data sources.
```

---

### Critical Issue 5: Missing Fictitious User Scenario

**The Problem**

The requirement explicitly states:
> "The decision rule is applied to a **(fictitious) user** based on the key figure in order to positively influence a decision in the use case."

And:
> "**Use a user to demonstrate** how the visualization improves a specific decision with data."

Your report has general recommendations ("Direct investments toward commuter-pressure zones...") but doesn't show a **concrete user scenario** walking through the decision process step-by-step.

**The Solution** (20 minutes):

Add a subsection in Chapter 11 (after the KPI visualizations):

```markdown
### Decision Scenario: Urban Planner Budget Allocation

To demonstrate how the dashboard supports real decisions, consider the following 
scenario:

**User:** Sarah, Senior Traffic Planner at the Zurich Urban Planning Department

**Task:** Allocate CHF 2 million in traffic infrastructure budget for 2026

**Decision Process using the Dashboard:**

1. Sarah opens the Metabase dashboard and reviews the **Stress Index Classification** 
   (Figure X). She identifies that **Enge (District 2)** shows a stress index of 
   +150.2%, classified as "Commuter Pressure."

2. According to the decision rule (Stress Index > +10% = High commuter pressure), 
   this district requires capacity expansion or traffic management measures.

3. Sarah then examines the **Peak-Hour Bottlenecks** visualization and finds that 
   **Tessinerplatz** in District 2 has an average peak volume of 1,847 vehicles/hour 
   at 17:00, well above the 700 threshold.

4. **Decision:** Sarah allocates CHF 800,000 to signal optimization at Tessinerplatz 
   and CHF 400,000 for a park-and-ride feasibility study at the district boundary.

5. **Outcome:** The data-driven approach ensures budget is directed to the highest-
   impact areas rather than relying on intuition or political pressure.

This scenario illustrates how the KPI framework transforms raw traffic data into 
actionable budget decisions.
```

---

### Critical Issue 6: Missing Explicit SQL Keyword Count

**The Problem**

The requirement states:
> "The SQL query should contain at least **8 different keywords**"

Your queries clearly use many keywords (SELECT, FROM, JOIN, WHERE, GROUP BY, ORDER BY, CASE, WHEN, WITH, SUM, AVG, ROW_NUMBER, OVER, PARTITION BY, etc.) but you **never explicitly list or count them** to show you meet the requirement.

**The Solution** (10 minutes):

Add a brief note in Section 7 (Analyzing & Evaluating Data) after presenting a complex query:

```markdown
### SQL Complexity Analysis

The KPI queries demonstrate appropriate complexity by utilizing the following 
SQL keywords and constructs:

1. **SELECT** - attribute selection
2. **FROM** - table specification  
3. **JOIN** - table combination (INNER JOIN, LEFT JOIN)
4. **WHERE** - row filtering with SARGable predicates
5. **GROUP BY** - aggregation grouping
6. **ORDER BY** - result sorting
7. **CASE/WHEN** - conditional logic for classification
8. **WITH** (CTE) - common table expressions for readability
9. **SUM/AVG** - aggregate functions
10. **ROW_NUMBER() OVER (PARTITION BY...)** - window functions
11. **ROUND/CAST** - type conversion and formatting

This exceeds the minimum requirement of 8 different keywords and demonstrates 
proficiency with advanced SQL constructs including CTEs and window functions.
```

---

### Critical Issue 7: Missing Conceptual-to-Physical Schema Mapping

**The Problem**

The requirement states:
> "Also show the **relationship between the conceptual model and the database schema**"

You have an ERD (Figure 2) and DDL code in appendices, but you don't explicitly show HOW the conceptual entities map to physical tables - especially where they differ.

**The Solution** (15 minutes):

Add a mapping table in Section 4 after the ERD description:

```markdown
### Mapping: Conceptual Model to Physical Schema

The following table shows how conceptual entities from the ER diagram correspond 
to physical database tables:

| Conceptual Entity | Physical Table | Key Differences |
|-------------------|----------------|-----------------|
| CountingSite | `countingsite` | `axis` column dropped due to inconsistent values |
| MeasurementSite | `measurementsite` | No changes |
| TrafficMeasurement | `trafficmeasurement` | Added surrogate key `traffic_measurement_id` |
| TrafficSignal | `trafficsignal` | No changes |
| Quarter | `quarter` | `street_name` used as PK instead of composite key |
| Population | `population` | No surrogate key (natural composite key) |
| Sex | `sex` | Lookup table extracted from Population |
| Origin | `origin` | Lookup table extracted from Population |

**Key design decisions:**
- Surrogate keys added to fact tables for efficient row identification
- Lookup tables normalized from repeated categorical values
- Some FK constraints not enforced for ETL performance (documented in code)
```

---

### Critical Issue 5: Missing Fictitious User Scenario Walkthrough

**The Problem**

The requirement explicitly states:
> "Demonstrate in a practical way how the visualization and the original use case are related: **Use a user to demonstrate** how the visualization improves a specific decision with data."
> "The decision rule is **applied to a (fictitious) user** based on the key figure in order to positively influence a decision in the use case."

Your report has generic "client recommendations" but no concrete user scenario showing step-by-step how someone would use the dashboard to make a decision.

**The Solution** (20 minutes):

Add a concrete scenario in Section 11 (Visualization):

```markdown
### Decision Scenario: Budget Allocation for District 2

To demonstrate practical decision support, consider the following scenario:

**User:** Maria Keller, Urban Planning Analyst at Stadt Zürich
**Task:** Allocate CHF 5M infrastructure budget across districts

**Step 1: Identify Problem Areas**
Maria opens the Metabase dashboard and views the Stress Index Classification 
(Figure X). She immediately sees District 2 (Enge) flagged as "Commuter Pressure" 
with a Stress Index of +150.2%.

[Screenshot: Dashboard showing District 2 highlighted]

**Step 2: Apply Decision Rule**
Based on the predefined decision rule:
- Stress Index > +10% → High commuter pressure → Invest in inbound capacity

**Step 3: Drill Down**
Maria filters KPI 2 (Bottlenecks) to District 2 and identifies Brunaustrasse 
as a peak-hour bottleneck (avg. 892 vehicles/hour at 17:00).

[Screenshot: Filtered bottleneck view]

**Step 4: Decision**
Maria recommends:
- Short-term: Signal optimization at Brunaustrasse intersection (CHF 200K)
- Long-term: Park-and-ride facility at district boundary (CHF 2M)

This data-driven approach replaced subjective prioritization with quantifiable 
metrics, improving budget allocation efficiency.
```

This satisfies the requirement for a fictitious user demonstration with specific dashboard interactions.

---

## ⚠️ Medium Priority Issues

### Issue 1: No Metabase Configuration Screenshot

**Problem**: The requirements ask to "Display the configuration you are using" for Metabase. You mention Metabase but don't show the actual connection configuration.

**Fix** (5 minutes):
1. Go to Metabase Admin → Databases
2. Screenshot the MySQL connection settings (hide password)
3. Add to report in Section 11 before the dashboards:

```markdown
### Metabase Configuration

Metabase was connected to the MySQL database using the following configuration:

[INSERT SCREENSHOT: metabase_connection_config.png]

The connection uses the university VM's internal IP address with read-only 
credentials to ensure dashboard stability.
```

---

### Issue 2: Conceptual-to-Physical Model Mapping Not Explicit

**Problem**: The requirement states:
> "Also show the relationship between the conceptual model and the database schema."

You have both an ERD (conceptual) and DDL (physical), but you don't explicitly show how they map to each other or explain any differences.

**Fix** (15 minutes):

Add a subsection in Chapter 4 after the ERD:

```markdown
### Mapping from Conceptual Model to Physical Schema

The following table shows how each conceptual entity maps to its physical 
implementation in MySQL:

| Conceptual Entity | Physical Table | Key Differences |
|-------------------|----------------|-----------------|
| CountingSite | countingsite | `axis` column dropped due to inconsistent values |
| MeasurementSite | measurementsite | No changes |
| TrafficMeasurement | trafficmeasurement | Added surrogate key `traffic_measurement_id` |
| Quarter | quarter | `street_name` used as natural primary key |
| Population | population | No surrogate key; composite natural key |
| Sex | sex | Lookup table extracted from population |
| Origin | origin | Lookup table extracted from population |
| TrafficSignal | trafficsignal | No changes |

The physical schema closely follows the conceptual model, with minor adjustments 
for performance (surrogate keys) and data quality (dropped columns).
```

---

### Issue 3: SQL Keywords Not Explicitly Listed

**Problem**: The requirement states queries should contain "at least 8 different keywords." Your queries clearly have 8+, but you don't explicitly list which keywords you use.

**Fix** (5 minutes):

Add to Section 7 (Database Analysis) after showing a KPI query:

```markdown
### SQL Keyword Coverage

The KPI queries demonstrate comprehensive SQL usage with the following keywords:

1. SELECT - attribute selection
2. FROM - table specification  
3. JOIN - table relationships (INNER, LEFT)
4. WHERE - row filtering
5. GROUP BY - aggregation grouping
6. ORDER BY - result ordering
7. AVG, SUM, COUNT - aggregate functions
8. CASE WHEN - conditional logic
9. WITH (CTE) - common table expressions
10. OVER, PARTITION BY - window functions
11. ROW_NUMBER, NTILE - ranking functions
12. ROUND, CAST - type conversion

This exceeds the minimum requirement of 8 keywords and demonstrates 
advanced SQL capabilities including window functions and CTEs.
```

---

### Issue 4: 3+ Optimization Approaches Not Clearly Listed

**Problem**: The requirement asks for "3+ database approaches" for optimization. You use 3+ approaches but don't list them explicitly.

**Fix** (5 minutes):

Add to the beginning of Section 8 (Optimization):

```markdown
## Optimization Strategy

Three complementary optimization approaches were applied:

1. **Targeted Indexing** - Created composite and single-column indexes on 
   high-cardinality filter columns (timestamp, measurement_site_id)
   
2. **SARGable Query Rewrites** - Replaced non-indexable predicates like 
   `YEAR(timestamp)` with range conditions `timestamp >= '2023-01-01'`
   
3. **Materialized Aggregation Tables** - Pre-computed expensive aggregations 
   into dedicated tables to avoid repeated full-table scans

These three approaches reduced query execution time from several minutes 
to under 5 seconds.
```

---

### Issue 5: Before/After Optimization Comparison Could Be Stronger

**Problem**: You mention "minutes to seconds" but the Visual EXPLAIN screenshot only shows the "after" state. The requirements ask to "Analyze execution plans **before and after** optimization."

**Fix** (15-30 minutes):
1. Temporarily remove one of your indexes:
   ```sql
   DROP INDEX idx_tm_timestamp ON TrafficMeasurement;
   ```
2. Run EXPLAIN on a KPI query and screenshot it (showing full table scan)
3. Recreate the index
4. You already have the "after" screenshot

Add to Section 8.2:
```markdown
### Before Optimization
[Screenshot showing type=ALL, full table scan]

The execution plan before optimization shows a full table scan (type=ALL) 
across 21 million rows, resulting in execution times of X minutes.

### After Optimization  
[Your existing screenshot]

After adding targeted indexes, the execution plan shows indexed access 
(type=range/ref), reducing execution time to X seconds.
```

---

### Issue 3: Execution Time Numbers Are Vague

**Problem**: You say "minutes to seconds" but don't give specific numbers. Concrete measurements are more convincing.

**Fix** (10 minutes):
Run your heaviest query with timing:
```sql
SET profiling = 1;
SELECT * FROM v_kpi2_bottlenecks;
SHOW PROFILES;
```

Or simply note the "Duration" shown in MySQL Workbench.

Update the text to say something like:
> "Query execution time improved from **4 minutes 23 seconds** to **3.2 seconds** after optimization."

---

## 📝 Writing & Formatting Improvements

### Issue 4: Some Typos and Grammar Issues

**Location**: Throughout, but especially in Section 11

**Examples found**:
- "infraestructure" → "infrastructure" (Section 11, KPI 2 decision recommendation)
- "cpaacity" → "capacity" (same location)
- "Direcional" → "Directional" (Section 11, KPI 3 header)
- "assisting material" → "supporting material" (Chapter 14)

**Fix**: Do a spell-check pass on the final PDF, or run the text through a grammar checker.

---

### Issue 5: Inconsistent Capitalization

**Problem**: Sometimes "Metabase" sometimes "metabase", sometimes "MySQL" sometimes "mysql"

**Fix**: Search and replace to ensure consistent capitalization:
- MySQL (always capitalized)
- Metabase (always capitalized)  
- SQL (always uppercase)
- NoSQL (capital N, capital SQL)

---

### Issue 6: Chapter 14 (AI Declaration) Appears Twice

**Problem**: Looking at your RMD structure, "Generative AI Declaration & Guidelines" appears at line 1157 AND potentially as a separate consideration. The individual reflections (Chapter 13) come before the AI declaration, which is slightly odd structurally.

**Fix**: Consider reordering to:
1. Conclusions & Lessons Learned (Chapter 12)
2. Generative AI Declaration (Chapter 13) 
3. Individual Team Member Reflections (Chapter 14)
4. Appendices

This puts the formal declaration before the personal reflections, which flows better.

---

### Issue 7: Some HTML Line Breaks in RMarkdown

**Problem**: You use `<br>` tags in several places (e.g., lines 1024, 1026, 1033, 1049). These work but are not ideal for PDF output.

**Fix**: Replace `<br>` with either:
- Two spaces at end of line + newline (for soft break)
- Blank line (for paragraph break)
- `\newline` or `\vspace{0.3cm}` for LaTeX-style breaks in PDF

---

## 🎯 Low-Hanging Fruit (Quick Wins)

### Quick Win 1: Add GitHub Link Visibility
**Current**: GitHub link is in title page subtitle
**Improvement**: Also mention it in the report body, perhaps in "System Access and Verification" section:

```markdown
All SQL scripts, ETL code, and documentation are version-controlled and 
available at: https://github.com/dydy2010/dbm_project_ACID
```

This makes it more visible for evaluators who might miss the title page.

---

### Quick Win 2: Number Your Appendices Consistently

**Current**: Appendices are titled "Appendix A:", "Appendix B:", etc.
**Improvement**: Add them to the table of contents by using proper RMarkdown headers:

```markdown
# Appendix A: Traffic Data – Complete ETL Script {-}
```

The `{-}` prevents numbering conflicts with main chapters.

---

### Quick Win 3: Add a "How to Reproduce" Section

**Why**: Evaluators appreciate being able to verify your work.

**Add to Section 2.1.1 or as a new subsection**:
```markdown
### Reproduction Steps

To reproduce the database and dashboards:

1. Connect to the VM using the credentials provided on ILIAS
2. Open MySQL Workbench and connect to `traffic_population_zh`
3. Access Metabase at [URL] with the provided login
4. SQL scripts are available in the GitHub repository under `/sql_scripts/`
```

---

### Quick Win 4: Add Figure/Table Cross-References

**Problem**: Figures are captioned but not always referenced in text.

**Example**: Figure 4 (tables1.png) is inserted but the preceding text just says "shown below" rather than "shown in Figure 4".

**Fix**: Update text to reference figures by number:
```markdown
The resulting schema in MySQL Workbench is shown in Figure 4.
```

This is more professional and helps if figures move during PDF compilation.

---

## 📊 Content Suggestions

### Suggestion 1: Quantify Your Data More

You mention "21 million rows" several times, which is great. Consider adding more specifics:

- How many counting sites? (e.g., "147 counting sites across Zurich")
- How many statistical quarters? (e.g., "34 statistical quarters")
- Date range covered? (e.g., "13 years of hourly data from 2012-2025")

These numbers help evaluators understand the scale.

---

### Suggestion 2: Add a Limitations Section

Academic reports benefit from acknowledging limitations. Consider adding to Chapter 12:

```markdown
## Limitations

- **Traffic data coverage**: Not all streets in Zurich have counting sites, 
  requiring imputation for some quarters
- **Temporal alignment**: Population data is quarterly while traffic data is 
  hourly, requiring aggregation decisions
- **Causality**: The Stress Index shows correlation between traffic and 
  population growth but cannot prove causation
```

This shows critical thinking and preempts evaluator questions.

---

### Suggestion 3: Reference the OECD Data Value Cycle More

**Problem**: The project assignment emphasizes the "OECD (2015) Data Value Cycle" as a key framework. You have a figure showing data landscape but don't explicitly mention or cite the Data Value Cycle in your text.

**Fix**: Add a paragraph showing how your project follows the cycle:
```markdown
Our project follows the OECD Data Value Cycle (OECD, 2015):
- **Data Collection**: Traffic counts, population records, geographic data
- **Big Data**: 21M+ records requiring scalable database design
- **Analytics**: SQL aggregations, KPI calculations, stress indices
- **Knowledge**: Identification of bottlenecks, pressure zones, directional patterns
- **Decisions**: Recommendations for infrastructure investment and traffic management
- **Value Added**: Improved urban planning efficiency for Zurich
```

Also add a simple reference at the end of your report:
```markdown
## References

OECD (2015). Data-Driven Innovation: Big Data for Growth and Well-Being. 
OECD Publishing, Paris.
```

---

### Suggestion 4: Add a References Section

**Problem**: The requirement mentions "valid source references" as part of formal criteria. Your report doesn't have a References/Bibliography section.

**Fix** (10 minutes):

Add before the Appendices:
```markdown
# References

City of Zurich Open Data Portal. Traffic counting data (MIV Verkehrszählung). 
https://data.stadt-zuerich.ch/dataset/sid_dav_verkehrszaehlung_miv_od2031

City of Zurich Open Data Portal. Population statistics. 
https://data.stadt-zuerich.ch/dataset/bev_monat_bestand_quartier_geschl_ag_herkunft_od3250

OECD (2015). Data-Driven Innovation: Big Data for Growth and Well-Being. 
OECD Publishing, Paris.

MySQL Documentation. LOAD DATA Statement. 
https://dev.mysql.com/doc/refman/8.0/en/load-data.html

Metabase Documentation. https://www.metabase.com/docs/latest/
```

---

## 📋 Final Checklist Before Submission

1. [ ] **Add NoSQL implementation** (CRITICAL - see detailed steps above)
2. [ ] **Add parameterized queries/filters in Metabase** (CRITICAL - show interactivity)
3. [ ] **Add fictitious user scenario walkthrough** (CRITICAL - step-by-step decision demo)
4. [ ] **Add raw data examples** (show 2-3 sample rows per dataset)
5. [ ] **Add data source URLs** (exact links to opendata.ch datasets)
6. [ ] **Add References section** (OECD, data sources, tools)
7. [ ] **Add conceptual-to-physical model mapping table**
8. [ ] **Add explicit SQL keyword list** (show 8+ keywords used)
9. [ ] **Add explicit optimization approaches list** (show 3+ approaches)
10. [ ] **Add Metabase configuration screenshot**
11. [ ] **Add before/after execution plan comparison**
12. [ ] **Add specific timing numbers for optimization**
13. [ ] **Fix typos**: infraestructure, cpaacity, Direcional
14. [ ] **Check page count** (max 40 pages excluding title, TOC, appendix)
15. [ ] **Verify all screenshots are included** and referenced
16. [ ] **Spell-check the entire document**
17. [ ] **Verify ILIAS credentials submission** is complete
18. [ ] **Test PDF renders correctly** (no broken images, correct formatting)

---

## Priority Summary

| Priority | Issue | Time to Fix |
|----------|-------|-------------|
| 🚨 Critical | NoSQL implementation missing | 2-4 hours |
| 🚨 Critical | Parameterized queries in Metabase missing | 30-60 minutes |
| 🚨 Critical | Raw data examples missing | 15 minutes |
| 🚨 Critical | Data source URLs missing | 10 minutes |
| 🚨 Critical | Fictitious user scenario walkthrough missing | 20 minutes |
| ⚠️ Medium | Metabase config screenshot | 5 minutes |
| ⚠️ Medium | Conceptual-to-physical model mapping | 15 minutes |
| ⚠️ Medium | SQL keywords not explicitly listed | 5 minutes |
| ⚠️ Medium | 3+ optimization approaches not clearly listed | 5 minutes |
| ⚠️ Medium | Before/after EXPLAIN comparison | 15-30 minutes |
| ⚠️ Medium | Specific timing numbers | 10 minutes |
| 📝 Low | Typos and grammar | 15 minutes |
| 📝 Low | Capitalization consistency | 5 minutes |
| 🎯 Quick Win | GitHub link visibility | 2 minutes |
| 🎯 Quick Win | Figure cross-references | 10 minutes |

**Total estimated time for all improvements**: 5-7 hours (mostly NoSQL + parameterized queries)

---

## Summary of Critical Gaps

Your report is **very strong** on:
- Database design and 3NF normalization
- SQL query complexity (CTEs, window functions, aggregations)
- Performance optimization documentation
- Business value and decision support
- Comprehensive ETL scripts in appendices

Your report is **missing or weak** on:
1. **NoSQL implementation** - explicitly required, completely absent
2. **Parameterized Metabase queries** - requirement says "with parameters"
3. **Fictitious user scenario** - need step-by-step walkthrough of dashboard usage
4. **Concrete data examples** - show actual rows, not just column descriptions
5. **Data source citations** - need exact URLs, not just "opendata.ch"
6. **Explicit requirement mapping** - keywords, optimization approaches, model mapping

Fixing these items would significantly strengthen your submission.

---

Good luck with the final submission! The SQL portion of your report is solid - address the critical gaps above and you'll have a comprehensive project.
