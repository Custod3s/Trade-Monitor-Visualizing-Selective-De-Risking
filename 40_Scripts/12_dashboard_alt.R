# ==============================================================================
# EU-China Trade Monitor: Interactive Dashboard
# ==============================================================================
# Description: Interactive Shiny dashboard with 3 key visualizations:
#   1) Overview of EU imports from China by sector (2020-2025)
#   2) Eurozone Banking Claims on China
#   3) Unified Trade & Finance De-Risking View
# ==============================================================================

library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(ggplot2)
library(zoo)
library(lubridate)
library(here)

# ==============================================================================
# LOAD CUSTOM THEME & DATA
# ==============================================================================

# Source the custom theme (adjust path as needed)
# Fallback theme if file not found
if (file.exists("40_Scripts/00_style.R")) {
  source("40_Scripts/00_style.R")
} else {
  # Inline theme definition
  esc_colors <- c(
    "High-Tech & Strategic"   = "#005f73",
    "Traditional & Basic" = "#94a3b8",
    "Financial Exposure (BIS)" = "#b91c1c"
  )
  
  theme_esc <- function() {
    theme_minimal(base_size = 12) +
      theme(
        plot.title    = element_text(face = "bold", size = 16, color = "#1e293b", hjust = 0),
        plot.subtitle = element_text(size = 11, color = "#64748b", margin = margin(b = 15), hjust = 0),
        plot.caption  = element_text(size = 8, color = "#94a3b8", hjust = 1, margin = margin(t = 10)),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_line(color = "#e2e8f0", linewidth = 0.5),
        panel.grid.minor.y = element_blank(),
        axis.title    = element_text(size = 10, face = "bold", color = "#475569"),
        axis.text     = element_text(size = 10, color = "#64748b"),
        axis.line.x   = element_line(color = "#cbd5e1"),
        legend.position = "top",
        legend.justification = "left",
        legend.title = element_blank(),
        legend.text = element_text(size = 10, color = "#475569"),
        plot.background  = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA)
      )
  }
}

# Load data files
load_data <- function() {
  tryCatch({
    # Load trade data
    trade_data <- read_csv(here::here("10_Data/11_Processed/01_data_clean_sitc.csv"), 
                           col_types = cols(date = col_date(format = "%Y-%m-%d")),
                           show_col_types = FALSE)
    
    # Load banking data
    finance_data <- read_csv(here::here("10_Data/11_Processed/cleaned_BIS_monthly_all_indicators.csv"), 
                             col_types = cols(date = col_date(format = "%Y-%m-%d")),
                             show_col_types = FALSE)
    
    list(trade = trade_data, finance = finance_data)
  }, error = function(e) {
    warning(paste("Error loading data:", e$message))
    NULL
  })
}

data_list <- load_data()

