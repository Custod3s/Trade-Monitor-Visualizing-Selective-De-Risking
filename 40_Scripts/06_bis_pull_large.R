# =====================================================
# PROJECT: ECB Data Challenge - Flight 1
# MEMBER: Pieter
# =====================================================


library(dplyr)
library(readr)
library(tidyr)
library(zoo)
library(stringr)
library(scales)
library(ggplot2)
library(lubridate)
source("40_Scripts/00_style.R")

# 1. Fetch Data
# ---------------------------------------------------------
bis_url <- "https://stats.bis.org/api/v2/data/dataflow/BIS/WS_LBS_D_PUB/1.0/Q..C.A.TO1....5C+AT+BE+CY+DE+ES+FI+FR+GR+IE+IT+LU+NL+PT.A.CN?startPeriod=2020-01-01&endPeriod=2026-01-13&format=csv"
df_bis_raw <- read_csv(bis_url, show_col_types = FALSE)
View(df_bis_raw)
# Making a vector with the countries of the EU 

eurozone_iso <- c("AT", "BE", "CY", "EE", "FI", "FR", "DE", "GR", 
                  "HR", "IE", "IT", "LV", "LT", "LU", "MT", "NL", 
                  "PT", "SK", "SI", "ES")

clean_df_bis <- df_bis_raw %>%
  filter(L_REP_CTY %in% eurozone_iso) %>%                                        #Filtering the eurozone countries
  filter(L_CP_COUNTRY == "CN") %>%                                               #Filtering China
  filter(L_MEASURE == "S", L_POSITION == "C", L_POS_TYPE == "N") %>%             #Filtering Stocks (S), Claims (C) and Cross-border (N)
  group_by(TIME_PERIOD) %>%    
  summarize(
    Total_Claims_USD_Millions = sum(OBS_VALUE, na.rm = TRUE)) %>%                #Summarize all the EU countries
  mutate(Date = as.Date(as.yearqtr(TIME_PERIOD, format = "%Y-Q%q"))) %>%         #Formatting dates
  complete(Date = seq.Date(min(Date), max(Date) %m+% months(2), by = "month")) %>%
  fill(Total_Claims_USD_Millions, TIME_PERIOD, .direction = "down") %>%
  arrange(Date) %>%
    select(Date, TIME_PERIOD, Total_Claims_USD_Millions)
View(clean_df_bis)

# 4. Export Final Merged File for Member C
# ---------------------------------------------------------
write_csv2(clean_df_bis, "10_Data/11_Processed/cleaned_BIS_monthly_LG.csv")


# ---------------------------------------------------------
# ---------------------------------------------------------
# ---------------------------------------------------------



# Visualization code
ggplot(clean_df_bis, aes(x = Date, y = Total_Claims_USD_Millions)) +
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
ggsave("20_Images/06_banking_claims_CN.png", width = 10, height = 6, dpi = 300)
