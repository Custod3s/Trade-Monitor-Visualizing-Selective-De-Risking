# -------------------------------------------------------------------------
# Purpose: Perform Chow Test to confirm Structural Break in Trade Data
# -------------------------------------------------------------------------

# 1. Load Libraries
library(strucchange)
library(dplyr)
library(readr)
library(here)
library(lubridate)

# 2. Load and Prepare Data
# ---------------------------------------------------------
data <- read_csv(here::here("10_Data/11_Processed/01_data_clean_sitc.csv"), 
                 col_types = cols(date = col_date(format = "%Y-%m-%d")))

# Filter for High-Tech Imports from China (The "Blue Line")
# We start from 2022 to exclude post-COVID volatility (2021 noise), 
# ensuring we detect policy shifts rather than pandemic recovery anomalies.
ts_data <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "High-Tech & Strategic") %>%
  filter(date >= "2022-01-01") %>%
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

print(paste("Number of rows:", nrow(ts_data)))

# Convert to Time Series Object (TS)
# Start = Jan 2022 (Year 2022, Month 1), Frequency = 12 (Monthly)
ts_val <- ts(ts_data$values, start = c(2022, 1), frequency = 12)

# 3. The F-Statistics Test (Finding the Break)
# ---------------------------------------------------------
# This tests every single month to see where the biggest "break" in the trend is.
fs <- Fstats(ts_val ~ 1)

# Plot the F-Statistics (Visual Proof)
plot(fs, main = "Structural Break Test (F-Statistics)")
lines(breakpoints(fs))

# 4. Extract the Exact Break Date
# ---------------------------------------------------------
bp <- breakpoints(ts_val ~ 1)
break_date_index <- bp$breakpoints

# Convert index back to a real date
break_date <- time(ts_val)[break_date_index]
print(paste("⚠️ STATISTICAL BREAK DETECTED AT:", break_date))

# 5. The Chow Test (Confirmation)
# ---------------------------------------------------------
# STRATEGY IMPACT ANALYSIS:
# We look for the most significant break specifically AFTER the Strategy Release (June 2023).
# This allows for "Implementation Lag" (e.g., market reacting in Oct/Nov) without
# picking up earlier noise (like the 2022 Energy Crisis).

# Get the F-statistics series
fs_ts <- fs$Fstats

# Define the search window: Start searching from June 2023 (2023.417 in decimal year)
# 2023 + (5/12) = 2023.41666... (June is the 6th month, so index 6, but usually time(ts) is year + (month-1)/12)
search_start_time <- 2023 + (5/12) 

# Filter F-stats to only include dates >= June 2023
window_fs <- window(fs_ts, start = search_start_time)

# Find the time index where F-statistic is MAXIMUM in this window
max_fs_index <- which.max(window_fs)
optimal_break_time <- time(window_fs)[max_fs_index]

# Convert this time (e.g., 2023.833) back to an integer index relative to the full series start (Jan 2022)
# Formula: (Year - Start_Year) * 12 + Month
optimal_break_date_val <- date_decimal(as.numeric(optimal_break_time))
# Round to nearest month to be safe (date_decimal can be slighty off)
optimal_break_date <- round_date(optimal_break_date_val, unit = "month")

# Calculate the 1-based index for the Chow Test "point" parameter
# ts_val starts Jan 2022. 
start_date <- as.Date("2022-01-01")
optimal_break_index <- length(seq(from = start_date, to = optimal_break_date, by = "month"))

print(paste("🔹 STRATEGY IMPACT SEARCH: Max structural shift (Reaction) found at", format(optimal_break_date, "%B %Y")))

# Convert index to date for reporting
optimal_break_date <- as.Date("2022-01-01") %m+% months(optimal_break_index - 1)
print(paste("🔹 Optimal Break Point Used:", format(optimal_break_date, "%B %Y")))

# Run Chow Test at this dynamically found point
chow_test_covid <- sctest(ts_val ~ 1, type = "Chow", point = optimal_break_index)

print("--- CHOW TEST RESULTS ---")
print(chow_test_covid)

# Save results for report
results <- list(
  break_date = as.character(optimal_break_date),
  chow_statistic = chow_test_covid$statistic,
  chow_p_value = chow_test_covid$p.value,
  f_max = max(fs$Fstats, na.rm = TRUE)
)

saveRDS(results, here::here("30_Report/strucchange_results.rds"))
write_csv(as_tibble(results), here::here("30_Report/strucchange_results.csv"))

cat("\n=== STRUCTURAL BREAK ANALYSIS ===\n")
cat("Break detected at:", results$break_date, "\n")
cat("Chow statistic:", round(results$chow_statistic, 2), "\n")
cat("P-value:", format(results$chow_p_value, scientific = TRUE), "\n")