# ==============================================================================
# UI DEFINITION
# ==============================================================================

ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(
    title = "🇪🇺 EU-China Trade Monitor",
    titleWidth = 320
  ),
  
  dashboardSidebar(
    width = 320,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    ),
    
    hr(),
    
    h4("Filters", style = "padding-left: 15px; color: white;"),
    
    dateRangeInput(
      "date_range",
      "Date Range:",
      start = "2020-01-01",
      end = "2025-12-31",
      min = "2020-01-01",
      max = "2025-12-31"
    ),
    
    checkboxGroupInput(
      "sectors",
      "Trade Sectors:",
      choices = c("High-Tech & Strategic", "Traditional & Basic"),
      selected = c("High-Tech & Strategic", "Traditional & Basic")
    ),
    
    sliderInput(
      "smooth_window",
      "Smoothing Window (months):",
      min = 1,
      max = 12,
      value = 3,
      step = 1
    ),
    
    hr(),
    
    div(
      style = "padding: 15px; color: white; font-size: 11px;",
      p(strong("📅 Key Date:")),
      p("Jan 2023: EU Economic Security Strategy"),
      br(),
      p(strong("📊 Data Sources:")),
      p("• Eurostat (Trade Data)"),
      p("• BIS (Banking Statistics)")
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .box-title { font-weight: bold; font-size: 15px; }
        .info-box { min-height: 90px; }
        .content-wrapper { background-color: #f4f6f9; }
        .small-box h3 { font-size: 28px; font-weight: bold; }
      "))
    ),
    
    tabItems(
      # Dashboard tab
      tabItem(
        tabName = "dashboard",
        
        # Summary boxes
        fluidRow(
          valueBoxOutput("total_imports_box", width = 4),
          valueBoxOutput("strategic_change_box", width = 4),
          valueBoxOutput("banking_change_box", width = 4)
        ),
        
        # Visualization 1: Trade Overview (Two graphs side by side)
        fluidRow(
          box(
            title = "1a. EU Imports from China (Traditional vs Strategic Sectors)",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            plotlyOutput("trade_overview", height = "450px")
          ),
          box(
            title = "1b. EU Imports by Trading Partner (All Sectors)",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            plotlyOutput("trade_by_partner", height = "450px")
          )
        ),
        
        # Visualization 2: Banking Claims
        fluidRow(
          box(
            title = "2. Eurozone Banking Claims on China",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            plotlyOutput("banking_chart", height = "450px")
          )
        ),
        
        # Visualization 3: Unified View
        fluidRow(
          box(
            title = "3. Unified View: Trade & Finance De-Risking (Indexed to 2022 Average)",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            plotlyOutput("unified_chart", height = "450px")
          )
        )
      ),
      
      # About tab
      tabItem(
        tabName = "about",
        fluidRow(
          box(
            title = "About This Dashboard",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            h3("EU-China Trade Monitor: Visualizing Selective De-Risking"),
            p("This dashboard investigates whether the EU is successfully 'de-risking' from China 
              following the Joint Communication on a European Economic Security Strategy (2023)."),
            
            h4("Key Findings:"),
            tags$ul(
              tags$li(strong("Strategic/High-Tech imports (SITC 5+7):"), " ~15% structural decline since Jan 2023"),
              tags$li(strong("Traditional/Basic imports (SITC 6+8):"), " Stabilized near baseline levels"),
              tags$li(strong("Banking exposure:"), " Synchronized contraction indicating systemic de-risking")
            ),
            
            h4("Methodology:"),
            tags$ul(
              tags$li("Data Source: Eurostat (ECB Data Portal) & BIS (2020-2025)"),
              tags$li("Statistical Validation: Chow Test for Structural Breaks"),
              tags$li("Break Point: January 2023 (EU Economic Security Strategy)"),
              tags$li(strong("High-Tech F-Statistic: 55.12 (p < 0.0001)")),
              tags$li(strong("Traditional F-Statistic: 12.37 (p < 0.001)")),
              tags$li(strong("Intensity Ratio: 4.5x (High-Tech vs Traditional)"))
            ),
            
            h4("Interpretation:"),
            p("Both sectors show significant structural breaks in January 2023, confirming 
              the policy timing. However, the High-Tech break is  strong 4.5x more intense), 
              than Traditional trade F = 55.12 vs F = 12.37, providing empirical evidence 
              that EU 'de-risking' specifically targeted strategic sectors while maintaining 
              traditional trade relationships. This validates the 'selective' nature of 
              de-risking beyond normal market fluctuations."),
            
            hr(),
            
            h4("Repository:"),
            p(a("GitHub: Trade-Monitor-Visualizing-Selective-De-Risking", 
                href = "https://github.com/Custod3s/Trade-Monitor-Visualizing-Selective-De-Risking",
                target = "_blank")),
            
            h4("Contact:"),
            p("For questions or feedback, please open an issue on GitHub.")
          )
        )
      )
    )
  )
)

# ==============================================================================
# SERVER LOGIC
# ==============================================================================

