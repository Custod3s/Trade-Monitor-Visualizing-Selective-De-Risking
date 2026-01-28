# ==============================================================================
# SCRIPT: 09_diagnostics_BASE_R.R
# PURPOSE: Verify Assumptions (Normality & Autocorrelation) on SEGMENTED Models
# ==============================================================================

library(dplyr)
library(readr)
library(ggplot2)
library(gridExtra) # For side-by-side plots if needed, or we use base R layout

source("40_Scripts/00_style.R")

# 1. Load & Prepare Data
# ------------------------------------------------------------------------------
data <- read_csv("10_Data/11_Processed/01_data_clean_sitc.csv", 
                 col_types = cols(date = col_date(format = "%Y-%m-%d")))

# Isolate the High-Tech Time Series
# Filter: Start from 2022 to match the Structural Break Analysis
ts_df <- data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group == "High-Tech & Strategic") %>%
  filter(date >= "2022-01-01") %>% 
  group_by(date) %>%
  summarise(values = sum(values, na.rm = TRUE)) %>%
  arrange(date)

# Add Time Index
ts_df$time_index <- 1:nrow(ts_df)

# 2. Build the SEGMENTED Linear Models
# ------------------------------------------------------------------------------
# We define the break date identified in the structural break analysis (May 2023)
break_date <- as.Date("2023-05-01")

print(paste("--- RUNNING DIAGNOSTICS ON SEGMENTED MODEL (Break:", break_date, ") ---"))

# Split Data
df_pre <- ts_df %>% filter(date < break_date)
df_post <- ts_df %>% filter(date >= break_date)

# Fit Separate Models
model_pre <- lm(values ~ time_index, data = df_pre)
model_post <- lm(values ~ time_index, data = df_post)

# Extract and Combine Residuals
# We want to check if the *errors around the trend* are normal, 
# accounting for the fact that the trend itself shifted.
resid_pre <- residuals(model_pre)
resid_post <- residuals(model_post)
residuals_segmented <- c(resid_pre, resid_post)

# 3. DIAGNOSTIC 1: NORMALITY (Shapiro-Wilk)
# ------------------------------------------------------------------------------
print("--- 1. NORMALITY CHECK (Segmented Residuals) ---")
shapiro_res <- shapiro.test(residuals_segmented)
print(shapiro_res)

# Visual: QQ Plot (Segmented)
png("20_Images/07_normality_qq.png", width = 800, height = 400)
par(mfrow=c(1,2)) # Side by side
qqnorm(resid_pre, main = "QQ Plot: Pre-Break")
qqline(resid_pre, col = "red", lwd = 2)
qqnorm(resid_post, main = "QQ Plot: Post-Break")
qqline(resid_post, col = "red", lwd = 2)
dev.off()
par(mfrow=c(1,1)) # Reset

# 4. DIAGNOSTIC 2: AUTOCORRELATION (The ACF Plot)
# ------------------------------------------------------------------------------
print("--- 2. AUTOCORRELATION CHECK (Visual ACF) ---")
# We check ACF separately to see if memory persists in either regime
png("20_Images/07_autocorrelation_acf.png", width = 800, height = 400)
par(mfrow=c(1,2))
acf(resid_pre, main = "ACF: Pre-Break Residuals")
acf(resid_post, main = "ACF: Post-Break Residuals")
dev.off()
par(mfrow=c(1,1)) # Reset

# 5. DIAGNOSTIC 3: HETEROSCEDASTICITY (Visual)
# ------------------------------------------------------------------------------
# We plot Residuals vs. Time, marking the break point.
# We create a data frame specifically for plotting
plot_data <- ts_df %>%
  mutate(
    regime = ifelse(date < break_date, "Pre-Break", "Post-Break"),
    resid = residuals_segmented # These are aligned because we didn't reorder rows
  )

p_het <- ggplot(plot_data, aes(x = date, y = resid, color = regime)) +
  geom_hline(yintercept = 0, color = "#64748b", linetype = "solid") +
  geom_vline(xintercept = break_date, color = "#b91c1c", linetype = "dashed") +
  geom_point(alpha = 0.8, size = 2) +
  geom_segment(aes(xend = date, yend = 0), alpha = 0.2) + # Lollipop style
  scale_color_manual(values = c("Pre-Break" = "#94a3b8", "Post-Break" = "#005f73")) +
  labs(title = "Variance Check: Segmented Residuals over Time", 
       subtitle = "Residuals from separate Pre/Post trend lines. Look for constant spread.",
       x = "Date", y = "Residuals (Detrended)") +
  theme_esc() +
  theme(legend.position = "top")

ggsave("20_Images/07_heteroscedasticity.png", plot = p_het, width = 8, height = 6)

print(p_het)

# 6. INTERPRETATION GUIDE
# ------------------------------------------------------------------------------
cat("\n--- DIAGNOSTIC SUMMARY ---\n")
cat("1. Normality: Checked on residuals after accounting for the structural shift.\n")
cat("2. Autocorrelation: Checked separately for Pre/Post periods to ensure short-term memory doesn't bias the break test.\n")
cat("3. Heteroscedasticity: Visually inspect if the 'spread' of dots changes significantly after May 2023.\n")