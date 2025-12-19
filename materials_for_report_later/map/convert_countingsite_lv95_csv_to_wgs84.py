import pandas as pd
from pyproj import Transformer

# -------------------------------------------------------------------------
# Convert CountingSite coordinates from Swiss LV95 (EPSG:2056) to WGS84.
# This script does NOT connect to MySQL.
#
# Workflow:
# 1) Export CountingSite table from MySQL Workbench to CSV with columns:
#    counting_site_id, counting_site_name, east_coordinate, north_coordinate
# 2) Put the CSV path below and run this script.
# 3) Import the output CSV back into MySQL.
# -------------------------------------------------------------------------

CSV_INPUT = "data/result data/counting_sites_lv95.csv"
CSV_OUTPUT = "data/result data/counting_sites_wgs84.csv"

transformer = Transformer.from_crs("EPSG:2056", "EPSG:4326", always_xy=True)


def _normalize(name: str) -> str:
    return str(name).strip().lower().replace(" ", "_")


def _standardize_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Accept both snake_case and MySQL Workbench exported headers."""
    normalized_to_original = {_normalize(c): c for c in df.columns}

    # Common variants we want to support
    aliases = {
        "counting_site_id": ["counting_site_id", "counting_site_id", "counting_site_id", "counting_site_id"],
        "counting_site_name": ["counting_site_name", "counting_site_name"],
        "east_coordinate": ["east_coordinate", "east_coordinate"],
        "north_coordinate": ["north_coordinate", "north_coordinate"],
    }

    # Explicitly add the Workbench-style names (after normalization)
    aliases["counting_site_id"].extend(["counting_site_id", "counting_site_id"])
    aliases["counting_site_name"].extend(["counting_site_name", "counting_site_name"])
    aliases["east_coordinate"].extend(["east_coordinate", "east_coordinate"])
    aliases["north_coordinate"].extend(["north_coordinate", "north_coordinate"])

    # The actual normalized Workbench headers from your CSV:
    # 'Counting Site ID' -> 'counting_site_id'
    # 'Counting Site Name' -> 'counting_site_name'
    # 'East Coordinate' -> 'east_coordinate'
    # 'North Coordinate' -> 'north_coordinate'
    for key in aliases:
        aliases[key].append(key)

    rename_map = {}
    for target, alias_list in aliases.items():
        for alias in alias_list:
            if alias in normalized_to_original:
                rename_map[normalized_to_original[alias]] = target
                break

    return df.rename(columns=rename_map)


def main():
    df = pd.read_csv(CSV_INPUT)
    df = _standardize_columns(df)

    required = {"counting_site_id", "counting_site_name", "east_coordinate", "north_coordinate"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(
            f"Missing columns in {CSV_INPUT}: {sorted(missing)}. "
            f"Found: {df.columns.tolist()}"
        )

    df["east_coordinate"] = pd.to_numeric(df["east_coordinate"], errors="coerce")
    df["north_coordinate"] = pd.to_numeric(df["north_coordinate"], errors="coerce")
    df = df.dropna(subset=["east_coordinate", "north_coordinate"]).copy()

    lon_lat = df.apply(
        lambda r: transformer.transform(float(r["east_coordinate"]), float(r["north_coordinate"])),
        axis=1,
    )

    df["longitude"] = [x[0] for x in lon_lat]
    df["latitude"] = [x[1] for x in lon_lat]

    out = df[["counting_site_id", "counting_site_name", "latitude", "longitude"]].copy()
    out.to_csv(CSV_OUTPUT, index=False)

    print(f"Converted {len(out)} counting sites.")
    print(f"Wrote: {CSV_OUTPUT}")
    print(out.head())


if __name__ == "__main__":
    main()