server <- function(input, output, session) {
  
  # Reactive data filtering
  filtered_trade_data <- reactive({
    req(data_list$trade)
    
    data_list$trade %>%
      filter(
        partner == "CN_X_HK",
        sector_group %in% input$sectors,
        date >= input$date_range[1],
        date <= input$date_range[2]
      )
  })
  
  # Reactive data for all partners (combined sectors)
  filtered_trade_all_partners <- reactive({
    req(data_list$trade)
    
    data_list$trade %>%
      filter(
        partner %in% c("CN_X_HK", "US", "VN", "EU27_2020_NEA20"),
        date >= input$date_range[1],
        date <= input$date_range[2]
      ) %>%
      group_by(date, partner) %>%
      summarise(total_value = sum(values, na.rm = TRUE), .groups = 'drop')
  })
  
  filtered_finance_data <- reactive({
    req(data_list$finance)
    
    data_list$finance %>%
      filter(
        date >= input$date_range[1],
        date <= input$date_range[2]
      )
  })
  
  # ==============================================================================
  # VALUE BOXES
  # ==============================================================================
  
  output$total_imports_box <- renderValueBox({
    req(filtered_trade_data())
    
    total <- filtered_trade_data() %>%
      summarise(total = sum(values, na.rm = TRUE)) %>%
      pull(total)
    
    valueBox(
      value = paste0("$", round(total / 1e6, 1), "B"),
      subtitle = "Total Imports (Period)",
      icon = icon("boxes"),
      color = "blue"
    )
  })
  
  output$strategic_change_box <- renderValueBox({
    req(filtered_trade_data())
    
    # Calculate change from 2022 baseline
    change_data <- filtered_trade_data() %>%
      filter(sector_group == "High-Tech & Strategic") %>%
      mutate(year = year(date)) %>%
      group_by(year) %>%
      summarise(avg_val = mean(values, na.rm = TRUE))
    
    if (nrow(change_data) >= 2 && 2022 %in% change_data$year) {
      baseline <- change_data %>% filter(year == 2022) %>% pull(avg_val)
      latest <- change_data %>% filter(year == max(year)) %>% pull(avg_val)
      pct_change <- ((latest - baseline) / baseline) * 100
      
      valueBox(
        value = paste0(round(pct_change, 1), "%"),
        subtitle = "Strategic Sector Change (vs 2022)",
        icon = icon("microchip"),
        color = if(pct_change < 0) "red" else "green"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Strategic Sector Change",
        icon = icon("microchip"),
        color = "light-blue"
      )
    }
  })
  
  output$banking_change_box <- renderValueBox({
    req(filtered_finance_data())
    
    # Calculate YoY change
    finance_change <- filtered_finance_data() %>%
      arrange(date) %>%
      filter(!is.na(values))
    
    if (nrow(finance_change) >= 2) {
      first_val <- head(finance_change$values, 1)
      last_val <- tail(finance_change$values, 1)
      pct_change <- ((last_val - first_val) / first_val) * 100
      
      valueBox(
        value = paste0(round(pct_change, 1), "%"),
        subtitle = "Banking Exposure Change",
        icon = icon("building-columns"),
        color = if(pct_change < 0) "red" else "green"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = "Banking Exposure Change",
        icon = icon("building-columns"),
        color = "light-blue"
      )
    }
  })
  
  # ==============================================================================
  # PLOT 1a: TRADE OVERVIEW (CHINA BY SECTOR)
  # ==============================================================================
  
  output$trade_overview <- renderPlotly({
    req(filtered_trade_data())
    
    # 1. Prepare Data: Aggregate & Smooth
    data_smooth <- filtered_trade_data() %>%
      group_by(date, sector_group) %>%
      summarise(values = sum(values, na.rm = TRUE), .groups = 'drop') %>%
      arrange(date) %>%
      group_by(sector_group) %>%
      mutate(
        rolling_avg = rollmean(values, k = input$smooth_window, fill = NA, align = "right")
      ) %>%
      filter(!is.na(rolling_avg))
    
    # 2. Reshape for Ribbon (Wide Format)
    trade_wide <- data_smooth %>%
      select(date, sector_group, rolling_avg) %>%
      tidyr::pivot_wider(names_from = sector_group, values_from = rolling_avg) %>%
      # SAFETY: Rename columns to match code (Adjust if your data differs)
      rename(HighTech = `High-Tech & Strategic`, Traditional = `Traditional & Basic`)
    
    # 3. Build the "Gap" Chart
    p <- ggplot(trade_wide, aes(x = date)) +
      
      # A. The Reference Line
      geom_line(aes(y = Traditional, color = "Traditional & Basic"), linewidth = 1, alpha = 0.6) +
      
      # B. The Strategic Line
      geom_line(aes(y = HighTech, color = "High-Tech & Strategic"), linewidth = 1.2) +
      
      # C. The "De-risking Gap" (Red Ribbon)
      geom_ribbon(aes(ymin = HighTech, ymax = Traditional), 
                  fill = "#e81e25", alpha = 0.15) +
      
      # D. Policy Marker
      geom_vline(xintercept = as.Date("2023-01-01"), linetype = "dashed", color = "#D9534F") +
      annotate("text", x = as.Date("2023-06-01"), y = min(trade_wide$Traditional, na.rm=T) * 1.05, 
               label = "Policy Shift", hjust = -0.1, color = "#D9534F", linewidth = 1.2) +
      
      # E. Styling
      scale_color_manual(values = esc_colors) +
      scale_y_continuous(labels = function(x) paste(x / 1000, "B")) +
      labs(title = NULL, x = NULL, y = "Trade Value (USD)", color = "Sector Groups") +
      theme_esc()
    
    ggplotly(p, tooltip = c("x", "y", "colour")) %>%
      layout(legend = list(orientation = "h", x = 0.1, y = -0.2))
  })
  
  # ==============================================================================
  # PLOT 1b: TRADE BY PARTNER (ALL SECTORS COMBINED)
  # ==============================================================================
  
  output$trade_by_partner <- renderPlotly({
    req(data_list$trade)
    
    # Filter for all partners and combine sectors
    plot_data <- data_list$trade %>%
      filter(
        partner %in% c("CN_X_HK", "US", "VN", "EU27_2020_NEA20"),
        date >= input$date_range[1],
        date <= input$date_range[2]
      ) %>%
      # Sum all sectors per partner per date
      group_by(date, partner) %>%
      summarise(total_value = sum(values, na.rm = TRUE), .groups = 'drop') %>%
      # Apply rolling average
      group_by(partner) %>%
      arrange(date) %>%
      mutate(
        rolling_avg = rollmean(total_value, k = input$smooth_window, fill = NA, align = "center")
      ) %>%
      ungroup() %>%
      filter(!is.na(rolling_avg)) %>%
      # Create readable labels
      mutate(
        partner_label = case_when(
          partner == "CN_X_HK" ~ "China",
          partner == "US" ~ "United States",
          partner == "VN" ~ "Vietnam",
          partner == "EU27_2020_NEA20" ~ "EU (Extra-EA)",
          TRUE ~ partner
        )
      )
    
    # Define colors for partners
    partner_colors <- c(
      "China" = "#b91c1c",            # Red (matches your theme)
      "United States" = "#0077b6",    # Blue
      "Vietnam" = "#2d6a4f",          # Green
      "EU (Extra-EA)" = "#94a3b8"     # Grey (matches Traditional color)
    )
    
    p <- ggplot(plot_data, aes(x = date, y = rolling_avg, color = partner_label)) +
      geom_line(linewidth = 1.2) +
      geom_vline(
        xintercept = as.Date("2023-01-01"), 
        linetype = "dashed", 
        color = "#D9534F", 
        linewidth = 1
      ) +
      scale_color_manual(values = partner_colors) +
      scale_y_continuous(labels = function(x) paste(x / 1000, "B")) +
      labs(
        x = "Date",
        y = "Total Trade Value (USD)",
        color = "Trading Partner"
      ) +
      theme_esc()
    
    ggplotly(p, tooltip = c("x", "y", "colour")) %>%
      layout(legend = list(orientation = "h", y = -0.15))
  })
  
  # ==============================================================================
  # PLOT 2: BANKING CLAIMS
  # ==============================================================================
  
  output$banking_chart <- renderPlotly({
    req(filtered_finance_data())
    
    p <- ggplot(filtered_finance_data(), aes(x = date, y = values)) +
      geom_line(color = esc_colors["Financial Exposure (BIS)"], linewidth = 1.2) +
      geom_point(color = esc_colors["Financial Exposure (BIS)"], size = 1.5, alpha = 0.6) +
      geom_vline(xintercept = as.Date("2023-01-01"), 
                 linetype = "dashed", 
                 color = "#D9534F", 
                 linewidth = 1) +
      scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
      labs(
        title = "Eurozone Banking Claims on China",
        subtitle = "Total cross-border claims (USD Millions)",
        x = "Date",
        y = "Total Claims (USD Millions)",
        caption = "Source: BIS Locational Banking Statistics"
      ) +
      theme_esc()
    
    ggplotly(p, tooltip = c("x", "y"))
  })
  
  # ==============================================================================
  # PLOT 3: UNIFIED VIEW (INDEXED)
  # ==============================================================================
  
  output$unified_chart <- renderPlotly({
    req(filtered_trade_data(), filtered_finance_data())
    
    # Process trade data
    trade_indexed <- filtered_trade_data() %>%
      group_by(date, sector_group) %>%
      summarise(values = sum(values, na.rm = TRUE), .groups = "drop") %>%
      group_by(sector_group) %>%
      arrange(date) %>%
      mutate(smooth_value = rollmean(values, k = 3, fill = NA, align = "center")) %>%
      mutate(
        base_val = mean(smooth_value[format(date, "%Y") == "2022"], na.rm = TRUE),
        index_val = (smooth_value / base_val) * 100
      ) %>%
      select(date, sector_group, index_val)
    
    # Process finance data
    finance_indexed <- filtered_finance_data() %>%
      mutate(
        base_val = mean(values[format(date, "%Y") == "2022"], na.rm = TRUE),
        index_val = (values / base_val) * 100
      ) %>%
      select(date, sector_group, index_val)
    
    # Combine
    plot_data <- bind_rows(trade_indexed, finance_indexed)
    
    p <- ggplot(plot_data, aes(x = date, y = index_val, color = sector_group, linetype = sector_group)) +
      geom_hline(yintercept = 100, color = "black", linetype = "dotted") +
      geom_vline(xintercept = as.Date("2023-01-01"), color = "#D9534F", linetype = "dashed") +
      geom_line(linewidth = 1.2) +
      scale_color_manual(values = esc_colors) +
      scale_linetype_manual(values = c(
        "High-Tech & Strategic" = "solid",
        "Traditional & Basic" = "solid",
        "Financial Exposure (BIS)" = "longdash"
      )) +
      labs(
        title = "The Dual De-Risking: Trade & Finance Divergence",
        subtitle = "Since Jan 2023, EU Banks and High-Tech Importers have reduced exposure",
        y = "Index (2022 Avg = 100)",
        x = "Date",
        caption = "Sources: Eurostat (Trade), BIS (Finance)",
        color = "Sector Group",
        linetype = "Sector Group"
      ) +
      theme_esc() +
      theme(legend.position = "bottom")
    
    ggplotly(p, tooltip = c("x", "y", "colour")) %>%
      layout(legend = list(orientation = "h", y = -0.2))
  })
}

# ==============================================================================
# RUN APPLICATION
# ==============================================================================

shinyApp(ui = ui, server = server)