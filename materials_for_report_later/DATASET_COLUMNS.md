# Dataset Column Reference

## population_raw.csv
| Column | Description |
| --- | --- |
| StichtagDatJahr | Year of the reference snapshot |
| StichtagDatMM | Month number (1-12) of the reference snapshot |
| StichtagDatMonat | Month name (German) |
| StichtagDat | Full reference date (YYYY-MM-DD) |
| SexCd | Sex code (e.g., `1` male, `2` female) |
| SexLang | Sex label (German) |
| AlterV20ueber80Sort_noDM | Sort order for the age group |
| AlterV20ueber80Cd_noDM | Age-group code |
| AlterV20ueber80Kurz_noDM | Age-group short label |
| HerkunftCd | Origin/Nationality code |
| HerkunftLang | Origin/Nationality label (German) |
| KreisCd | City district code |
| KreisLang | City district label (German) |
| QuarCd | Statistical quarter code |
| QuarLang | Statistical quarter name |
| DatenstandCd | Data status code |
| DatenstandLang | Data status label (German) |
| AnzBestWir | Population count for the slice |

## str_stadtquartier_raw_for_join.csv
| Column | Description |
| --- | --- |
| adresse | Full formatted street address |
| anzahl_fla_projektiert | Planned residential/commercial units (count) |
| anzahl_fla_real | Realized residential/commercial units (count) |
| flaeche_projektiert | Planned area (m²) |
| flaeche_real | Realized area (m²) |
| flaeche_total | Total area (m²) |
| gwr_egid | Swiss federal building identifier |
| hausnummer | House number component |
| lokalisationsname | Street name without number |
| objectid | Internal object identifier |
| stadtkreis | Numerical city district |
| statistisches_quartier | Statistical quarter name |

## traffic_data_cleaned.csv
| Column | Description |
| --- | --- |
| measurement_site_id | Unique identifier for the measurement site |
| measurement_site_name | Human-readable measurement site name |
| counting_site_id | Identifier for the counting site |
| counting_site_name | Human-readable counting site name |
| position_description | Additional location description |
| east_coordinate | CH1903+ east coordinate |
| north_coordinate | CH1903+ north coordinate |
| direction | Traffic direction (e.g., outbound/inbound) |
| signal_id | Associated signal/controller identifier |
| signal_name | Name of the signal/controller |
| num_detectors | Number of detectors contributing to the measurement |
| timestamp | ISO-8601 timestamp of the measurement interval |
| vehicle_count | Count value for the interval |
| vehicle_count_status | Status/quality flag for the count (e.g., Measured) |
