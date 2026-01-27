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



# 2. Filter for the CONTROL GROUP ("Traditional & Basic")
# We use the exact same timeframe (post-2022) to be fair.
ts_data_control <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "Traditional & Basic") %>%
  filter(date >= "2022-01-01") %>%
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

print(paste("Number of rows:", nrow(ts_data_control)))

# Convert to Time Series Object (TS)
# Start = Jan 2022 (Year 2022, Month 1), Frequency = 12 (Monthly)
ts_val <- ts(ts_data_control$values, start = c(2022, 1), frequency = 12)

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

# 3. Create Time Series
# Start Jan 2022, Frequency 12
ts_control <- ts(ts_data_control$values, start = c(2022, 1), frequency = 12)

# 4. Run Chow Test (Using Break Date from High-Tech Analysis)
# ---------------------------------------------------------
# Load the dynamically calculated break date from the High-Tech analysis
break_results <- readRDS(here::here("30_Report/strucchange_results.rds"))
optimal_break_date <- as.Date(break_results$break_date)
print(paste("Using High-Tech Break Date for Control Group:", optimal_break_date))

# Calculate the index for this date in the time series (Starts Jan 2022)
# Logic: (Year_Diff * 12) + Month_Diff + 1 (because TS is 1-indexed)
start_year <- 2022
break_index <- (year(optimal_break_date) - start_year) * 12 + month(optimal_break_date)

print(paste("Calculated Break Index:", break_index))

chow_test_control <- sctest(ts_control ~ 1, type = "Chow", point = break_index)

print("--- CONTROL GROUP RESULTS (Traditional Trade) ---")
print(chow_test_control)

# Save results for report
results <- list(
  break_date = as.character(optimal_break_date), # Use the date we actually tested against
  chow_statistic = chow_test_control$statistic,
  chow_p_value = chow_test_control$p.value,
  f_max = max(fs$Fstats, na.rm = TRUE)
)

saveRDS(results, here::here("30_Report/strucchange_control_results.rds"))
write_csv(as_tibble(results), here::here("30_Report/strucchange_control_results.csv"))

cat("\n=== STRUCTURAL BREAK ANALYSIS ===\n")
cat("Break detected at:", results$break_date, "\n")
cat("Chow statistic:", round(results$chow_statistic, 2), "\n")
cat("P-value:", format(results$chow_p_value, scientific = TRUE), "\n")