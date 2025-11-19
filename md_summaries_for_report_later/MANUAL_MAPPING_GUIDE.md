# Manual Station-to-District Mapping Guide

## Quick Start (30 minutes per person for ~27 stations)

### Tools You'll Need
1. **Swiss Map Viewer**: https://map.geo.admin.ch
   - Official Swiss government mapping tool
   - Shows coordinates and district boundaries
2. **Station List**: `dav.tbl_standort_zaehlung_miv_p.csv` (109 stations)
3. **District Reference**: See table below

---

## Zürich Districts Reference (QuarCd)

### Kreis 1 (City Center)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 011 | Rathaus | Old town, near Limmat |
| 012 | Hochschulen | University area |
| 013 | Lindenhof | Hill area, Bahnhofstrasse |
| 014 | City | Main shopping district |

### Kreis 2 (South/Wollishofen area)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 021 | Wollishofen | Lake shore south, "Strandbad" |
| 023 | Leimbach | South-west, near Uetliberg |
| 024 | Enge | Near lake, between City and Wollishofen |

### Kreis 3 (South-west)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 031 | Alt-Wiedikon | Residential, "Wiedikon" stations |
| 032 | Friesenberg | Hill area, west |
| 033 | Sihlfeld | Near Sihl river |

### Kreis 4 (West, Langstrasse)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 041 | Werd | Near HB train station |
| 042 | Langstrasse | "Langstrasse" in name |
| 043 | Hard | "Hard" streets, near highway |

### Kreis 5 (West, Industrial)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 051 | Gewerbeschule | "Escher Wyss" area |
| 052 | Escher Wyss | Near Hardbrücke |

### Kreis 6 (North-west)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 061 | Unterstrass | Between center and north |
| 062 | Oberstrass | "Oberstrass" in names |

### Kreis 7 (East, Fluntern/Hottingen)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 071 | Fluntern | "Fluntern", Zoo area |
| 072 | Hottingen | "Hottingen" streets |
| 073 | Hirslanden | "Hirslanden" in names |
| 074 | Witikon | "Witikon" streets, far east |

### Kreis 8 (Lake shore, east)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 081 | Seefeld | "Seefeld", "Bellevue" |
| 082 | Mühlebach | "Mühlebach" streets |
| 083 | Weinegg | Residential east |

### Kreis 9 (North, Albisrieden/Altstetten)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 091 | Albisrieden | "Albisrieden" in names |
| 092 | Altstetten | "Altstetten" streets, west |

### Kreis 10 (North-west, Höngg)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 101 | Höngg | "Höngg" in names |
| 102 | Wipkingen | "Wipkingen" streets |

### Kreis 11 (North, Oerlikon/Seebach)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 111 | Affoltern | "Affoltern" in names |
| 112 | Oerlikon | "Oerlikon" streets, industrial |
| 113 | Seebach | "Seebach" in names |

### Kreis 12 (North-east, Schwamendingen)
| QuarCd | QuarLang | Notes |
|--------|----------|-------|
| 121 | Saatlen | "Saatlen" in names |
| 122 | Schwamendingen-Mitte | "Schwamendingen" streets |
| 123 | Hirzenbach | "Hirzenbach" in names |

---

## Step-by-Step Mapping Process

### Method 1: Text Matching (Fast, ~70% of stations)

Look at station name for district keywords:

**Examples**:
```
Z001 "Seestrasse (Strandbad Wollishofen)"
     ^^^^^^^^^ Contains "Wollishofen" 
     → QuarCd = 021, KreisCd = 2, Confidence = 1.00

Z005 "Albisriederstrasse (Lyrenweg)"
     ^^^^^^^^^^^^^^ Contains "Albisrieden"
     → QuarCd = 091, KreisCd = 9, Confidence = 1.00

Z042 "Langstrasse (Hohlstrasse)"
     ^^^^^^^^^^^ Contains "Langstrasse"
     → QuarCd = 042, KreisCd = 4, Confidence = 1.00
```

### Method 2: Coordinate Lookup (For unclear stations)

1. Open https://map.geo.admin.ch
2. Click search icon (🔍)
3. Enter coordinates from CSV (EKoord, NKoord)
   - Example: `2683009.89, 1243936.2`
4. Map will show exact location
5. Enable "Statistische Quartiere" layer:
   - Click layers icon
   - Search "quartier"
   - Enable "Statistische Quartiere"
6. Click on location → See district name
7. Match to QuarCd from reference table above

### Method 3: Known Street Lookup

1. Google the street name + "Zürich Quartier"
2. Or use: https://www.stadt-zuerich.ch/geodaten/

---

## Mapping Template (Copy this)

Create a CSV file: `station_district_mapping.csv`

