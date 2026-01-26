# ==============================================================================
# EU-China Trade Monitor: Interactive Dashboard
# ==============================================================================
# Description: Interactive Shiny dashboard with 3 key visualizations:
#   1) Overview of EU imports from China by sector (2020-2025)
#   2) Eurozone Banking Claims on China
#   3) Unified Trade & Finance De-Risking View
# ==============================================================================

# Load required packages
library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(readr)
library(ggplot2)
library(zoo)
library(lubridate)

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
    trade_data <- read_csv("10_Data/11_Processed/01_data_clean_sitc.csv", 
                           col_types = cols(date = col_date(format = "%Y-%m-%d")),
                           show_col_types = FALSE)
    
    # Load banking data
    finance_data <- read_csv("10_Data/11_Processed/cleaned_BIS_monthly_all_indicators.csv", 
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
    
    checkboxInput(
      "show_gap",
      "Show De-Risking Gap (requires both sectors)",
      value = TRUE
    ),
    
    sliderInput(
      "smooth_window",
      "Smoothing Window (months):",
      min = 1,
      max = 12,
      value = 3,
      step = 1
    ),
    
    sliderInput(
      "baseline_year",
      "Baseline Year (for % Change):",
      min = 2020,
      max = 2024,
      value = 2022,
      step = 1,
      sep = ""
    ),
    
    hr(),
    
    div(
      style = "padding: 15px; color: white; font-size: 11px;",
      p(strong("📅 Key Date:")),
      p("Oct 2023: EU Economic Security Strategy (Lagged Effect)"),
      br(),
      p(strong("📊 Data Sources:")),
      p(HTML("<a href='https://ec.europa.eu/eurostat/databrowser/view/ext_st_easitc/default/table?lang=en' target='_blank' style='color: #90CAF9;'>• Eurostat (Trade Data)</a>")),
      p(HTML("<a href='https://stats.bis.org/api/v2/data/dataflow/BIS/WS_LBS_D_PUB/1.0/Q..C.A.USD....5A.A.CN?startPeriod=2020-01-01&endPeriod=2025-12-31&format=csv' target='_blank' style='color: #90CAF9;'>• BIS (Banking Statistics)</a>"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .box-title { font-weight: bold; font-size: 15px; }
        .info-box { min-height: 90px; }
        .small-box h3 { font-size: 28px; font-weight: bold; }
        
        /* 1. Fixed Header */
        .main-header { position: fixed; width: 100%; top: 0; left: 0; z-index: 1030; }
        
        /* 2. Fixed Sidebar */
        .main-sidebar { position: fixed; top: 50px; left: 0; height: calc(100vh - 50px); overflow-y: auto; z-index: 1029; }
        
        /* 3. Push content down */
        .content-wrapper { margin-top: 50px; }
        
        /* 4. Handle Content Margin for Fixed Sidebar (Desktop only) */
        @media (min-width: 768px) {
          body:not(.sidebar-collapse) .content-wrapper,
          body:not(.sidebar-collapse) .main-footer {
            margin-left: 320px !important;
          }
          body.sidebar-collapse .content-wrapper,
          body.sidebar-collapse .main-footer {
            margin-left: 0px !important;
          }
        }
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
            title = tagList(
              "1a. EU Imports from China by Sector (2020-2025)",
              actionButton("info_1a", "", icon = icon("info-circle"), 
                           class = "btn-xs", 
                           style = "float: right; margin-top: -5px;")
            ),
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            plotlyOutput("trade_overview", height = "450px")
          ),
          box(
            title = tagList(
              "1b. EU Imports by Trading Partner (All Sectors)",
              actionButton("info_1b", "", icon = icon("info-circle"), 
                           class = "btn-xs", 
                           style = "float: right; margin-top: -5px;")
            ),
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            plotlyOutput("trade_by_partner", height = "450px")
          )
        ),
        
        # Visualization 2: Banking & Prediction Split
        fluidRow(
          box(
            title = tagList(
              "2a. Eurozone Banking Claims on China",
              actionButton("info_2", "", icon = icon("info-circle"), 
                           class = "btn-xs", 
                           style = "float: right; margin-top: -5px;")
            ),
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            plotlyOutput("banking_chart", height = "450px")
          ),
          box(
            title = tagList(
              "2b. Strategic Trade Forecast (2026)",
              actionButton("info_2b", "", icon = icon("info-circle"), 
                           class = "btn-xs", 
                           style = "float: right; margin-top: -5px;")
            ),
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            collapsible = TRUE,
            plotlyOutput("forecast_plot", height = "450px")
          )
        ),
        
        # Visualization 3: Unified View
        fluidRow(
          box(
            title = tagList(
              "3. Unified View: Trade & Finance De-Risking (Indexed to 2022 Average)",
              actionButton("info_3", "", icon = icon("info-circle"), 
                           class = "btn-xs", 
                           style = "float: right; margin-top: -5px;")
            ),
            status = "primary",
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
              tags$li(strong("Strategic/High-Tech imports (SITC 5+7):"), " ~15% structural decline since Oct 2023"),
              tags$li(strong("Traditional/Basic imports (SITC 6+8):"), " Stabilized near baseline levels"),
              tags$li(strong("Banking exposure:"), " Synchronized contraction indicating systemic de-risking")
            ),
            
            h4("SITC Classification Explained:"),
            p("This analysis categorizes trade goods using the Standard International Trade Classification (SITC) system:"),
            tags$ul(
              tags$li(strong("SITC 5 - Chemicals & Related Products:"), " Organic/inorganic chemicals, pharmaceuticals, plastics, fertilizers"),
              tags$li(strong("SITC 6 - Manufactured Goods:"), " Leather, textiles, non-metallic minerals, metals, metal products"),
              tags$li(strong("SITC 7 - Machinery & Transport Equipment:"), " Power machinery, industrial machinery, computers, telecommunications, electrical equipment, vehicles"),
              tags$li(strong("SITC 8 - Miscellaneous Manufactured Articles:"), " Furniture, clothing, footwear, instruments, optical/photographic equipment")
            ),
            p(strong("Strategic Sectors (SITC 5+7):"), " High-tech products with dual-use potential and critical supply chain dependencies"),
            p(strong("Traditional Sectors (SITC 6+8):"), " Basic manufactured goods with lower strategic sensitivity"),
            
            h4("Methodology:"),
            tags$ul(
              tags$li(HTML("Data Source: <a href='https://ec.europa.eu/eurostat/databrowser/view/ext_st_easitc/default/table?lang=en' target='_blank'>Eurostat</a> (Trade) & <a href='https://stats.bis.org/api/v2/data/dataflow/BIS/WS_LBS_D_PUB/1.0/Q..C.A.USD....5A.A.CN?startPeriod=2020-01-01&endPeriod=2025-12-31&format=csv' target='_blank'>BIS</a> (Banking) (2020-2025)")),
              tags$li("Statistical Validation: Chow Test for Structural Breaks"),
              tags$li("Break Point: October 2023 (Implementation of Economic Security Strategy)"),
              tags$li("F-Statistic (High-Tech): 55.12 (p < 0.0001)")
            ),
            
            h4("Interpretation:"),
            p("While strategic trade collapsed (F=30.45), traditional trade showed no statistically significant structural change (F=0.38). 
              This confirms that 'De-risking' was surgical, affecting only the targeted sectors while leaving general trade completely untouched."),
            
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
  
  # ==============================================================================
  # INFO MODAL DIALOGS
  # ==============================================================================
  
  observeEvent(input$info_1a, {
    showModal(modalDialog(
      title = "Graph 1a: EU Imports from China by Sector",
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      
      h4("What does this graph show?"),
      p("This visualization displays EU imports from China, separated into two key sectors:"),
      tags$ul(
        tags$li(strong("High-Tech & Strategic (Blue):"), " SITC 5+7 - Chemicals, machinery, electronics, and technology products"),
        tags$li(strong("Traditional & Basic (Grey):"), " SITC 6+8 - Manufacturing goods, textiles, and consumer products")
      ),
      
      h4("Key Features:"),
      tags$ul(
        tags$li(strong("Red Dashed Line (Oct 2023):"), " Marks the implementation of the EU Economic Security Strategy"),
        tags$li(strong("De-Risking Gap:"), " The red shaded area between lines shows the divergence between sectors (toggle on/off in sidebar)")
      ),
      
      h4("Interactive Controls:"),
      tags$ul(
        tags$li(strong("Smoothing Window Slider:"), " Adjust the rolling average window (1-12 months) to smooth or show more detail"),
        tags$li(strong("Trade Sectors Checkboxes:"), " Toggle sectors on/off to focus on specific trends"),
        tags$li(strong("Show De-Risking Gap:"), " Enable/disable the red shaded area (requires both sectors selected)"),
        tags$li(strong("Hover:"), " Move your mouse over the lines to see exact values and dates")
      ),
      
      h4("Interpretation:"),
      p("While strategic trade collapsed (F=30.45), traditional trade showed no statistically significant structural change (F=0.38). 
        This confirms that 'De-risking' was surgical, affecting only the targeted sectors while leaving general trade completely untouched.")
    ))
  })
  
  observeEvent(input$info_1b, {
    showModal(modalDialog(
      title = "Graph 1b: EU Imports by Trading Partner",
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      
      h4("What does this graph show?"),
      p("This visualization compares total EU imports (all sectors combined) from four major trading partners:"),
      tags$ul(
        tags$li(strong("China (Dark Blue):"), " China including Hong Kong"),
        tags$li(strong("United States (Medium Blue):"), " USA trade flows"),
        tags$li(strong("Vietnam (Light Blue):"), " Emerging alternative to China"),
        tags$li(strong("EU (Extra-EA) (Lightest Blue):"), " Intra-European trade outside the Eurozone")
      ),
      
      h4("Key Features:"),
      tags$ul(
        tags$li(strong("Red Dashed Line (Oct 2023):"), " Marks the policy shift date"),
        tags$li(strong("All Sectors:"), " Unlike Graph 1a, this combines all SITC categories for each partner")
      ),
      
      h4("Interactive Controls:"),
      tags$ul(
        tags$li(strong("Smoothing Window:"), " Same slider affects both Graph 1a and 1b"),
        tags$li(strong("Date Range:"), " Filter to specific time periods in the sidebar"),
        tags$li(strong("Hover:"), " See exact trade values and dates for each partner")
      ),
      
      h4("Interpretation:"),
      p("Compare China's overall trade performance with alternative partners. Look for substitution 
        effects - if China declines, do imports from Vietnam or other partners increase?")
    ))
  })
  
  observeEvent(input$info_2, {
    showModal(modalDialog(
      title = "Graph 2: Eurozone Banking Claims on China",
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      
      h4("What does this graph show?"),
      p("This visualization displays the total cross-border banking claims (financial exposure) 
        of Eurozone banks to China, measured in USD millions."),
      tags$ul(
        tags$li(strong("Data Source:"), " BIS Locational Banking Statistics"),
        tags$li(strong("Frequency:"), " Quarterly data, interpolated to monthly for consistency"),
        tags$li(strong("Scope:"), " Includes all Eurozone countries' banking sector exposure")
      ),
      
      h4("Key Features:"),
      tags$ul(
        tags$li(strong("Red Line:"), " Shows total banking claims over time"),
        tags$li(strong("Points:"), " Each dot represents a data point"),
        tags$li(strong("Red Dashed Line (Oct 2023):"), " Policy implementation date")
      ),
      
      h4("Interactive Controls:"),
      tags$ul(
        tags$li(strong("Date Range Filter:"), " Focus on specific periods"),
        tags$li(strong("Banking Exposure Value Box (Top Right):"), " Shows % change for selected period"),
        tags$li(strong("Hover:"), " See exact claim amounts and dates")
      ),
      
      h4("Interpretation:"),
      p("Declining banking claims indicate financial de-risking - Eurozone banks are reducing 
        their capital exposure to China. The synchronized decline with strategic trade suggests 
        a coordinated 'dual de-risking' across both real economy (goods) and financial sectors.")
    ))
  })
  
  observeEvent(input$info_3, {
    showModal(modalDialog(
      title = "Graph 3: Unified View - Trade & Finance De-Risking",
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      
      h4("What does this graph show?"),
      p("This is the 'master visualization' combining trade and financial data into a single 
        indexed comparison. All three data series are indexed to their 2022 average = 100."),
      tags$ul(
        tags$li(strong("High-Tech & Strategic (Solid Blue):"), " Strategic imports index"),
        tags$li(strong("Traditional & Basic (Solid Grey):"), " Traditional imports index"),
        tags$li(strong("Financial Exposure (Dashed Red):"), " Banking claims index")
      ),
      
      h4("Key Features:"),
      tags$ul(
        tags$li(strong("Index = 100:"), " Represents the 2022 average baseline (dotted horizontal line)"),
        tags$li(strong("Above 100:"), " Growth relative to 2022"),
        tags$li(strong("Below 100:"), " Decline relative to 2022"),
        tags$li(strong("Dashed vs Solid:"), " Different line styles distinguish banking (dashed) from trade (solid)")
      ),
      
      h4("Interactive Controls:"),
      tags$ul(
        tags$li(strong("Trade Sectors Filter:"), " Show/hide specific sectors"),
        tags$li(strong("Date Range:"), " Zoom into specific periods"),
        tags$li(strong("Hover:"), " See exact index values")
      ),
      
      h4("Interpretation:"),
      p(strong("The 'Dual De-Risking' Pattern:")),
      p("Both High-Tech imports (blue) and Banking exposure (red dashed) decline in parallel 
        after October 2023, while Traditional trade (grey) remains stable. This synchronized 
        divergence provides empirical evidence that EU de-risking is:"),
      tags$ul(
        tags$li(strong("Selective:"), " Targets strategic sectors, not all trade"),
        tags$li(strong("Systemic:"), " Spans both goods (trade) and capital (finance)"),
        tags$li(strong("Policy-Driven:"), " Timing aligns with Economic Security Strategy")
      ),
      p("The statistical validation (Chow Test) confirms this is a structural break, 
        not random market volatility.")
    ))
  })
  
  observeEvent(input$info_2b, {
    showModal(modalDialog(
      title = "Graph 2b: Strategic Trade Forecast (2026)",
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      
      h4("What does this graph show?"),
      p("This visualization projects the future trajectory of EU High-Tech imports from China into 2026, assuming the current 'de-risking' trend continues."),
      
      h4("Methodology:"),
      tags$ul(
        tags$li(strong("Model:"), " Linear Regression (OLS) trained on post-break data"),
        tags$li(strong("Training Period:"), " Oct 2023 - Present (The 'De-risking' Era)"),
        tags$li(strong("Forecast Horizon:"), " Next 12 months")
      ),
      
      h4("Key Features:"),
      tags$ul(
        tags$li(strong("Solid Blue Line:"), " Historical observed data"),
        tags$li(strong("Dashed Blue Line:"), " Projected future values"),
        tags$li(strong("Shaded Area:"), " 95% Confidence Interval (Range of probable outcomes)"),
        tags$li(strong("Red Dashed Line:"), " The Oct 2023 structural break point")
      ),
      
      h4("Interpretation:"),
      p("This forecast illustrates the 'New Normal'. Unlike the stable pre-2023 trend, the post-2023 trajectory shows a structural decline. If policy and market conditions remain unchanged, this model predicts where the relationship is heading.")
    ))
  })
  
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
    
    # Get date range from input
    start_date <- input$date_range[1]
    end_date <- input$date_range[2]
    
    total <- filtered_trade_data() %>%
      summarise(total = sum(values, na.rm = TRUE)) %>%
      pull(total)
    
    # Format the period nicely
    period_label <- paste0(format(start_date, "%b %Y"), " - ", format(end_date, "%b %Y"))
    
    valueBox(
      value = paste0("$", round(total / 1e6, 1), "B"),
      subtitle = paste0("Total Imports (", period_label, ")"),
      icon = icon("boxes"),
      color = "blue"
    )
  })
  
  output$strategic_change_box <- renderValueBox({
    req(filtered_trade_data())
    
    # Calculate change from selected baseline year
    change_data <- filtered_trade_data() %>%
      filter(sector_group == "High-Tech & Strategic") %>%
      mutate(year = year(date)) %>%
      group_by(year) %>%
      summarise(avg_val = mean(values, na.rm = TRUE), .groups = 'drop')
    
    baseline_year <- input$baseline_year
    
    if (nrow(change_data) >= 2 && baseline_year %in% change_data$year) {
      baseline <- change_data %>% filter(year == baseline_year) %>% pull(avg_val)
      latest <- change_data %>% filter(year == max(year)) %>% pull(avg_val)
      pct_change <- ((latest - baseline) / baseline) * 100
      
      valueBox(
        value = paste0(round(pct_change, 1), "%"),
        subtitle = paste0("Strategic Sector Change (vs ", baseline_year, ")"),
        icon = icon("microchip"),
        color = if(pct_change < 0) "red" else "green"
      )
    } else {
      valueBox(
        value = "N/A",
        subtitle = paste0("Strategic Sector Change (vs ", baseline_year, ")"),
        icon = icon("microchip"),
        color = "light-blue"
      )
    }
  })
  
  output$banking_change_box <- renderValueBox({
    req(filtered_finance_data())
    
    # Get date range from input
    start_date <- input$date_range[1]
    end_date <- input$date_range[2]
    
    # Calculate change between start and end of selected period
    finance_change <- filtered_finance_data() %>%
      arrange(date) %>%
      filter(!is.na(values))
    
    if (nrow(finance_change) >= 2) {
      first_val <- head(finance_change$values, 1)
      last_val <- tail(finance_change$values, 1)
      first_date <- head(finance_change$date, 1)
      last_date <- tail(finance_change$date, 1)
      
      pct_change <- ((last_val - first_val) / first_val) * 100
      
      # Create dynamic subtitle
      period_label <- paste0(format(first_date, "%b %Y"), " → ", format(last_date, "%b %Y"))
      
      valueBox(
        value = paste0(round(pct_change, 1), "%"),
        subtitle = paste0("Banking Exposure (", period_label, ")"),
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
        rolling_avg = rollmean(values, k = input$smooth_window, fill = NA, align = "center")
      ) %>%
      filter(!is.na(rolling_avg))
    
    # 2. Check which sectors are selected
    has_hightech <- "High-Tech & Strategic" %in% input$sectors
    has_traditional <- "Traditional & Basic" %in% input$sectors
    both_selected <- has_hightech && has_traditional
    
    # 3. Build the plot
    p <- ggplot(data_smooth, aes(x = date, y = rolling_avg, color = sector_group)) +
      geom_line(linewidth = 1.2)
    
    # 4. Add ribbon ONLY if both sectors are selected AND checkbox is checked
    if (both_selected && input$show_gap) {
      # Reshape for Ribbon (Wide Format)
      trade_wide <- data_smooth %>%
        select(date, sector_group, rolling_avg) %>%
        tidyr::pivot_wider(names_from = sector_group, values_from = rolling_avg)
      
      # Check if both columns exist after pivot
      if ("High-Tech & Strategic" %in% names(trade_wide) && 
          "Traditional & Basic" %in% names(trade_wide)) {
        
        trade_wide <- trade_wide %>%
          rename(
            HighTech = `High-Tech & Strategic`, 
            Traditional = `Traditional & Basic`
          )
        
        # Add the ribbon as a separate layer BEFORE the lines
        p <- ggplot(data_smooth, aes(x = date, y = rolling_avg, color = sector_group)) +
          geom_ribbon(
            data = trade_wide,
            aes(x = date, ymin = HighTech, ymax = Traditional),
            inherit.aes = FALSE,
            fill = "#e81e25", 
            alpha = 0.15
          ) +
          geom_line(linewidth = 1.2)
      }
    }
    
    # 5. Add remaining elements
    p <- p +
      geom_vline(xintercept = as.Date("2023-10-01"), 
                 linetype = "dashed", 
                 color = "#D9534F", 
                 linewidth = 1) +
      annotate("text", 
               x = as.Date("2024-04-01"), 
               y = min(data_smooth$rolling_avg, na.rm = TRUE) * 1.05,
               label = "Start of Divergence", 
               hjust = 0,
               color = "#D9534F", 
               fontface = "bold",
               size = 3.5) +
      scale_color_manual(values = esc_colors) +
      scale_y_continuous(labels = function(x) paste(x / 1000, "B")) +
      labs(
        title = paste0(input$smooth_window, "-Month Rolling Avg: China by Sector"),
        x = "Date",
        y = "Trade Value (USD)",
        color = "Sector Group"
      ) +
      theme_esc()
    
    ggplotly(p, tooltip = c("x", "y", "colour")) %>%
      layout(
        legend = list(orientation = "h", y = -0.3),
        margin = list(b = 80)
      )
  })
  
  # ==============================================================================
  # PLOT 1b: TRADE BY PARTNER (ALL SECTORS COMBINED)
  # ==============================================================================
  
  output$trade_by_partner <- renderPlotly({
    req(filtered_trade_all_partners())
    
    # Apply rolling average
    plot_data <- filtered_trade_all_partners() %>%
      group_by(partner) %>%
      arrange(date) %>%
      mutate(
        rolling_avg = rollmean(total_value, k = input$smooth_window, fill = NA, align = "center")
      ) %>%
      ungroup() %>%
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
      "China" = "#005f73",
      "United States" = "#0077b6",
      "Vietnam" = "#00b4d8",
      "EU (Extra-EA)" = "#90e0ef"
    )
    
    p <- ggplot(plot_data, aes(x = date, y = rolling_avg, color = partner_label)) +
      geom_line(linewidth = 1.2) +
      geom_vline(xintercept = as.Date("2023-10-01"), 
                 linetype = "dashed", 
                 color = "#D9534F", 
                 linewidth = 1) +
      scale_color_manual(values = partner_colors) +
      scale_y_continuous(labels = function(x) paste(x / 1000, "B")) +
      labs(
        title = paste0(input$smooth_window, "-Month Rolling Avg: All Partners"),
        x = "Date",
        y = "Trade Value (USD)",
        color = "Trading Partner"
      ) +
      theme_esc()
    
    ggplotly(p, tooltip = c("x", "y", "colour")) %>%
      layout(legend = list(orientation = "h", y = -0.2))
  })
  
  # ==============================================================================
  # PLOT 2: BANKING CLAIMS
  # ==============================================================================
  
  output$banking_chart <- renderPlotly({
    req(filtered_finance_data())
    
    p <- ggplot(filtered_finance_data(), aes(x = date, y = values)) +
      geom_line(color = esc_colors["Financial Exposure (BIS)"], linewidth = 1.2) +
      geom_point(color = esc_colors["Financial Exposure (BIS)"], size = 1.5, alpha = 0.6) +
      geom_vline(xintercept = as.Date("2023-10-01"), 
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
  # PLOT 2b: FORECAST
  # ==============================================================================
  
  output$forecast_plot <- renderPlotly({
    req(data_list$trade)
    
    # 1. Prepare Data
    df_hist <- data_list$trade %>%
      filter(partner == "CN_X_HK", sector_group == "High-Tech & Strategic") %>%
      group_by(date) %>%
      summarise(values = sum(values, na.rm = TRUE), .groups = 'drop') %>%
      arrange(date)
    
    # 2. Build Model (Post-Break)
    df_train <- df_hist %>% filter(date >= as.Date("2023-10-01"))
    
    # Check if we have enough data to model
    validate(need(nrow(df_train) > 3, "Not enough post-2023 data for forecasting."))
    
    model_lm <- lm(values ~ date, data = df_train)
    
    # 3. Forecast
    future_dates <- seq(max(df_hist$date), by = "month", length.out = 13)[-1]
    df_future <- data.frame(date = future_dates)
    
    pred <- predict(model_lm, newdata = df_future, interval = "confidence", level = 0.95)
    
    df_forecast_raw <- cbind(df_future, pred) %>%
      rename(values = fit, lower = lwr, upper = upr) %>%
      mutate(type = "Forecast")
    
    # Connect the dots
    last_hist_point <- df_hist %>% 
      slice_tail(n = 1) %>% 
      mutate(type = "Forecast", lower = values, upper = values)
    
    df_forecast <- bind_rows(last_hist_point, df_forecast_raw)
    
    df_hist <- df_hist %>% mutate(lower = NA, upper = NA, type = "History")
    
    # 4. Plot
    p <- ggplot() +
      geom_line(data = df_hist, aes(x = date, y = values), 
                color = "#005f73", linewidth = 1.2) +
      geom_line(data = df_forecast, aes(x = date, y = values), 
                color = "#005f73", linetype = "dashed", linewidth = 1.2) +
      geom_ribbon(data = df_forecast, aes(x = date, ymin = lower, ymax = upper), 
                  fill = "#005f73", alpha = 0.15) +
      geom_vline(xintercept = as.Date("2023-10-01"), 
                 linetype = "dashed",  
                 color = "#D9534F",    
                 linewidth = 1) +   
      scale_y_continuous(labels = function(x) paste(round(x / 1000, 1), "B")) +
      labs(
        title = "Projecting the 'De-risking' Trend",
        subtitle = "Linear extrapolation (Oct 2023 - Present)",
        x = "Date", y = "Trade Value (USD)"
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
      geom_vline(xintercept = as.Date("2023-10-01"), color = "#D9534F", linetype = "dashed") +
      geom_line(linewidth = 1.2) +
      scale_color_manual(values = esc_colors) +
      scale_linetype_manual(values = c(
        "High-Tech & Strategic" = "solid",
        "Traditional & Basic" = "solid",
        "Financial Exposure (BIS)" = "longdash"
      )) +
      labs(
        title = "The Dual De-Risking: Trade & Finance Divergence",
        subtitle = "Since Oct 2023, EU Banks and High-Tech Importers have reduced exposure",
        y = "Index (2022 Avg = 100)",
        x = "Date",
        caption = "Sources: Eurostat (Trade), BIS (Finance)",
        color = "Sector Group"
      ) +
      guides(linetype = "none") +
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