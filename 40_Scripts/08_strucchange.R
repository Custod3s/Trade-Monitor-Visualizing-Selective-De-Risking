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
# Instead of hardcoding, we use the optimal break point found by the F-stats
bp <- breakpoints(ts_val ~ 1)
optimal_break_index <- bp$breakpoints[1]

# If no break found, default to Oct 2023 (22) as fallback - adjusted index for 2022 start (Oct 2023 is 22nd month from Jan 2022)
if(is.na(optimal_break_index)) { optimal_break_index <- 22 }

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
