# =====================================================
# PROJECT: ECB Data Challenge - Flight 1
# SCRIPT: 04_bis_data_correction.R
# =====================================================

library(dplyr)
library(readr)
library(tidyr)
library(zoo)        # Essential for interpolation
library(stringr)
library(scales)
library(ggplot2)
library(lubridate)
source("40_Scripts/00_style.R") # Ensure this path is correct relative to your project

# 1. Fetch Data
# ---------------------------------------------------------
# Note: L_MEASURE="S" (Amounts Outstanding), L_POSITION="C" (Total Claims), L_POS_TYPE="N" (Cross-border)
bis_url <- "https://stats.bis.org/api/v2/data/dataflow/BIS/WS_LBS_D_PUB/1.0/Q..C.A.TO1....5C+AT+BE+CY+DE+ES+FI+FR+GR+IE+IT+LU+NL+PT.A.CN?startPeriod=2020-01-01&endPeriod=2026-01-13&format=csv"
df_bis_raw <- read_csv(bis_url, show_col_types = FALSE)

# 2. Define Eurozone
eurozone_iso <- c("AT", "BE", "CY", "EE", "FI", "FR", "DE", "GR", 
                  "HR", "IE", "IT", "LV", "LT", "LU", "MT", "NL", 
                  "PT", "SK", "SI", "ES")

# 3. Process & Interpolate
# ---------------------------------------------------------
bis_quarterly <- df_bis_raw %>%
  filter(L_REP_CTY %in% eurozone_iso) %>%
  filter(L_CP_COUNTRY == "CN") %>%
  filter(L_MEASURE == "S", L_POSITION == "C", L_POS_TYPE == "N") %>%
  group_by(TIME_PERIOD) %>%
  summarize(quarterly_value = sum(OBS_VALUE, na.rm = TRUE)) %>%
  ungroup() %>%
  # Convert "2023-Q1" string to a real Date (set to 1st month of quarter)
  mutate(date = as.Date(as.yearqtr(TIME_PERIOD, format = "%Y-Q%q")))
View(bis_quarterly)

# 3. The "Skeleton Key" (Force the Timeline)
# ---------------------------------------------------------
# Create a dataframe with EVERY month from start to finish.
# This ensures "Dates missing" is impossible.
min_date <- min(bis_quarterly$date)
max_date <- max(bis_quarterly$date) # Or use Sys.Date() if you want up to today

date_grid <- tibble(
  date = seq.Date(from = min_date, to = max_date, by = "month")
)

# 4. Merge & Interpolate
# ---------------------------------------------------------
clean_df_bis <- date_grid %>%
  # Join Quarterly data onto the Monthly grid
  left_join(bis_quarterly, by = "date") %>%
  
  # INTERPOLATION MAGIC
  # 1. na.approx: Draws a straight line between Q1 and Q2 to fill the months
  # 2. na.locf: "Last Observation Carried Forward" fills any trailing NA at the end
  mutate(values = na.approx(quarterly_value, na.rm = FALSE)) %>%
  mutate(values = na.locf(values, na.rm = FALSE)) %>%
  mutate(sector_group = "Financial Exposure (BIS)") %>%
  
  # Final Cleanup
  select(date, values, sector_group) %>%
  filter(!is.na(values)) # Remove any leading NAs if data started later than min_date

# 4. Export Final Merged File
# ---------------------------------------------------------
write_csv(clean_df_bis, "10_Data/11_Processed/cleaned_BIS_monthly_all_indicators.csv")

# 5. Visualization (Updated Column Name)
# ---------------------------------------------------------
ggplot(clean_df_bis, aes(x = Date, y = values)) +
  # Using linewidth (new standard) to avoid warnings
  geom_line(color = "#2c3e50", linewidth = 1) + 
  geom_point(color = "#e74c3c", size = 2) +
  
  # English Labels and Titles
  labs(
    title = "Eurozone Banking Claims on China",
    subtitle = "Total cross-border claims in millions of USD (2020 - 2026)",
    x = "Year",
    y = "Total Claims (USD Millions)",
    caption = "Source: BIS Locational Banking Statistics (LBS)"
  ) +
  
  # Robust formatting for numbers (works without needing new scales functions)
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  
  # Theme
  theme_esc() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "grey30"),
    panel.grid.minor = element_blank(),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10))
  )
ggsave("20_Images/06_banking_claims_CN_all_indic.png", width = 10, height = 6, dpi = 300)

