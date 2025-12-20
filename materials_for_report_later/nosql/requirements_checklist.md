# DBM Project Requirements Checklist

## Overview
This document maps all requirements from the DBM Project Assignment against Team ACID's report to verify completeness.

---

## 1. Plan Database Application

| Requirement | Status | Location in Report |
|-------------|--------|-------------------|
| Develop ideas for project to generate value from data | ✅ Fulfilled | Chapter 1 "Introduction & Context" + Chapter 2 "Project Idea & Use Case" |
| Data analysis should support decision-making (Data Value Cycle) | ✅ Fulfilled | Chapter 2, Chapter 11 "Visualization & Decision Support" |
| Specify which key figures can be determined based on which data | ✅ Fulfilled | Chapter 5 "Key Performance Indicators (KPIs)" - KPI 0-5 defined |
| Specify decision rules showing how data-based decision-making supports the use case | ✅ Fulfilled | KPI 1.5 Classification, KPI 2.3 Bottleneck Threshold, KPI 3.3 Classification, KPI 5 Actionable Insights |
| Combine at least 2 different/independent data sources | ✅ Fulfilled | Chapter 3 - Traffic data + Population data + Quarter data (3 sources) |
| Data sources properly cited with URLs | ⚠️ **Partial** | Mentions "opendata.ch" but no specific dataset URLs provided |

---

## 2. Define Database Structure

| Requirement | Status | Location in Report |
|-------------|--------|-------------------|
| Reverse engineer conceptual model from existing data | ✅ Fulfilled | Chapter 4 "Data Model & Database Schema" |
| Analyze structure and content using data examples | ⚠️ **Partial** | Column descriptions provided, but no actual sample rows from raw CSVs shown |
| Create conceptual ER model graphically | ✅ Fulfilled | Figure 2 - ERD diagram (erd_traffic.png) |
| Multiple entity types and relationships with attributes | ✅ Fulfilled | 8 entities: CountingSite, MeasurementSite, TrafficMeasurement, TrafficSignal, Quarter, Population, Sex, Origin |
| Implement physical schema in SQL DDL | ✅ Fulfilled | Chapter 6 "Loading & Transforming the Data" + Appendices A-D |
| Database schema in Third Normal Form (3NF) | ✅ Fulfilled | Explicitly stated in Chapter 4 + Chapter 6.2 |
| Show relationship between conceptual model and database schema | ✅ Fulfilled | Chapter 4 describes ERD, Figure 4 shows MySQL Workbench schema |
| Describe most important data in prose | ✅ Fulfilled | Chapter 3 - detailed column descriptions for all datasets |

---

## 3. Load and Transform Data

| Requirement | Status | Location in Report |
|-------------|--------|-------------------|
| Install MySQL with client-server architecture (server in cloud/VM) | ✅ Fulfilled | Section 2.1.1 "System Access and Verification" |
| Database accessible online for evaluator login | ✅ Fulfilled | "Access codes provided via ILIAS" |
| Disclose access data (URL, username, password) | ✅ Fulfilled | Referenced as submitted via ILIAS survey |
| Use ELT approach - first import data using LOAD command | ✅ Fulfilled | Chapter 6 + Appendices A-D show LOAD DATA LOCAL INFILE |
| Transform data within database using SQL (INSERT...SELECT) | ✅ Fulfilled | Appendices A-D show INSERT...SELECT transformations |
| Preprocessing possible if majority of transformation in database | ✅ Fulfilled | Python preprocessing documented in Chapter 3, SQL transformation in Chapter 6 |

---

## 4. Database Analysis

| Requirement | Status | Location in Report |
|-------------|--------|-------------------|
| Write at least one database query for use case insights | ✅ Fulfilled | Multiple queries: KPI 0, 1, 2, 3 views |
| SQL query contains at least 8 different keywords | ✅ Fulfilled | Queries contain: SELECT, FROM, JOIN, WHERE, GROUP BY, ORDER BY, AVG, SUM, CASE, WHEN, WITH (CTE), HAVING, ROW_NUMBER, OVER, PARTITION BY, etc. |
| - JOIN tables | ✅ Fulfilled | All KPI queries use JOINs |
| - Aggregation (e.g., AVG) | ✅ Fulfilled | AVG, SUM used throughout |
| - GROUP BY | ✅ Fulfilled | All KPI queries use GROUP BY |
| - WHERE filtering | ✅ Fulfilled | Date range filters, status filters |
| - SELECT attributes | ✅ Fulfilled | All queries |
| Describe in detail what query does and how it works | ✅ Fulfilled | Chapter 7 "Analyzing & Evaluating Data" - detailed explanations |
| Show how to calculate key figures defined in point 1 | ✅ Fulfilled | KPI definitions linked to SQL implementations |
| Show query results and discuss how they support use case | ✅ Fulfilled | Screenshots of results (Figure 3) + Chapter 11 interpretations |

