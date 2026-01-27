# ==============================================================================
# SCRIPT: 09_diagnostics_BASE_R.R
# PURPOSE: Verify Assumptions (Normality & Autocorrelation) WITHOUT external packages
# ==============================================================================

library(dplyr)
library(readr)
library(ggplot2)

source("40_Scripts/00_style.R")

# 1. Load & Prepare Data
# ------------------------------------------------------------------------------
data <- read_csv("10_Data/11_Processed/01_data_clean_sitc.csv", 
                 col_types = cols(date = col_date(format = "%Y-%m-%d")))

# Isolate the High-Tech Time Series
# Filter: Start from 2022 to match the Structural Break Analysis (script 08)
ts_df <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "High-Tech & Strategic") %>%
  filter(date >= "2022-01-01") %>% 
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

# 2. Build the Linear Model
# ------------------------------------------------------------------------------
# We check the residuals (errors) of the trend line
ts_df$time_index <- 1:nrow(ts_df)
model_global <- lm(values ~ time_index, data = ts_df)
residuals <- model_global$residuals

# 3. DIAGNOSTIC 1: NORMALITY (Shapiro-Wilk)
# ------------------------------------------------------------------------------
# Shapiro-Wilk is built into Base R. No library needed.
print("--- 1. NORMALITY CHECK (Shapiro-Wilk) ---")
shapiro_res <- shapiro.test(residuals)
print(shapiro_res)

# Visual: QQ Plot
png("20_Images/07_normality_qq.png", width = 800, height = 600)
qqnorm(residuals, main = "Normality Check (QQ Plot)")
qqline(residuals, col = "red", lwd = 2)
dev.off()


# 4. DIAGNOSTIC 2: AUTOCORRELATION (The ACF Plot)
# ------------------------------------------------------------------------------
# Instead of Durbin-Watson (lmtest), we use the Autocorrelation Function (Base R).
# If the bars extend beyond the blue dashed lines, correlation exists.

print("--- 2. AUTOCORRELATION CHECK (Visual ACF) ---")
png("20_Images/07_autocorrelation_acf.png", width = 800, height = 600)
acf(residuals, main = "Autocorrelation of Residuals (ACF)")
dev.off()

# 5. DIAGNOSTIC 3: HETEROSCEDASTICITY (Visual)
# ------------------------------------------------------------------------------
# We plot Residuals vs. Time. If the spread gets wider/narrower like a funnel,
# we have heteroscedasticity. If it looks like a random cloud, we are good.

p_het <- ggplot(data.frame(x = ts_df$date, y = residuals), aes(x=x, y=y)) +
  geom_hline(yintercept = 0, color = "#b91c1c", linetype = "dashed") +
  geom_line(color = "#475569") + 
  geom_point(alpha = 0.6) +
  labs(title = "Variance Check: Residuals over Time", 
       subtitle = "Ideally, this looks like random noise (constant width).",
       x = "Date", y = "Residuals") +
  theme_esc()

ggsave("20_Images/07_heteroscedasticity.png", plot = p_het, width = 8, height = 6)

print(p_het)

# 6. INTERPRETATION GUIDE
# ------------------------------------------------------------------------------
cat("\n--- HOW TO READ THE ACF PLOT ---\n")
cat("1. Look at the vertical bars starting from Lag 1.\n")
cat("2. The Blue Dashed Lines are the 'Significance Threshold'.\n")
cat("3. If the bar at Lag 1 crosses the blue line, the data is 'Sticky' (Autocorrelated).\n")
cat("4. VERDICT: Given the strong structural breaks expected in this analysis, slight autocorrelation is often tolerable.\n")