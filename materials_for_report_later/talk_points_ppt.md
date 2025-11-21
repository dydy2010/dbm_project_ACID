# Talk Points for Presentation

## Slide 1 – Title & Framing
- Introduce the project as an integrated traffic-and-demographic database supporting Zurich’s planners.
- Mention Team ACID and the DBM HS 2025 context.
- Set expectations: this is a progress and data-modeling update focused on turning open data into planning insights.

## Slide 2 – Why This Matters
- Client pain point: rapid population growth stresses fixed road capacity.
- Our mission: spot “stress zones” where population growth outpaces traffic capacity.
- Emphasize that accurate district-level data is critical for prioritizing infrastructure investments.

## Slide 3 – Stress Index Hypothesis
- Explain that linking traffic and population data per district enables comparable growth metrics.
- Classification logic: commuter hubs (traffic growth > population growth) vs. residential zones (population growth > traffic growth).
- Note that this builds on the KPI framework (peak load, imbalance, temporal trends) defined earlier.

## Slide 4 – Raw Data Landscape
- Present the three sources: hourly traffic counts, city quarter/district population tables, and the geo-address bridge.
- Highlight the scale (21M+ cleaned traffic rows).
- Stress that the geo-address file lets us translate street measurements into districts/quarters for demographic joins. which we talk about in detail in next page.

## Slide 5 – Solving the Missing Link
- Traffic data lacked quarter names, only street address, blocking joins with population data.
- The str_stadtquartier mapping adds quarter_name afnter regex cleaning and manual harmonization of tricky street names.
- Once quarter names were injected, every traffic record could inherit demographic context.

## Slide 6 – Conceptual Data Model
- Walk through the ERD: start at CountingSite (physical location), drill down to MeasurementSite (direction/lane), end at TrafficMeasurement (hourly counts), then show how Quarter, Population, Sex, and Origin add spatial and demographic context.
- Explain the data-modeling method: gather all cleaned attributes, cluster them into entities, then normalize relationships until each table has a clear primary key.
- Highlight the methodology: iterative passes through 1NF → 2NF → 3NF,
Emphasize achieving 3NF—no transitive dependencies remain—so every attribute depends solely on its table key.


## Slide 7 – Challenges & Next Steps
- Data cleaning hurdles: inconsistent street naming, mixed-language categories, redundant metadata.
- Timeframe mismatch: hourly traffic vs. monthly population required aggregation and alignment.
- Next steps: finish SQL normalization of all sources, finalize the unified schema, and develop the stress-index queries/dashboards.
