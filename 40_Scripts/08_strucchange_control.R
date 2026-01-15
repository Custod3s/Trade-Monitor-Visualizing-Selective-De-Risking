# 1. Load Libraries
library(strucchange)
library(dplyr)
library(readr)

# 2. Load and Prepare Data
# ---------------------------------------------------------
data <- read_csv(here::here("10_Data/11_Processed/01_data_clean_sitc.csv"), 
                 col_types = cols(date = col_date(format = "%Y-%m-%d")))
View(data)



# 2. Filter for the CONTROL GROUP ("Traditional & Basic")
# We use the exact same timeframe (post-2021) to be fair.
ts_data_control <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "Traditional & Basic") %>%
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

print(paste("Number of rows:", nrow(ts_data)))

# 3. Create Time Series
# Start Jan 2021, Frequency 12
ts_control <- ts(ts_data_control$values, start = c(2021, 1), frequency = 12)

# 4. Run Chow Test (Same Date: Jan 2023)
# Jan 2023 is the 25th observation in a series starting Jan 2021.
chow_test_control <- sctest(ts_control ~ 1, type = "Chow", point = 25)

print("--- CONTROL GROUP RESULTS (Traditional Trade) ---")
print(chow_test_control)

# Save results for report
results <- list(
  break_date = as.character(break_date),
  chow_statistic = chow_test$statistic,
  chow_p_value = chow_test$p.value,
  f_max = max(fs$Fstats, na.rm = TRUE)
)

saveRDS(results, here::here("30_Report/strucchange__control_results.rds"))
write_csv(as_tibble(results), here::here("30_Report/strucchange_control_results.csv"))

cat("\n=== STRUCTURAL BREAK ANALYSIS ===\n")
cat("Break detected at:", results$break_date, "\n")
cat("Chow statistic:", round(results$chow_statistic, 2), "\n")
cat("P-value:", format(results$chow_p_value, scientific = TRUE), "\n")