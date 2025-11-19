# Dataset Connection Analysis

## Unique Counts Summary

### Population Data (bev325od3250.csv)
- **35 unique QuarLang** (district names)
- **225,558 total rows**
- Granularity: Monthly data from 1998-2024

### Traffic Data (sid_dav_verkehrszaehlung_miv_od2031_2024.csv)
- **109 unique ZSID** (station IDs)
- **210 unique MSID** (measurement point IDs)
- **110 unique ZSName** (station names)
- **1,799,790 total rows**
- Granularity: Hourly data for 2024

### Station Metadata (dav.tbl_standort_zaehlung_miv_p.csv)
- **109 stations** (matches ZSID count ✅)

---

## Connection Challenge

### The Gap
```
Population Side:               Traffic Side:
35 Districts (QuarLang)   →    109 Stations (ZSID)
                          ←    210 Measurement Points (MSID)

RATIO: ~3 stations per district (109 ÷ 35 = 3.1)
```

### What This Means
- Each district will have **0-10+ traffic stations**
- Some districts may have **no traffic stations** (residential areas)
- Some districts may have **many stations** (major arteries, commercial areas)

---

## Text Matching Success Rate

### Automatic Matching Potential
Checked station names for district name keywords:

**Result**: **8 out of 110 station names** contain clear district references (~7%)

**Examples of Matchable Stations**:
```
✅ "Seestrasse (Strandbad Wollishofen)" → Wollishofen
✅ "Sood-/Leimbachstrasse" → Leimbach  
✅ "Autobahn A1 (Auschluss Schwamendingen)" → Schwamendingen-Mitte
✅ "Seebacherstrasse (Binzmühlestrasse)" → Seebach
✅ "Wallisellenstrasse (Saatlenstrasse)" → Saatlen
✅ "Witikonerstrasse (Katzenschwanzstrasse)" → Witikon
✅ "Katzenschwanzstrasse (Witikonerstrasse)" → Witikon
✅ "Binzmuehlestrasse (Seebacherstrasse)" → Seebach
```

**93% of stations (102/110) have NO district name in station name** ❌

### Why Text Matching Won't Work
Most stations are named by **street/landmark**, not district:
```
❌ "Bahnhofbrücke" → Which district?
❌ "Hardbrücke (Hardstrasse)" → Which district?
❌ "Stauffacherbrücke" → Which district?
❌ "Allmendstrasse (Brunau)" → Which district?
```

---

## Recommended Connection Strategy

### ✅ **Best Approach: Coordinate-Based Mapping**

Since 93% of stations lack district names, use **geographic coordinates**:

1. **Every station has coordinates**: EKoord, NKoord (Swiss LV95 system)
2. **Two methods available**:

#### **Method A: Manual Coordinate Lookup** (1-2 hours)
- Use https://map.geo.admin.ch
- Paste coordinates for each station
- See which district polygon it falls in
- Document in spreadsheet

**Pros**:
- 100% accuracy
- No programming needed
- Team can divide work (27 stations each)

**Cons**:
- Manual labor
- 1-2 hours total time

#### **Method B: Automated Spatial Join** (2-4 hours setup)
- Download district boundary GeoJSON
- Use Python/PostGIS for spatial join
- Fully automated

**Pros**:
- Automated
- Reproducible
- Can validate Method A

**Cons**:
- Requires GIS skills
- Need external boundary data
- Initial setup time

---

## Detailed Mapping Workload

### Option 1: Pure Manual Mapping
```
109 stations ÷ 4 team members = ~27 stations each
27 stations × 1-2 min/station = 30-50 minutes per person
Total team time: 2-3 hours
```

### Option 2: Hybrid Approach (RECOMMENDED)
```
Step 1: Auto-match 8 obvious stations (5 min)
Step 2: Manual coordinate lookup for 101 stations
        101 ÷ 4 = 25 stations per person
        25 × 2 min = 50 min per person
Total team time: 1.5-2 hours
```