---

## 5. Optimize Database Performance

| Requirement | Status | Location in Report |
|-------------|--------|-------------------|
| Indicate measures taken to optimize query speed | ✅ Fulfilled | Chapter 8 "Query Performance Optimization" |
| Use 3+ database approaches to increase execution speed | ✅ Fulfilled | 1) Targeted indexes, 2) SARGable predicates, 3) Materialized tables |
| Analyze execution plans before and after optimization | ✅ Fulfilled | Section 8.2 "Execution Plan Analysis" + Visual EXPLAIN screenshot (Figure 6) |
| Measure runtimes before and after optimization | ✅ Fulfilled | "from several minutes to a few seconds" documented |

---

## 6. Visualize and Apply Results

| Requirement | Status | Location in Report |
|-------------|--------|-------------------|
| Install BI tool (Metabase) | ✅ Fulfilled | Chapter 11 "Visualization & Decision Support" |
| Connect Metabase to MySQL database | ✅ Fulfilled | Metabase connected to materialized tables |
| **Connect Metabase to NoSQL database** | ❌ **NOT FULFILLED** | **No NoSQL implementation found** |
| Display configuration being used | ⚠️ Partial | Metabase connection mentioned but no detailed config screenshot |
| Display analysis results interactively with parameters | ⚠️ **Partial** | Screenshots show static dashboards - no visible filters or parameter inputs demonstrated |
| Show how user can interactively work with SQL visualization | ✅ Fulfilled | Dashboard screenshots demonstrate interactivity |
| **Show how user can interactively work with NoSQL visualization** | ❌ **NOT FULFILLED** | **No NoSQL implementation** |
| **Show SQL and NoSQL query outputs are the same** | ❌ **NOT FULFILLED** | **No NoSQL implementation** |
| Demonstrate how visualization relates to original use case | ✅ Fulfilled | Chapter 11 - each KPI visualization has "Key Insight" and "Decision Recommendation" |
| Make recommendation for data-driven decision based on key figures | ✅ Fulfilled | Chapter 12.2 "Conclusion for our Client" - 3 strategic takeaways |

---

## 7. Write Project Report

| Requirement | Status | Location in Report |
|-------------|--------|-------------------|
| Technical report about project | ✅ Fulfilled | Complete report structure |
| Names and email addresses of authors on title page | ✅ Fulfilled | Title page shows all 4 team members with emails |
| Team name on title page | ✅ Fulfilled | "Team ACID" |
| Project title on title page | ✅ Fulfilled | "Traffic Flow Analysis for Urban Planning in Zurich" |
| Maximum 40 pages (excl. title, TOC, appendix) | ⚠️ To Verify | User indicated they will check this |
| Reflection and lessons learned on database technology | ✅ Fulfilled | Chapter 12.3 "Lessons Learned" - first bullet |
| Reflection on project management | ✅ Fulfilled | Chapter 12.3 - second bullet |
| Reflection on teamwork | ✅ Fulfilled | Chapter 12.3 - fourth bullet + Chapter 13 individual reflections |
| Reflection on use of AI | ✅ Fulfilled | Chapter 12.3 - fifth bullet + Chapter 14 "Generative AI Declaration" |
| All AI tools clearly disclosed | ✅ Fulfilled | Chapter 14 - guidelines, use cases, benefits/challenges |
| Create single PDF file | ✅ Fulfilled | R Markdown outputs to PDF |
| Submit to ILIAS folder | N/A | Administrative task |

---

## 8. Assessment Criteria Specific Requirements

### Project Idea
| Criterion | Status | Notes |
|-----------|--------|-------|
| Use case is relevant and coherent | ✅ Fulfilled | Urban planning for Zurich - clear and practical |
| Decision support based on clear decision rule with mathematical key figure | ✅ Fulfilled | Stress Index formula, bottleneck thresholds, dominance share |
| 2+ independent but integrable data sources described | ✅ Fulfilled | Traffic + Population + Quarter |

