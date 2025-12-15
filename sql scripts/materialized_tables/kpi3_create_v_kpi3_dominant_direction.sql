CREATE OR REPLACE VIEW v_kpi3_dominant_direction AS
WITH direction_totals AS (
    SELECT
        counting_site_name,
        direction,
        direction_volume
    FROM traffic_direction_site_mat
),

site_totals AS (
    SELECT
        counting_site_name,
        SUM(direction_volume) AS total_volume
    FROM direction_totals
    GROUP BY counting_site_name
),

ranked_directions AS (
    SELECT
        dt.counting_site_name,
        dt.direction,
        dt.direction_volume,
        st.total_volume,
        ROW_NUMBER() OVER (
            PARTITION BY dt.counting_site_name
            ORDER BY dt.direction_volume DESC
        ) AS rn
    FROM direction_totals dt
    JOIN site_totals st
        ON dt.counting_site_name = st.counting_site_name
)

SELECT
    counting_site_name,
    direction AS dominant_direction,
    direction_volume AS dominant_volume,
    total_volume,
    direction_volume / total_volume AS dominance_share,
    CASE
        WHEN direction_volume / total_volume > 0.60 THEN 'Strong corridor dependency'
        WHEN direction_volume / total_volume BETWEEN 0.50 AND 0.60 THEN 'Moderate directional preference'
        ELSE 'Balanced intersection'
    END AS classification
FROM ranked_directions
WHERE rn = 1
ORDER BY dominance_share DESC;
