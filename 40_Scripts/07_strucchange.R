# -------------------------------------------------------------------------
# Script: 02_strucchange.R
# Purpose: Perform Chow Test to confirm Structural Break in Trade Data
# -------------------------------------------------------------------------

# 1. Load Libraries
library(strucchange)
library(dplyr)
library(readr)

# 2. Load and Prepare Data
# ---------------------------------------------------------
data <- read_csv("10_Data/11_Processed/01_data_clean_sitc.csv", 
                 col_types = cols(date = col_date(format = "%Y-%m-%d")))
View(data)

# Filter for High-Tech Imports from China (The "Blue Line")
ts_data <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "High-Tech & Strategic") %>%
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

print(paste("Number of rows:", nrow(ts_data)))

# Convert to Time Series Object (TS)
# Start = Jan 2020 (Year 2020, Month 1), Frequency = 12 (Monthly)
ts_val <- ts(ts_data$values, start = c(2020, 1), frequency = 12)

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
# We test specifically against the "De-risking" start date (approx Jan 2023)
# Note: In TS decimal time, Jan 2023 is exactly 2023.00
break_index <- which(time(ts_val) == 2023.0) 
chow_test_covid <- sctest(ts_val ~ 1, type = "Chow", point = break_index)

print("--- CHOW TEST RESULTS ---")
print(chow_test)

ts_data_c <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "High-Tech & Strategic") %>%
  filter(date >= "2021-01-01") %>%   # <--- Look after COVID
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

# Convert to Time Series Object (TS)
# Start = Jan 2020 (Year 2020, Month 1), Frequency = 12 (Monthly)
ts_val <- ts(ts_data$values, start = c(2020, 1), frequency = 12)

chow_test_covid <- sctest(ts_val ~ 1, type = "Chow", point = 25)
print(chow_test_covid)