```csv
ZSID,QuarCd,KreisCd,MappingMethod,MappingConfidence,Notes
Z001,021,2,text_match,1.00,"Strandbad Wollishofen - clear district name"
Z002,021,2,coordinate,0.95,"Albisstrasse near Wollishofen"
Z003,023,2,text_match,1.00,"Leimbach in station vicinity"
Z004,032,3,coordinate,0.90,"Triemli area - Friesenberg border"
Z005,091,9,text_match,1.00,"Albisriederstrasse in name"
...
```

**Confidence Scoring**:
- `1.00` = Certain (district name in station name)
- `0.95` = Very confident (coordinate lookup clear)
- `0.90` = Confident (street well-known in district)
- `0.80` = Likely (coordinate on district border)
- `0.50` = Uncertain (highway, between districts)
- `NULL` = Cannot determine (A1 highway outside city limits)

---

## Special Cases

### Highways/Autobahns
```
Z023 "Autobahn A1 (Anschluss Altstetten)"
     → QuarCd = NULL, KreisCd = NULL
     Notes: "Highway interchange, not within specific district"
```

### Border Stations (Between Districts)
```
Z073 "Stauffacherbrücke"
     → QuarCd = 033, KreisCd = 3  (choose primary side)
     Confidence = 0.80
     Notes: "Bridge between Sihlfeld and Wiedikon, assigned to Sihlfeld"
```

### Tunnels
```
Z077 "Sihlhölzlibrücke (Ulmbergtunnel)"
     → Use tunnel entrance coordinates
     → QuarCd = 033, KreisCd = 3
```

---

## Dividing Work Among 4 Team Members

### Station Assignment
- **Person 1**: Stations Z001 - Z027 (~27 stations)
- **Person 2**: Stations Z028 - Z054 (~27 stations)
- **Person 3**: Stations Z055 - Z081 (~27 stations)
- **Person 4**: Stations Z082 - Z110 (~28 stations)

### Time Estimate
- Easy stations (text match): 30 seconds each
- Medium stations (coordinate lookup): 2 minutes each
- Difficult stations (research): 5 minutes each

**Total per person**: 20-40 minutes

---

## Example Completed Mappings (First 10)

```sql
-- Copy-paste ready INSERT statements
INSERT INTO BridgeStationQuartier 
(ZSID, QuarCd, KreisCd, MappingMethod, MappingConfidence, Notes) VALUES
('Z001', '021', '2', 'text_match', 1.00, 'Strandbad Wollishofen'),
('Z002', '021', '2', 'coordinate', 0.95, 'Albisstrasse Widmerstrasse near Wollishofen'),
('Z003', '023', '2', 'text_match', 0.90, 'Sood-/Leimbach area'),
('Z004', '032', '3', 'text_match', 1.00, 'Triemli clearly in Friesenberg'),
('Z005', '091', '9', 'text_match', 1.00, 'Albisriederstrasse'),
('Z007', '041', '4', 'coordinate', 0.90, 'Bernerstrasse Hermetschloobrücke'),
('Z008', '051', '5', 'coordinate', 0.85, 'Limmattalstrasse industrial area'),
('Z009', '051', '5', 'coordinate', 0.85, 'Regensdorferstrasse industrial area'),
('Z010', '061', '6', 'text_match', 0.90, 'Wehntalerstrasse Unterstrass area'),
('Z023', NULL, NULL, 'manual', 0.50, 'Autobahn A1 - outside specific district');
```

---

## Validation Checklist

After completing your mappings:

✅ All 109 stations assigned (or marked NULL for highways)  
✅ Confidence scores documented  
✅ Uncertain mappings (< 0.90) reviewed by second person  
✅ At least 80% of stations have confidence >= 0.90  
✅ No duplicate ZSID entries  
✅ All QuarCd values exist in DimQuartier table  

---

## Quick Import to Database

```sql
-- After creating CSV file
LOAD DATA LOCAL INFILE 'station_district_mapping.csv'
INTO TABLE BridgeStationQuartier
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ZSID, QuarCd, KreisCd, MappingMethod, MappingConfidence, Notes);

-- Verify
SELECT 
    COUNT(*) as TotalStations,
    SUM(CASE WHEN QuarCd IS NOT NULL THEN 1 ELSE 0 END) as Mapped,
    AVG(MappingConfidence) as AvgConfidence
FROM BridgeStationQuartier;

-- Check uncertain mappings
SELECT ZSID, QuarCd, MappingConfidence, Notes
FROM BridgeStationQuartier
WHERE MappingConfidence < 0.90 OR QuarCd IS NULL
ORDER BY MappingConfidence;
```

---

## Pro Tips

1. **Start with obvious ones**: Stations with district names in their title (50-60 stations, 15 minutes)

2. **Batch similar stations**: All "Albisrieden" stations together, all "Wollishofen" together

3. **Use map layers**: Enable "Statistische Quartiere" layer in map.geo.admin.ch from the start

4. **Document uncertainties**: Better to mark 0.80 confidence and come back than guess wrong

5. **Cross-validate**: If station name says "Wollishofen" but coordinates show "Enge", investigate!

