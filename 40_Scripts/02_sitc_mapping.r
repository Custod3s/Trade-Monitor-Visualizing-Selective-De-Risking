library(dplyr)
library(readr)
library(tidyr)
library(stringr)

setwd("/Users/alex/Programming/ECB_Data_Challenge")

trade_raw <- read_delim("Data/pulled_EU_CN_VN_US_2020-2025.csv", 
                        delim = ";", escape_double = FALSE, col_types = cols(freq = col_skip(), 
                                                                             stk_flow = col_skip(), geo = col_skip(), 
                                                                             TIME_PERIOD = col_date(format = "%Y-%m-%d")), 
                        trim_ws = TRUE)

View(trade_raw)

df_clean <- trade_raw %>%
  # Standardize column names (optional but safer)
  rename(
    date = TIME_PERIOD,
    description = sitc06
  ) %>%
  
  # Create the 'sitc_code' column by mapping the descriptions
  mutate(
    sitc_code = case_when(
      str_detect(description, "5") ~ "5",
      str_detect(description, "6") ~ "6",
      str_detect(description, "7") ~ "7",
      str_detect(description, "8") ~ "8",
      TRUE ~ "Unknown" # Safety catch
    )
  ) %>%
  
  # Select only the columns you need for the analysis
  select(date, partner, sitc_code, values)

View(df_clean)
# Function to categorize SITC codes
# Input: A dataframe with a column named 'sitc_code' (e.g., "5", "7", "64", etc.)
categorize_trade <- function(df) {
  df %>%
    mutate(
      # Extract the first digit just in case the data is granular (e.g., "752")
      
      # Create the Strategy Buckets
      sector_group = case_when(
        sitc_code %in% c("5", "7") ~ "High-Tech & Strategic",
        sitc_code %in% c("6", "8") ~ "Traditional & Basic",
        TRUE ~ "Other" # For food, fuel, etc. (SITC 0-4)
      )
    ) %>%
    summarize(
      values = sum(values, na.rm = TRUE),
      .by = c(date, partner, sector_group)
    )
}

df_categorized <- categorize_trade(df_clean) %>%
  select(date, partner, sector_group, values)
View(df_categorized)

write.csv(df_categorized, file = "10_Data/01_data_clean_sitc.csv", row.names = FALSE)


