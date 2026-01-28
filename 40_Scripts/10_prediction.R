# ==============================================================================
# SCRIPT: 11_forecast_linear.R
# PURPOSE: Predictive Modelling using Linear Trend Extrapolation (Base R)
# USP: Projecting the "New Normal" trajectory into 2026
# ==============================================================================

library(dplyr)
library(readr)
library(ggplot2)
library(here)
library(lubridate)

# Ensure this points to your style file correctly
source("40_Scripts/00_style.R")

# 1. Load Data
# ------------------------------------------------------------------------------
data <- read_csv("10_Data/11_Processed/01_data_clean_sitc.csv", 
                 col_types = cols(date = col_date(format = "%Y-%m-%d")))

# Prepare High-Tech Series
# Filter: Start from 2022 to exclude COVID noise (matching Script 08)
df_hist <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "High-Tech & Strategic") %>%
  filter(date >= "2022-01-01") %>% 
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

# 2. Build the Model (The "New Normal" Trend)
# ------------------------------------------------------------------------------
# Load Break Date
break_results <- readRDS(here::here("30_Report/strucchange_results.rds"))
optimal_break_date <- as.Date(break_results$break_date)
print(paste("Modeling based on break date:", optimal_break_date))

# We train the model ONLY on data AFTER the structural break
df_train <- df_hist %>%
  filter(date >= optimal_break_date)

# Linear Model: Value depends on Time
model_lm <- lm(values ~ date, data = df_train)

# 3. Generate Forecast (2026)
# ------------------------------------------------------------------------------
# Create dates for the next 12 months
future_dates <- seq(max(df_hist$date), by = "month", length.out = 13)[-1]
df_future <- data.frame(date = future_dates)

# Predict values with Confidence Intervals (95%)
pred <- predict(model_lm, newdata = df_future, interval = "confidence", level = 0.95)

# Combine into a dataframe
df_forecast_raw <- cbind(df_future, pred) %>%
  rename(values = fit, lower = lwr, upper = upr) %>%
  mutate(type = "Forecast")

# --- THE FIX: CONNECT THE DOTS ---
# Glue the last historical point to the start of the forecast
last_hist_point <- df_hist %>% 
  slice_tail(n = 1) %>% 
  mutate(type = "Forecast", lower = values, upper = values)

df_forecast <- bind_rows(last_hist_point, df_forecast_raw)

# Label history
df_hist <- df_hist %>%
  mutate(lower = NA, upper = NA, type = "History")

# 4. Visualization
# ------------------------------------------------------------------------------
p_forecast <- ggplot() +
  
  # A. Historical Data (Using Dashboard "High-Tech" Color: #005f73)
  geom_line(data = df_hist, aes(x = date, y = values), 
            color = "#005f73", linewidth = 1.2) +
  
  # B. The Forecast (Same Color, Dashed)
  geom_line(data = df_forecast, aes(x = date, y = values), 
            color = "#005f73", linetype = "dashed", linewidth = 1.2) +
  
  # C. Confidence Interval (The Fan)
  geom_ribbon(data = df_forecast, aes(x = date, ymin = lower, ymax = upper), 
              fill = "#005f73", alpha = 0.15) +
  
  # D. Structural Break Line (Matches Dashboard Style EXACTLY)
  geom_vline(xintercept = optimal_break_date, 
             linetype = "dashed",  
             color = "#D9534F",    
             linewidth = 1.2) +   
  
  # Annotations
  annotate("text", x = as.Date("2022-06-01"), y = min(df_hist$values), 
           label = "Historical Trend", hjust = 1, color = "#005f73", size = 4) +
  
  annotate("text", x = optimal_break_date %m+% months(3), y = max(df_hist$values), 
           label = paste("Policy Impact (", format(optimal_break_date, "%b '%y"), ")", sep=""), 
           hjust = 0, color = "#D9534F", fontface = "bold", size = 4) +
  
  # E. Theme & Formatting (FIXED SCALING)
  # Data is in Millions -> Divide by 1000 to get Billions
  scale_y_continuous(labels = function(x) paste0(round(x / 1000, 1), " B")) + 
  
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  
  labs(
    title = "Projecting the 'De-risking' Trend into 2026",
    subtitle = paste0("Linear extrapolation of the post-break trajectory (", format(optimal_break_date, "%b %Y"), " - Present)"),
    x = "Date", y = "Trade Value (USD)",
    caption = "Model: OLS Linear Regression on Post-Break Data (95% CI)"
  ) +
  theme_esc()

print(p_forecast)
ggsave("20_Images/10_forecast_linear.png", plot = p_forecast, width = 10, height = 6)