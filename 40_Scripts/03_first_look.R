library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)

setwd("/Users/alex/Programming/ECB_Data_Challenge")

trade_data <- read_csv("data/01_data_clean_sitc.csv", 
                       col_types = cols(date = col_date(format = "%Y-%m-%d")))
View(trade_data)


plot_data <- trade_data %>%
  filter(partner == "CN_X_HK") %>%
  group_by(date, sector_group) %>%
  summarise(total_trade_value = sum(values, na.rm = TRUE), .groups = 'drop') %>%
  group_by(sector_group) %>%
  mutate(
    rolling_avg = rollmean(total_trade_value, k = 6, fill = NA, align = "right")
  )


View(plot_data)


ggplot(plot_data, aes(x = date, y = rolling_avg, color = sector_group)) +
  geom_line(size = 1.2) + theme_minimal() +
  labs(title = "3-Month Rolling Average of EU Trade with China by Sector Group",
       x = "Time",
       y = "Trade Value (USD)",
       color = "Sector Group") +
  scale_color_manual(values = c("High-Tech & Strategic" = "blue", 
                                     "Traditional & Basic" = "green", 
                                     "Other" = "gray")) +
  theme(text = element_text(size = 14)) + 
  geom_vline(xintercept = as.Date("2023-01-01"), 
                                                   linetype = "dashed", 
                                                   color = "#D9534F", # "Risk Red" color
                                                   linewidth = 1) +
  
  annotate("text", 
           x = as.Date("2023-01-01"), # Place text slightly to the right of the line
           y = 28000,                 # Place it high up (adjust based on your Y-axis)
           label = "Start of Divergence\n(EU Economic Security Strategy)", 
           hjust = 0,                 # Left-align text
           color = "#D9534F", 
           fontface = "bold",
           size = 4)

ggsave("20_Images/02_eu_trade_china_sector_trends.png", width = 10, height = 6)


# Calculate Index (Jan 2023 = 100)
View(plot_data)

plot_data_indexed <- plot_data %>%
  group_by(sector_group) %>%
  mutate(
    # Find the value in Jan 2023 (or closest date) to use as baseline
    base_value = total_trade_value[which.min(abs(date - as.Date("2023-01-01")))],
    index_value = (rolling_avg / base_value) * 100
  ) %>%
  filter(date >= "2022-01-01") # Zoom in on the relevant period

# Plot the Index
ggplot(plot_data_indexed, aes(x = date, y = index_value, color = sector_group)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 100, linetype = "dotted") + # The "No Change" line
  geom_vline(xintercept = as.Date("2023-03-01"), linetype = "dashed", color = "#D9534F") +
  theme_minimal() +
  labs(
    title = "Relative Trade Performance (Index: Jan 2023 = 100)",
    subtitle = "Since the EU Economic Security Strategy, High-Tech has underperformed Traditional trade.",
    y = "Import Volume (Index 100 = Jan 2023)",
    x = "Date",
    color = "Sector Groups"
  ) +
  scale_color_manual(values = c("High-Tech & Strategic" = "#004494", 
                                "Traditional & Basic" = "#555555"))
ggsave("20_Images/03_eu_trade_china_sector_indexed.png", width = 10, height = 6)