---

## Summary

**Total Work**: 1-2 hours for 4-person team (20-30 min per person)  
**Required Tools**: Browser with internet  
**External Data**: None required  
**Output**: 109-row CSV file or SQL INSERT statements  
**Accuracy**: 90-95% achievable  

This mapping unlocks the full potential of your datasets for combined urban planning analysis! 🎯

DIMENSION TABLES
═══════════════════════════════════════════════════════════

DimGender                          DimAgeGroup
├─ SexCd (PK)                     ├─ AlterV20ueber80Cd_noDM (PK)
└─ SexLang                        ├─ AlterV20ueber80Kurz_noDM
                                  └─ AlterV20ueber80Sort_noDM

DimOrigin                          DimKreis
├─ HerkunftCd (PK)                ├─ KreisCd (PK)
└─ HerkunftLang                   └─ KreisLang

DimQuartier                        DimTime
├─ QuarCd (PK)                    ├─ DateKey (PK)
├─ QuarLang                       ├─ FullDate
└─ KreisCd (FK)                   ├─ Year
                                  ├─ Month
DimTrafficStation                  └─ IsWeekend
├─ ZSID (PK)
├─ ZSName                         DimMeasurementPoint
├─ Status                         ├─ MSID (PK)
├─ EKoord                         ├─ MSName
├─ NKoord                         ├─ ZSID (FK)
└─ Adresse                        ├─ Achse
                                  ├─ Richtung
BRIDGE TABLE (YOU CREATE)          ├─ EKoord
═══════════════════════════════════ └─ NKoord
BridgeStationQuartier
├─ ZSID (PK, FK)                  
├─ QuarCd (FK)                    
├─ KreisCd (FK)                   
├─ MappingConfidence              
└─ Notes                          


FACT TABLES
═══════════════════════════════════════════════════════════

FactPopulation
├─ PopulationID (PK)
├─ DateKey (FK) ────────────────────┐
├─ QuarCd (FK) ─────────────┐       │
├─ SexCd (FK) ──────┐       │       │
├─ AlterV20ueber80Cd_noDM (FK)      │
├─ HerkunftCd (FK)  │       │       │
└─ AnzBestWir       │       │       │
      (measure)     ▼       ▼       ▼
                DimGender DimQuartier DimTime
                          │
                          └─ KreisCd (FK) ──▶ DimKreis

FactTraffic
├─ TrafficID (PK)
├─ MSID (FK) ───────────────────┐
├─ MessungDatZeit               │
├─ DateKey (FK) ────────────────┼────┐
├─ HourOfDay                    │    │
├─ AnzFahrzeuge (measure)       ▼    ▼
└─ AnzFahrzeugeStatus    DimMeasurementPoint DimTime
                                │
                                └─ ZSID (FK) ──▶ DimTrafficStation
                                                  │
                                                  └─ ZSID (FK) ──▶ BridgeStationQuartier
                                                                   │
                                                                   └─ QuarCd (FK) ──▶ DimQuartier


JOIN PATH: Population ↔ Traffic
═══════════════════════════════════════════════════════════

FactPopulation                    FactTraffic
      │                                 │
      │ QuarCd                          │ MSID
      ▼                                 ▼
DimQuartier                    DimMeasurementPoint
      │                                 │ ZSID
      │ QuarCd                          ▼
      │                         DimTrafficStation
      │                                 │ ZSID
      │                                 ▼
      └──────────────────────▶ BridgeStationQuartier
                                  (your mapping table)


KEY RELATIONSHIPS
═══════════════════════════════════════════════════════════

1. FactPopulation.QuarCd         → DimQuartier.QuarCd
2. DimQuartier.KreisCd           → DimKreis.KreisCd
3. FactTraffic.MSID              → DimMeasurementPoint.MSID
4. DimMeasurementPoint.ZSID      → DimTrafficStation.ZSID
5. DimTrafficStation.ZSID        → BridgeStationQuartier.ZSID
6. BridgeStationQuartier.QuarCd  → DimQuartier.QuarCd
7. Both Facts.DateKey            → DimTime.DateKey


COMBINED QUERY EXAMPLE
═══════════════════════════════════════════════════════════

SELECT 
    q.QuarLang,
    SUM(p.AnzBestWir) AS Population,
    SUM(t.AnzFahrzeuge) AS Traffic
FROM FactPopulation p
JOIN DimQuartier q ON p.QuarCd = q.QuarCd
LEFT JOIN BridgeStationQuartier bsq ON q.QuarCd = bsq.QuarCd
LEFT JOIN DimTrafficStation ts ON bsq.ZSID = ts.ZSID
LEFT JOIN DimMeasurementPoint mp ON ts.ZSID = mp.ZSID
LEFT JOIN FactTraffic t ON mp.MSID = t.MSID
WHERE p.DateKey = t.DateKey
GROUP BY q.QuarLang;