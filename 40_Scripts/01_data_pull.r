library(eurostat)
library(dplyr)
library(readr)

# =====================================================
# LOAD DATA FROM EUROSTAT API
# =====================================================
trade_raw <- get_eurostat(
  "ext_st_easitc",
  time_format = "date"
)

# =====================================================
# FILTER – MATCHES CSV USED IN SCRIPTS
# =====================================================
trade_csv <- trade_raw %>%
  filter(
    # frequency
    freq == "M",
    
    # trade flow: IMPORTS
    stk_flow == "IMP",
    
    # indicator: trade value
    indic_et == "TRD_VAL",
    
    # reporting area: Euro Area
    geo == "EA20",
    
    # partners: China, EU, Vietnam, US
    partner %in% c(
      "CN_X_HK",          # China (+ Hong Kong)
      "US",               # United States
      "VN",               # Vietnam
      "EU27_2020_NEA20"   # European Union (extra-EA)
    ),
    
    # time range
    TIME_PERIOD >= as.Date("2020-01-01"),
    TIME_PERIOD <= as.Date("2026-12-31"),
    
    # SITC sections (all variants present in dataset)
    sitc06 %in% c(
      "SITC5",
      
      "SITC6",
      
      "SITC7",
      "SITC8"
    )
  ) %>%
  select(
    freq,
    stk_flow,
    indic_et,
    partner,
    sitc06,
    geo,
    TIME_PERIOD,
    values
  ) %>%
  arrange(TIME_PERIOD, partner, sitc06)
View(trade_csv)

# =====================================================
# EXPORT CSV
# =====================================================

write_csv(
  trade_csv,
  "10_Data/12_Raw/pulled_EU_CN_VN_US_2020-2025.csv"
)
