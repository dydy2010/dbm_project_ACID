# Raw Dataset Column Reference

## population_raw.csv
| Column                       | Example Value      | English Translation           |
|------------------------------|--------------------|-----------------------------|
| StichtagDatJahr              | 1998               | Reference date year           |
| StichtagDatMM                | 1                  | Reference date month (number) |
| StichtagDatMonat             | Januar             | Reference date month (name)   |
| StichtagDat                  | 1998-01-31         | Reference date                |
| SexCd                        | 1                  | Sex code                      |
| SexLang                      | männlich           | Sex (male)                    |
| AlterV20ueber80Sort_noDM     | 1                  | Age group sort order          |
| AlterV20ueber80Cd_noDM       | 1                  | Age group code                |
| AlterV20ueber80Kurz_noDM     | 0-19               | Age group short (0-19)        |
| HerkunftCd                   | 1                  | Origin code                   |
| HerkunftLang                 | Schweizer*in       | Origin (Swiss)                |
| KreisCd                      | 2                  | District code                 |
| KreisLang                    | Kreis 2            | District 2                    |
| QuarCd                       | 021                | Quarter code                  |
| QuarLang                     | Wollishofen        | Quarter name (Wollishofen)    |
| DatenstandCd                 | V                  | Data status code              |
| DatenstandLang               | Veröffentlicht     | Data status (Published)       |
| AnzBestWir                   | 950                | Population count              |

## str_stadtquartier_raw_for_join.csv
| Column                 | Example Value        | English Translation           |
|------------------------|----------------------|-------------------------------|
| adresse                | Zähringerstrasse 43  | Address                       |
| anzahl_fla_projektiert |                      | Number of units (planned)     |
| anzahl_fla_real        | 2                    | Number of units (realized)    |
| flaeche_projektiert    |                      | Area planned (m²)             |
| flaeche_real           | 449                  | Area realized (m²)            |
| flaeche_total          | 449                  | Total area (m²)               |
| gwr_egid               | 140003               | Federal building ID           |
| hausnummer             | 43                   | House number                  |
| lokalisationsname      | Zähringerstrasse     | Street name                   |
| objectid               | 1                    | Object ID                     |
| stadtkreis             | 1                    | City district                 |
| statistisches_quartier | Rathaus              | Statistical quarter (Rathaus) |

## traffic_data_cleaned.csv
| Column                | Example Value                       | English Translation           |
|-----------------------|-------------------------------------|-------------------------------|
| measurement_site_id   | Z001M001                            | Measurement site ID           |
| measurement_site_name | Unknown                             | Measurement site name         |
| counting_site_id      | Z001                                | Counting site ID              |
| counting_site_name    | Seestrasse (Strandbad Wollishofen)  | Counting site name            |
| position_description  | Unknown                             | Position description          |
| east_coordinate       | 2683009.89                          | East coordinate (CH1903+)     |
| north_coordinate      | 1243936.2                           | North coordinate (CH1903+)    |
| direction             | outbound                            | Traffic direction             |
| signal_id             | 789                                 | Signal/controller ID          |
| signal_name           | Badanstalt Wollishofen              | Signal/controller name        |
| num_detectors         | 1                                   | Number of detectors           |
| timestamp             | 2013-01-01T00:00:00                 | Timestamp (ISO-8601)          |
| vehicle_count         | 224.0                               | Vehicle count                 |
| vehicle_count_status  | Measured                            | Count status                  |