### Option 3: Automated Spatial Join
```
Setup: 2-4 hours (one person with Python/GIS knowledge)
Execution: 5 minutes
Validation: 30 minutes
Total time: 3-5 hours (but reusable!)
```

---

## Cardinality Analysis

### District Coverage Estimation

Based on station names and typical urban patterns:

| District Type | Est. Stations | Examples |
|---------------|---------------|----------|
| **Major arterials** | 10-15 stations | Oerlikon, Altstetten, Schwamendingen |
| **City center** | 15-20 stations | City, Rathaus, Lindenhof |
| **Medium density** | 5-10 stations | Wollishofen, Enge, Wiedikon |
| **Residential** | 2-5 stations | Fluntern, Hirslanden, Weinegg |
| **Low traffic** | 0-2 stations | Saatlen, Affoltern |

### Expected Distribution
```
~10 districts: 0-1 stations (residential, hills)
~15 districts: 2-5 stations (moderate)
~8 districts: 6-10 stations (busy)
~2 districts: 10+ stations (city center, major junctions)
```

---

## Connection Schema Design

### Recommended Tables

```sql
-- Bridge table (must be populated)
CREATE TABLE BridgeStationQuartier (
    ZSID VARCHAR(20) PRIMARY KEY,
    QuarCd VARCHAR(10),              -- Can be NULL for highways
    QuarLang VARCHAR(100),           -- For easy reference
    MappingMethod VARCHAR(50),        -- 'coordinate', 'text_match', 'manual'
    MappingConfidence DECIMAL(3,2),  -- 0.00 to 1.00
    EKoord DECIMAL(12,4),            -- Store coordinates for verification
    NKoord DECIMAL(12,4),
    Notes TEXT
);

-- Then MSIDs inherit from stations
CREATE TABLE DimMeasurementPoint (
    MSID VARCHAR(20) PRIMARY KEY,
    ZSID VARCHAR(20) NOT NULL,
    -- other columns...
    FOREIGN KEY (ZSID) REFERENCES DimTrafficStation(ZSID)
);
```

### Join Path for Analysis
```sql
-- Population + Traffic combined query
SELECT 
    q.QuarLang AS District,
    COUNT(DISTINCT t.MSID) AS MeasurementPoints,
    SUM(t.AnzFahrzeuge) AS TotalTraffic,
    AVG(p.AnzBestWir) AS AvgPopulation
FROM FactPopulation p
JOIN DimQuartier q ON p.QuarCd = q.QuarCd
LEFT JOIN BridgeStationQuartier bsq ON q.QuarCd = bsq.QuarCd
LEFT JOIN DimTrafficStation ts ON bsq.ZSID = ts.ZSID
LEFT JOIN DimMeasurementPoint mp ON ts.ZSID = mp.ZSID
LEFT JOIN FactTraffic t ON mp.MSID = t.MSID
WHERE YEAR(p.StichtagDat) = 2024
GROUP BY q.QuarLang;
```

---

## Alternative: MSID to QuarLang Direct Mapping?

### Could We Map 210 MSIDs Instead of 109 ZSIDs?

**Answer**: No, not recommended

**Reason**: 
- MSIDs belong to ZSIDs (parent-child relationship)
- Example: Z001 has multiple measurement points (Z001M001, Z001M002, etc.)
- All MSIDs under one ZSID are at **same location** (same coordinates)
- Mapping ZSID automatically maps all child MSIDs ✅

**Math**:
```
109 stations × 1 mapping each = 109 mappings needed
vs.
210 measurement points × 1 mapping each = 210 mappings
BUT: All MSIDs under Z001 would map to SAME QuarCd anyway!
```

**Conclusion**: Map at ZSID level (109 stations), inherit to MSIDs via foreign key.

---

## Implementation Priority

