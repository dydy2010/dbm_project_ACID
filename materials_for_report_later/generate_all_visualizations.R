# ============================================================================
# DATABASE PROJECT - ALL KPI VISUALIZATIONS
# ============================================================================
# This script generates all visualizations for the Zurich Traffic Analysis report
# Author: Team ACID
# Date: 2025-12-17
#
# Output: 8 high-resolution PNG charts (300 DPI) saved to screenshots folder
# ============================================================================

# Load required libraries
cat("Loading required packages...\n")
library(ggplot2)
library(readxl)
library(dplyr)
library(scales)
library(forcats)

# Set working directory and output path
setwd("/Users/dongyuangao/Desktop/dbm_project_ACID/scripts")
output_dir <- "../materials_for_report_later/screenshots"

cat("Starting visualization generation...\n\n")

# ============================================================================
# KPI 0: POPULATION & TRAFFIC TRENDS (2012-2025)
# ============================================================================
cat("Generating KPI 0: Population & Traffic Trends...\n")

data_kpi0 <- read_excel("../result data/population_trafficAVG_yearly.xlsx")

# Calculate scaling factor for dual axis
pop_range <- range(data_kpi0$`Population City`, na.rm = TRUE)
traffic_range <- range(data_kpi0$`Avg Vehicle Count City`, na.rm = TRUE)
scale_factor <- (pop_range[2] - pop_range[1]) / (traffic_range[2] - traffic_range[1])

p_kpi0 <- ggplot(data_kpi0, aes(x = Year)) +
  geom_line(aes(y = `Population City`, color = "Population"), size = 1.2) +
  geom_point(aes(y = `Population City`, color = "Population"), size = 3) +
  geom_line(aes(y = `Avg Vehicle Count City` * scale_factor, color = "Traffic Intensity"), 
            size = 1.2, linetype = "dashed") +
  geom_point(aes(y = `Avg Vehicle Count City` * scale_factor, color = "Traffic Intensity"), 
             size = 3, shape = 17) +
  annotate("rect", xmin = 2020, xmax = 2021, ymin = -Inf, ymax = Inf, 
           alpha = 0.2, fill = "grey") +
  annotate("text", x = 2020.5, y = max(data_kpi0$`Population City`) * 0.95, 
           label = "COVID-19", size = 3.5, fontface = "italic") +
  scale_y_continuous(
    name = "Population (Total)",
    labels = comma,
    sec.axis = sec_axis(~ . / scale_factor, 
                        name = "Average Traffic Intensity\n(Vehicles/Hour)",
                        labels = comma)
  ) +
  scale_color_manual(
    name = "",
    values = c("Population" = "#2E86AB", "Traffic Intensity" = "#A23B72"),
    labels = c("Population (Total)", "Traffic Intensity (Avg Vehicles/Hour)")
  ) +
  labs(
    title = "Zurich: Population Growth vs. Traffic Intensity (2012-2025)",
    subtitle = "Citywide yearly trends showing relationship between demographic and mobility development",
    x = "Year",
    caption = "Data source: City of Zurich Open Data Portal"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    panel.grid.minor = element_blank(),
    axis.title.y.right = element_text(color = "#A23B72"),
    axis.text.y.right = element_text(color = "#A23B72"),
    axis.title.y.left = element_text(color = "#2E86AB"),
    axis.text.y.left = element_text(color = "#2E86AB")
  )

ggsave(file.path(output_dir, "kpi0_population_traffic_trends.png"), 
       plot = p_kpi0, width = 10, height = 6, dpi = 300, bg = "white")
cat("✓ KPI 0 saved\n\n")

# ============================================================================
# KPI 1: DISTRICT STRESS INDEX
# ============================================================================
cat("Generating KPI 1: Stress Index...\n")

data_kpi1 <- read_excel("../result data/quarter_stress_index.xlsx")

