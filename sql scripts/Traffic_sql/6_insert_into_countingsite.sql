-- Column "axis" contains inconsistent values across multiple rows
-- for the same counting_site_id. These cause
-- primary key conflicts in the final dimension table.
-- Therefore, remove this column from the final schema.
ALTER TABLE CountingSite
DROP COLUMN axis;

-- Insert one clean, consistent record per counting_site_id.
-- The staging table contains many duplicate rows for the same ID,
-- often with small differences (NULLs, blanks, numeric rounding, etc.).
-- GROUP BY collapses all these rows into a single group PER ID.
--
-- Since MySQL now has multiple different values inside each group,
-- tell it which value to pick for each column.
-- Do this using MIN(), which provides:
--   - A deterministic, stable choice
--   - Works for both text and numeric columns
--   - Resolves inconsistencies without errors
--   - Guarantees exactly one final row per counting_site_id

INSERT INTO CountingSite (
    counting_site_id,
    counting_site_name,
    east_coordinate,
    north_coordinate,
    signal_id
)
SELECT
    counting_site_id,

    -- MIN(counting_site_name):
    -- If small variations exist (trailing spaces, capitalization, etc.)
    -- MIN() chooses the alphabetically smallest value.
    -- This ensures a consistent, clean attribute for the entire site.
    MIN(counting_site_name) AS counting_site_name,

    -- MIN(east_coordinate):
    -- Some rows may contain NULL or slightly different numeric values.
    -- MIN() ensures we consistently choose one stable numeric value.
    MIN(CAST(east_coordinate AS FLOAT)) AS east_coordinate,

    -- Same logic for the north coordinate.
    MIN(CAST(north_coordinate AS FLOAT)) AS north_coordinate,

    -- MIN(signal_id):
    -- Some rows may have signal_id = NULL or different assignments.
    -- MIN() chooses a deterministic value and avoids PK/FK conflicts.
    MIN(CAST(signal_id AS UNSIGNED)) AS signal_id

FROM stg_traffic_data

-- GROUP BY ensures return of exactly one row per counting_site_id.
-- Without GROUP BY, MySQL would try to insert many rows with the same
-- primary key, causing "Duplicate entry" errors.
GROUP BY counting_site_id;