### Week 1 (CRITICAL)
1. ✅ Create BridgeStationQuartier table structure
2. ✅ Extract unique ZSID + coordinates from station metadata
3. ✅ Divide 109 stations among 4 team members (~27 each)
4. ✅ Manual coordinate lookup using map.geo.admin.ch
5. ✅ Populate bridge table
6. ✅ Validate with sample queries

### Week 2 (OPTIONAL)
- If time permits: Implement automated spatial join for validation
- Compare manual vs. automated results
- Fix any discrepancies

---

## Sample Starter Script

Here's a semi-automated approach:

```python
import pandas as pd
import re

# Load data
stations = pd.read_csv('dav.tbl_standort_zaehlung_miv_p.csv')
districts = [
    'Wollishofen', 'Albisrieden', 'Wiedikon', 'Altstetten', 'Enge',
    'Leimbach', 'Oerlikon', 'Seebach', 'Schwamendingen', 'Witikon',
    'Höngg', 'Wipkingen', 'Affoltern', 'Saatlen', 'Hirzenbach'
    # ... add all 35
]

# Auto-match obvious ones
mapping = []
for idx, row in stations.iterrows():
    zsid = row['zsid']
    name = row['zsname']
    ekoord = row['ekoord']
    nkoord = row['nkoord']
    
    # Try text matching
    matched = None
    for district in districts:
        if district.lower() in name.lower():
            matched = district
            break
    
    if matched:
        mapping.append({
            'ZSID': zsid,
            'QuarLang': matched,
            'Method': 'text_match',
            'Confidence': 1.00,
            'EKoord': ekoord,
            'NKoord': nkoord,
            'StationName': name
        })
    else:
        # Needs manual lookup
        mapping.append({
            'ZSID': zsid,
            'QuarLang': 'NEEDS_MANUAL_LOOKUP',
            'Method': 'pending',
            'Confidence': 0.00,
            'EKoord': ekoord,
            'NKoord': nkoord,
            'StationName': name
        })

# Export for manual completion
df = pd.DataFrame(mapping)
df.to_csv('station_mapping_template.csv', index=False)
print(f"Auto-matched: {len(df[df['QuarLang'] != 'NEEDS_MANUAL_LOOKUP'])}")
print(f"Needs manual lookup: {len(df[df['QuarLang'] == 'NEEDS_MANUAL_LOOKUP'])}")
```

This would give you:
- **~8 auto-matched** stations
- **~101 to manually lookup** (split among 4 people = 25 each)

---

## Decision Matrix

| Approach | Time | Accuracy | Skill Required | Team Effort |
|----------|------|----------|----------------|-------------|
| **Pure Manual** | 2-3h | 95-100% | None | High (all 4) |
| **Hybrid** | 1.5-2h | 95-100% | None | Medium (all 4) |
| **Automated** | 3-5h | 99-100% | Python/GIS | Low (1 person) |

---

## Recommendation

### For Your Team (4 people, 1.5 months timeline):

**Use Hybrid Approach**:

1. **Tuesday Week 1**: One person runs auto-match script (30 min)
2. **Wednesday Week 1**: 
   - Split remaining 101 stations into 4 lists
   - Each person: 25 stations × 2 min = 50 minutes
   - Use map.geo.admin.ch with coordinates
3. **Thursday Week 1**: Cross-validate uncertain mappings (30 min)
4. **Friday Week 1**: Load into BridgeStationQuartier, test joins

**Total time investment**: 1.5-2 hours team time

**Outcome**: Full dataset connectivity, enables all combined analyses ✅

---

## Success Metrics

After mapping is complete, you should achieve:

✅ 109 stations mapped (100%)  
✅ 95-100 stations with confidence ≥ 0.90  
✅ 0-10 stations marked as NULL (highways outside districts)  
✅ Can join population + traffic data  
✅ Can calculate traffic-per-capita by district  
✅ Can identify infrastructure gaps  

This unlocks the **full potential** of your datasets for urban planning analysis! 🎯