data_kpi1 <- data_kpi1 %>%
  mutate(
    has_complete_data = `Stress Classification` != "Insufficient data",
    classification_ordered = factor(`Stress Classification`, 
                                    levels = c("Residential pressure", 
                                              "Balanced", 
                                              "Commuter pressure",
                                              "Insufficient data"))
  )

# Chart 1: By Quarter
p_kpi1_quarter <- ggplot(data_kpi1, 
                         aes(x = reorder(`Quarter Name`, `Stress Index Pct`, na.rm = TRUE), 
                             y = `Stress Index Pct`, 
                             fill = classification_ordered)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size = 0.5) +
  scale_fill_manual(
    values = c(
      "Residential pressure" = "#3A86FF",
      "Balanced" = "#90BE6D",
      "Commuter pressure" = "#F94144",
      "Insufficient data" = "#CCCCCC"
    ),
    name = "Classification"
  ) +
  labs(
    title = "Stress Index by Statistical Quarter",
    subtitle = "Traffic Growth % minus Population Growth % (2012-2025)\nPositive = Commuter Pressure | Negative = Residential Pressure",
    x = "Statistical Quarter",
    y = "Stress Index (%)",
    caption = "Grey bars indicate insufficient traffic data for reliable calculation"
  ) +
  coord_flip() +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 9, color = "grey30"),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(file.path(output_dir, "kpi1_stress_index_by_quarter.png"), 
       plot = p_kpi1_quarter, width = 10, height = 12, dpi = 300, bg = "white")

# Chart 2: By District
district_summary <- data_kpi1 %>%
  filter(has_complete_data) %>%
  group_by(`District ID`) %>%
  summarise(
    avg_stress = mean(`Stress Index Pct`, na.rm = TRUE),
    n_quarters = n(),
    .groups = "drop"
  ) %>%
  mutate(
    classification = case_when(
      avg_stress > 10 ~ "Commuter pressure",
      avg_stress < -10 ~ "Residential pressure",
      TRUE ~ "Balanced"
    ),
    classification = factor(classification, 
                           levels = c("Residential pressure", "Balanced", "Commuter pressure"))
  )

p_kpi1_district <- ggplot(district_summary, 
                          aes(x = factor(`District ID`), 
                              y = avg_stress, 
                              fill = classification)) +
  geom_col() +
  geom_hline(yintercept = c(-10, 10), linetype = "dashed", color = "grey50", size = 0.5) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", size = 0.7) +
  scale_fill_manual(
    values = c(
      "Residential pressure" = "#3A86FF",
      "Balanced" = "#90BE6D",
      "Commuter pressure" = "#F94144"
    ),
    name = "Classification"
  ) +
  labs(
    title = "Average Stress Index by City District",
    subtitle = "Districts with complete traffic data | Dashed lines mark ±10% classification thresholds",
    x = "City District",
    y = "Average Stress Index (%)",
    caption = "Based on quarters with complete 2012 and 2025 traffic measurements"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave(file.path(output_dir, "kpi1_stress_index_by_district.png"), 
       plot = p_kpi1_district, width = 10, height = 6, dpi = 300, bg = "white")
cat("✓ KPI 1 (2 charts) saved\n\n")

# ============================================================================
# KPI 2: TRAFFIC BOTTLENECKS
# ============================================================================
cat("Generating KPI 2: Bottlenecks...\n")

data_kpi2 <- read_excel("../result data/bottleneck_and_peakhour.xlsx")

# Chart 1: Top 20 Bottlenecks
bottlenecks <- data_kpi2 %>%
  filter(Status == "Bottleneck") %>%
  arrange(desc(`Avg Volume`)) %>%
  slice_head(n = 20) %>%
  mutate(
    peak_hour_num = as.numeric(substr(`Peak Hour`, 1, 2)),
    hour_category = case_when(
      peak_hour_num >= 6 & peak_hour_num < 10 ~ "Morning Rush (06-10)",
      peak_hour_num >= 10 & peak_hour_num < 15 ~ "Midday (10-15)",
      peak_hour_num >= 15 & peak_hour_num < 20 ~ "Evening Rush (15-20)",
      TRUE ~ "Other"
    ),
    hour_category = factor(hour_category, 
                          levels = c("Morning Rush (06-10)", 
                                    "Midday (10-15)", 
                                    "Evening Rush (15-20)", 
                                    "Other"))
  )

p_kpi2_top <- ggplot(bottlenecks, 
                     aes(x = reorder(`Counting Site Name`, `Avg Volume`), 
                         y = `Avg Volume`,
                         fill = hour_category)) +
  geom_col() +
  geom_text(aes(label = `Peak Hour`), hjust = -0.2, size = 3) +
  scale_fill_manual(
    values = c(
      "Morning Rush (06-10)" = "#F4A261",
      "Midday (10-15)" = "#E9C46A",
      "Evening Rush (15-20)" = "#E76F51",
      "Other" = "#264653"
    ),
    name = "Peak Hour Period"
  ) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Top 20 Traffic Bottlenecks in Zurich",
    subtitle = "Sites with highest average peak-hour vehicle counts (2023-2025)",
    x = "",
    y = "Average Vehicles per Hour (Peak)",
    caption = "Threshold: 700 vehicles/hour | Peak hour shown on right side of bars"
  ) +
  coord_flip() +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(file.path(output_dir, "kpi2_top_bottlenecks.png"), 
       plot = p_kpi2_top, width = 10, height = 8, dpi = 300, bg = "white")

