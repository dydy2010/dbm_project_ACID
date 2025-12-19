import re
import pandas as pd
from pyproj import Transformer

# -------------------------------------------------------------------------
# This script converts Zurich quarter centroids from Swiss LV95 to WGS84
# and exports to CSV. No MySQL connection needed.
# -------------------------------------------------------------------------

CSV_INPUT = "data/result data/for map/stzh.adm_statistische_quartiere_b_p.csv"
CSV_OUTPUT = "data/result data/quarter_centroids_wgs84.csv"

transformer = Transformer.from_crs("EPSG:2056", "EPSG:4326", always_xy=True)


def parse_point_wkt(point_wkt: str):
    """Parse 'POINT (E N)' -> (east, north)"""
    m = re.search(r"POINT\s*\(\s*([0-9.]+)\s+([0-9.]+)\s*\)", str(point_wkt))
    if not m:
        return None, None
    return float(m.group(1)), float(m.group(2))


def main():
    df = pd.read_csv(CSV_INPUT)

    # Parse coordinates
    coords = df["geometry"].apply(parse_point_wkt)
    df["east_coordinate"] = [c[0] for c in coords]
    df["north_coordinate"] = [c[1] for c in coords]
    df = df.dropna(subset=["east_coordinate"])

    # Convert LV95 -> WGS84
    lonlat = df.apply(lambda r: transformer.transform(r["east_coordinate"], r["north_coordinate"]), axis=1)
    df["longitude"] = [x[0] for x in lonlat]
    df["latitude"] = [x[1] for x in lonlat]

    # Keep relevant columns
    out = df[["kuerzel", "name", "latitude", "longitude"]].copy()
    out.columns = ["quarter_code", "quarter_name", "latitude", "longitude"]

    out.to_csv(CSV_OUTPUT, index=False)
    print(f"Exported {len(out)} rows to {CSV_OUTPUT}")
    print(out.head())


if __name__ == "__main__":
    main()
