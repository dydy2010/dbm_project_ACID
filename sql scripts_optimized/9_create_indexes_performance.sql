-- ============================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- Run this AFTER all tables are created and data is loaded
-- ============================================================

USE traffic_population_zh;

-- TrafficMeasurement indexes (largest table, most critical)
-- Used in: v_traffic_yearly, v_kpi2_bottlenecks, v_kpi3_dominant_direction
CREATE INDEX idx_tm_timestamp ON TrafficMeasurement(timestamp);
CREATE INDEX idx_tm_measurement_site_id ON TrafficMeasurement(measurement_site_id);
CREATE INDEX idx_tm_composite ON TrafficMeasurement(measurement_site_id, timestamp);

-- MeasurementSite indexes
-- Used in: all traffic views (JOIN condition)
CREATE INDEX idx_ms_counting_site_id ON MeasurementSite(counting_site_id);

-- Population indexes
-- Used in: v_population_yearly, v_population_city_yearly, v_kpi1
CREATE INDEX idx_pop_reference_date ON Population(reference_date_year);
CREATE INDEX idx_pop_district_quarter ON Population(city_district, statistical_quarter);
CREATE INDEX idx_pop_composite ON Population(city_district, statistical_quarter, reference_date_year);

-- Quarter indexes
-- Used in: v_traffic_yearly (JOIN on street_name)
CREATE INDEX idx_quarter_street ON Quarter(street_name);
CREATE INDEX idx_quarter_district ON Quarter(city_district);
