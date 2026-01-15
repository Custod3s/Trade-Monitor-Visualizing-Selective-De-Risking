library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)
library(here)
source("40_Scripts/00_style.R")

trade_data <- read_csv(here::here("10_Data/11_Processed/01_data_clean_sitc.csv"), 
                       col_types = cols(date = col_date(format = "%Y-%m-%d")))
View(trade_data)


plot_data <- trade_data %>%
  filter(partner == "CN_X_HK") %>%
  group_by(date, sector_group) %>%
  summarise(total_trade_value = sum(values, na.rm = TRUE), .groups = 'drop') %>%
  group_by(sector_group) %>%
  mutate(
    rolling_avg = rollmean(total_trade_value, k = 6, fill = NA, align = "center")
  )

View(plot_data)

ggplot(plot_data, aes(x = date, y = rolling_avg, color = sector_group)) +
  geom_line(linewidth = 1.2) + theme_esc() +
  labs(title = "3-Month Rolling Average of EU Trade with China by Sector Group",
       x = "Time",
       y = "Trade Value (USD)",
       color = "Sector Group") +
  scale_color_manual(values =  c("High-Tech & Strategic"   = "#005f73",
                                  "Traditional & Basic" = "#94a3b8")) +
  theme_esc() + 
  geom_vline(xintercept = as.Date("2023-01-01"), 
                                                   linetype = "dashed", 
                                                   color = "#D9534F", # "Risk Red" color
                                                   linewidth = 1) +
  
  annotate("text", 
           x = as.Date("2022-12-01"), # Place text slightly to the right of the line
           y = 28000,                 # Place it high up (adjust based on your Y-axis)
           label = "Start of Divergence", 
           hjust = 1,                 # Left-align text
           color = "#D9534F", 
           fontface = "bold",
           size = 4) +
  scale_y_continuous(
    labels = function(x) paste(x / 1000, "Billion") 
  )

ggsave("20_Images/02_eu_trade_china_sector_trends.png", width = 10, height = 6)


# Calculate Index (Jan 2023 = 100)
View(plot_data)

plot_data_indexed <- trade_data %>%
  filter(grepl("CN_X_HK", partner)) %>%
  filter(sector_group %in% c("High-Tech & Strategic", "Traditional & Basic")) %>%
  
  # Aggregate up to monthly totals (summing sub-sectors)
  group_by(date, sector_group) %>%
  summarise(values = sum(values, na.rm = TRUE), .groups = "drop") %>%
  
  # Apply 3-Month Rolling Average (Smoother lines)
  group_by(sector_group) %>%
  mutate(smooth_value = rollmean(values, k = 3, fill = NA, align = "center")) %>%  
  
  # Index to Jan 2023 = 100
  group_by(sector_group) %>%
  mutate(
    # Calculate the average value for the entire year of 2022
    base_val = mean(smooth_value[format(date, "%Y") == "2022"], na.rm = TRUE),
    index_val = (smooth_value / base_val) * 100
  ) %>%
  select(date, sector_group, index_val)


# Plot the Index
ggplot(plot_data_indexed, aes(x = date, y = index_val, color = sector_group)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 100, linetype = "dotted") + # The "No Change" line
  geom_vline(xintercept = as.Date("2023-01-01"), linetype = "dashed", color = "#D9534F") +
  theme_esc() +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.title = element_text(face = "bold", size = 14)
  ) +
  labs(
    title = "Relative Trade Performance (Index: 2022 Average = 100)",
    subtitle = "Since the EU Economic Security Strategy, High-Tech has underperformed Traditional trade.",
    y = "Import Volume (Index 100 = 2022 Avg)",
    x = "Date",
    color = "Sector Groups"
  ) +
  scale_color_manual(values = c("High-Tech & Strategic"   = "#005f73",
                                "Traditional & Basic" = "#94a3b8"))
  

ggsave("20_Images/03_eu_trade_china_sector_indexed.png", width = 10, height = 6)