### Data Model
| Criterion | Status | Notes |
|-----------|--------|-------|
| Source data analysis shows structure/content with examples | ✅ Fulfilled | Tables showing raw columns, cleaned columns |
| Conceptual model explains entities/relationships graphically | ✅ Fulfilled | ERD diagram with descriptions |
| Database schema in DDL with correct data types, PK/FK, 3NF | ✅ Fulfilled | CREATE TABLE statements in appendices |

### Loading & Transformation
| Criterion | Status | Notes |
|-----------|--------|-------|
| Loading processes traceable and performant with MySQL LOAD | ✅ Fulfilled | LOAD DATA LOCAL INFILE documented |
| Transformations meaningful and scalable in SQL | ✅ Fulfilled | INSERT...SELECT transformations |

### Analytics
| Criterion | Status | Notes |
|-----------|--------|-------|
| Data analysis with 8+ keywords in SQL | ✅ Fulfilled | Complex queries with CTEs, window functions |
| Analysis relates directly to use case for decision rule calculation | ✅ Fulfilled | Each KPI tied to urban planning decisions |

### Optimization
| Criterion | Status | Notes |
|-----------|--------|-------|
| 3+ database approaches used | ✅ Fulfilled | Indexes, SARGable rewrites, materialized tables |
| Execution speed measurably faster after optimization | ✅ Fulfilled | "minutes to seconds" with Visual EXPLAIN |

### Visualization
| Criterion | Status | Notes |
|-----------|--------|-------|
| Interactive BI dashboard displays key figure graphically and parameterized | ✅ Fulfilled | Metabase dashboards shown |
| Decision rule applied to (fictitious) user | ✅ Fulfilled | Client recommendations in Chapter 12.2 |

### Lessons Learned
| Criterion | Status | Notes |
|-----------|--------|-------|
| One insight for better database work | ✅ Fulfilled | Database design importance |
| One insight for better project organization | ✅ Fulfilled | Performance planning early |
| One insight for better teamwork | ✅ Fulfilled | GitHub + Miro collaboration challenges |
| One insight for better AI use | ✅ Fulfilled | Context limitations of external AI |
| AI tools disclosed | ✅ Fulfilled | Chapter 14 |

### Project Report
| Criterion | Status | Notes |
|-----------|--------|-------|
| Formal criteria met (<40 pages, valid sources, format, deadline) | ⚠️ Partial | Page count to verify |
| Well structured and clearly written | ✅ Fulfilled | Clear chapter structure, professional tone |

---

## CRITICAL MISSING REQUIREMENT

### ❌ NoSQL Implementation (Section 6 of Assignment)

The project assignment **explicitly requires**:

1. "Connect [Metabase] to **both databases**" - implying SQL AND NoSQL
2. "Show how a user can interactively work with the visualization of the **SQL and NoSQL** queries"
3. "Show that the output of the **SQL and NoSQL** queries and visualizations is the same"

**Current Status**: The report contains ONLY MySQL implementation. There is no mention of:
- Any NoSQL database (MongoDB, etc.)
- NoSQL data loading
- NoSQL queries equivalent to the SQL KPIs
- Metabase connection to NoSQL
- Comparison of SQL vs NoSQL outputs

**Impact**: This is likely a significant point deduction as it's explicitly mentioned 3 times in Section 6 of the requirements.

---

## Summary

| Category | Fulfilled | Partial | Not Fulfilled |
|----------|-----------|---------|---------------|
| 1. Plan Database Application | 5 | 1 | 0 |
| 2. Define Database Structure | 6 | 1 | 0 |
| 3. Load and Transform Data | 6 | 0 | 0 |
| 4. Database Analysis | 7 | 0 | 0 |
| 5. Optimize Performance | 4 | 0 | 0 |
| 6. Visualize and Apply | 4 | 2 | **3** |
| 7. Write Report | 10 | 1 | 0 |
| **TOTAL** | **42** | **5** | **3** |

**Overall Assessment**: The report is comprehensive and well-written for the SQL portion. However, several gaps need attention:

1. **CRITICAL**: NoSQL implementation is completely missing (required 3 times in Section 6)
2. **IMPORTANT**: Parameterized/interactive Metabase queries not demonstrated
3. **MINOR**: Raw data examples and source URLs should be added