# Chart 2: Distribution by Hour
hour_distribution <- data_kpi2 %>%
  filter(Status == "Bottleneck") %>%
  mutate(peak_hour_num = as.numeric(substr(`Peak Hour`, 1, 2))) %>%
  count(peak_hour_num, name = "bottleneck_count")

p_kpi2_hour <- ggplot(hour_distribution, 
                      aes(x = factor(peak_hour_num), y = bottleneck_count)) +
  geom_col(fill = "#E76F51", alpha = 0.8) +
  geom_text(aes(label = bottleneck_count), vjust = -0.5, size = 3.5) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "When Do Bottlenecks Occur?",
    subtitle = paste0("Distribution of peak hours across all bottleneck sites (n = ", 
                     sum(data_kpi2$Status == "Bottleneck"), ")"),
    x = "Hour of Day",
    y = "Number of Bottleneck Sites",
    caption = "Data period: 2023-2025"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

ggsave(file.path(output_dir, "kpi2_bottleneck_by_hour.png"), 
       plot = p_kpi2_hour, width = 10, height = 6, dpi = 300, bg = "white")
cat("✓ KPI 2 (2 charts) saved\n\n")

# ============================================================================
# KPI 3: DIRECTIONAL FLOW ANALYSIS
# ============================================================================
cat("Generating KPI 3: Directional Flow...\n")

data_kpi3 <- read_excel("../result data/street_flow_direction.xlsx")
data_kpi3 <- data_kpi3 %>% filter(!is.na(`Dominance Share`))

# Chart 1: Classification Distribution (Pie Chart)
classification_summary <- data_kpi3 %>%
  count(Classification) %>%
  mutate(
    percentage = n / sum(n) * 100,
    label = paste0(n, " sites\n(", round(percentage, 1), "%)")
  )

p_kpi3_pie <- ggplot(classification_summary, aes(x = "", y = n, fill = Classification)) +
  geom_col(width = 1, color = "white", linewidth = 1) +
  geom_text(aes(label = label), 
            position = position_stack(vjust = 0.5),
            size = 4, fontface = "bold", color = "white") +
  coord_polar(theta = "y") +
  scale_fill_manual(
    values = c(
      "Strong corridor dependency" = "#D62828",
      "Moderate directional preference" = "#F77F00",
      "Balanced intersection" = "#90BE6D"
    )
  ) +
  labs(
    title = "Directional Flow Balance Across Zurich",
    subtitle = paste0("Classification of ", nrow(data_kpi3), " counting sites based on dominant direction share"),
    caption = "Strong = >60% | Moderate = 50-60% | Balanced = <50%"
  ) +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "grey30", hjust = 0.5),
    plot.caption = element_text(size = 9, color = "grey50", hjust = 0.5),
    legend.position = "bottom",
    legend.title = element_blank()
  )

