library(dplyr)
library(readr)
library(tidyr)
library(zoo)
library(stringr)

# 1. Fetch Data
# ---------------------------------------------------------
bis_url <- "https://stats.bis.org/api/v2/data/dataflow/BIS/WS_LBS_D_PUB/1.0/Q..C.A.USD....5A.A.CN?startPeriod=2020-01-01&endPeriod=2025-12-31&format=csv"
df_bis_raw <- read_csv(bis_url, show_col_types = FALSE)

# 2. Clean, Filter, and Aggregate (The Fix)
# ---------------------------------------------------------
df_bis_clean <- df_bis_raw %>%
  # Filter for "S" (Stock/Amounts Outstanding) to fix the duplicate issue
  filter(L_MEASURE == "S") %>%
  
  # Select raw columns
  select(quarter = TIME_PERIOD, claims_usd = OBS_VALUE) %>%
  
  # Handle any remaining duplicates by averaging (Safety Step)
  group_by(quarter) %>%
  summarise(claims_usd = mean(claims_usd, na.rm = TRUE), .groups = "drop") %>%
  
  # CRITICAL FIX: Create the 'date' column AFTER summarising
  mutate(date = as.Date(as.yearqtr(quarter, format = "%Y-Q%q")))

# 3. Frequency Conversion (Quarterly -> Monthly)
# ---------------------------------------------------------
df_bis_monthly <- df_bis_clean %>%
  # Now 'date' definitely exists, so this line will work
  complete(date = seq.Date(from = min(date), 
                           to = max(date) + 90, 
                           by = "month")) %>%
  
  # Fill the quarterly value down to the empty months (Step line)
  fill(claims_usd, .direction = "down") %>%
  
  # Trim overflow and add label
  filter(date <= as.Date("2025-12-31")) %>%
  mutate(sector_group = "Financial Exposure (BIS)") %>%
  
  # Keep only what we need for the plot
  select(date, value = claims_usd, sector_group)

# 4. Save
# ---------------------------------------------------------
print(head(df_bis_monthly))
View(df_bis_monthly)

write_csv(
  df_bis_monthly,
  "10_Data/12_Raw/BIS_Financial_Exposure_EU_CN_2020-2025.csv"
)
