# -------------------------------------------------------------------------
# Script: 05_grand_unification.R
# Purpose: Merge Trade (Eurostat) and Finance (BIS) into one "Master Plot"
# -------------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(readr)
library(zoo)
source("40_Scripts/00_style.R")


# 1. Load the Two Datasets
# ---------------------------------------------------------
trade_data <- read_csv("10_Data/11_Processed/01_data_clean_sitc.csv", 
                       col_types = cols(date = col_date(format = "%Y-%m-%d")))
View(trade_data)

finance_data <- read_delim("10_Data/12_Raw/BIS_Financial_Exposure_EU_CN_2020-2025.csv", 
                             delim = ";", escape_double = FALSE, col_types = cols(date = col_date(format = "%Y-%m-%d")), 
                             trim_ws = TRUE)
View(finance_data)

# 2. Process Trade Data (Smooth & Index)
# ---------------------------------------------------------
trade_indexed <- trade_data %>%
  # Filter for China & the two key sectors
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group %in% c("High-Tech & Strategic", "Traditional & Basic")) %>%
  
  # Aggregate up to monthly totals (summing sub-sectors)
  group_by(date, sector_group) %>%
  summarise(values = sum(values, na.rm = TRUE), .groups = "drop") %>%
  
  # Apply 3-Month Rolling Average (Smoother lines)
  group_by(sector_group) %>%
  mutate(smooth_value = rollmean(values, k = 3, fill = NA, align = "center")) %>%  
  
  # Index to Jan 2023 = 100
  group_by(sector_group) %>%
  mutate(
    # Calculate the average value for the entire year of 2022
    base_val = mean(smooth_value[format(date, "%Y") == "2022"], na.rm = TRUE),
    index_val = (smooth_value / base_val) * 100
  ) %>%
  select(date, sector_group, index_val)

View(trade_indexed)

# 3. Process Finance Data (Index Only)
# ---------------------------------------------------------
# Note: BIS data was already step-filled to monthly in Script 04
finance_indexed <- finance_data %>%
  mutate(
    # Index to Jan 2023 = 100
    base_val = mean(value[format(date, "%Y") == "2022"], na.rm = TRUE),
    index_val = (value / base_val) * 100
  ) %>%
  select(date, sector_group, index_val)

# 4. Merge and Filter Time Window
# ---------------------------------------------------------
plot_data <- bind_rows(trade_indexed, finance_indexed) # %>%
        # filter(date >= "2022-01-01") # Zoom in to show the pre-strategy vs post-strategy

# 5. Generate the "Money Plot"
# ---------------------------------------------------------
p <- ggplot(plot_data, aes(x = date, y = index_val, color = sector_group, linetype = sector_group)) +
  
  # Reference Lines
  geom_hline(yintercept = 100, color = "black", linetype = "dotted") +
  geom_vline(xintercept = as.Date("2022-11-01"), color = "#D9534F", linetype = "dashed") +
  
  # The Data Lines
  geom_line(linewidth = 1.2) +
  
  # Custom Colors & Line Types
  scale_color_manual(values = c(
    "High-Tech & Strategic"   = "#005f73",  # Deep Teal (Strategic)
    "Traditional & Basic" = "#94a3b8",  # Cool Grey (Background/Control)
    "Financial Exposure (BIS)" = "#b91c1c"   # Bold Red (Warning/Capital Flight)
  )) +
  scale_linetype_manual(values = c(
    "High-Tech & Strategic" = "solid",
    "Traditional & Basic" = "solid",
    "Financial Exposure (BIS)" = "longdash" # Dashed to indicate it's a different data source
  )) +
  
  # Labels and Theme
  labs(
    title = "The Dual De-Risking: Trade & Finance Divergence",
    subtitle = "Since Jan 2023, EU Banks and High-Tech Importers have both reduced exposure.",
    y = "Index (Jan 2023 = 100)",
    x = "",
    caption = "Sources: Eurostat (Trade), BIS Locational Banking Statistics (Finance)"
  ) +
  theme_esc() +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.title = element_text(face = "bold", size = 14)
  )

# 6. Save Output
# ---------------------------------------------------------
print(p)
ggsave("20_Images/05_grand_unification_No_zoom.png", width = 10, height = 6, dpi = 300)