ggsave(file.path(output_dir, "kpi3_classification_distribution.png"), 
       plot = p_kpi3_pie, width = 8, height = 8, dpi = 300, bg = "white")

# Chart 2: Top 15 Imbalanced Sites
top_imbalanced <- data_kpi3 %>%
  filter(Classification == "Strong corridor dependency") %>%
  arrange(desc(`Dominance Share`)) %>%
  slice_head(n = 15)

p_kpi3_top <- ggplot(top_imbalanced, 
                     aes(x = reorder(`Counting Site Name`, `Dominance Share`), 
                         y = `Dominance Share`,
                         fill = `Dominant Direction`)) +
  geom_col() +
  geom_text(aes(label = paste0(round(`Dominance Share` * 100, 1), "%")), 
            hjust = -0.1, size = 3) +
  scale_y_continuous(labels = percent, limits = c(0, 1), 
                    expand = expansion(mult = c(0, 0.08))) +
  scale_fill_brewer(palette = "Set2", name = "Dominant\nDirection") +
  labs(
    title = "Top 15 Sites with Strongest Directional Imbalance",
    subtitle = "Sites where one direction dominates traffic flow (>60% of total volume)",
    x = "",
    y = "Dominance Share (% of Total Traffic)",
    caption = "Data period: 2023-2025 | Percentage labels show share of dominant direction"
  ) +
  coord_flip() +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    legend.position = "right",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(file.path(output_dir, "kpi3_top_imbalanced_sites.png"), 
       plot = p_kpi3_top, width = 11, height = 8, dpi = 300, bg = "white")

# Chart 3: Dominance Distribution Histogram
p_kpi3_hist <- ggplot(data_kpi3, aes(x = `Dominance Share`, fill = Classification)) +
  geom_histogram(bins = 20, color = "white", alpha = 0.8) +
  geom_vline(xintercept = c(0.5, 0.6), linetype = "dashed", 
             color = "black", linewidth = 0.7) +
  annotate("text", x = 0.55, y = Inf, label = "Moderate\nThreshold", 
           vjust = 1.5, size = 3, fontface = "italic") +
  annotate("text", x = 0.65, y = Inf, label = "Strong\nThreshold", 
           vjust = 1.5, size = 3, fontface = "italic") +
  scale_x_continuous(labels = percent) +
  scale_fill_manual(
    values = c(
      "Strong corridor dependency" = "#D62828",
      "Moderate directional preference" = "#F77F00",
      "Balanced intersection" = "#90BE6D"
    )
  ) +
  labs(
    title = "Distribution of Directional Dominance",
    subtitle = "How traffic is distributed across directions at all counting sites",
    x = "Dominance Share (% of Traffic in Dominant Direction)",
    y = "Number of Sites",
    caption = "Vertical lines mark classification thresholds at 50% and 60%"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    legend.position = "bottom",
    legend.title = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(file.path(output_dir, "kpi3_dominance_distribution.png"), 
       plot = p_kpi3_hist, width = 10, height = 6, dpi = 300, bg = "white")
cat("✓ KPI 3 (3 charts) saved\n\n")

# ============================================================================
# SUMMARY
# ============================================================================
cat("============================================================================\n")
cat("VISUALIZATION GENERATION COMPLETE\n")
cat("============================================================================\n")
cat("Total charts generated: 8\n")
cat("Output directory:", output_dir, "\n\n")

generated_files <- list.files(output_dir, pattern = "^kpi.*\\.png$", full.names = FALSE)
cat("Generated files:\n")
for(file in generated_files) {
  cat(paste0("  ✓ ", file, "\n"))
}

cat("\n✓ All visualizations ready for report!\n")
