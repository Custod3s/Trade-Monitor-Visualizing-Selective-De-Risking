================================================================================
EU-CHINA TRADE MONITOR: VISUALIZING SELECTIVE DE-RISKING
ESC Data Challenge 2026 Submission
================================================================================

PROJECT OVERVIEW
--------------------------------------------------------------------------------
This project investigates whether the EU is successfully implementing 
"selective de-risking" from China following the EU Economic Security Strategy 
(January 2023). Using structural break detection and cross-domain analysis 
(trade + finance), we provide empirical evidence that strategic sectors 
experienced significantly stronger breaks than traditional sectors.

KEY FINDING: High-Tech imports show a structural break 4.5x more intense than 
Traditional imports (F=55.12 vs F=12.37, both p<0.001), confirming targeted 
"selective de-risking" rather than general trade decline.


QUICK START
--------------------------------------------------------------------------------
1. Open R/RStudio
2. Set working directory to the project root folder
3. Run: source("00_BASE/run_all.R")
4. Wait ~5-10 minutes for data download and processing
5. Dashboard will open automatically in your browser

ALTERNATIVE: View the live dashboard at:
https://[your-shinyapps-url].shinyapps.io/


SYSTEM REQUIREMENTS
--------------------------------------------------------------------------------
- R version 4.0 or higher (tested on R 4.3+)
- Internet connection (for data download from Eurostat and BIS APIs)
- Recommended: 8GB RAM, modern web browser
- Operating System: Windows, macOS, or Linux


REPOSITORY STRUCTURE
--------------------------------------------------------------------------------
.
├── 00_BASE/
│   ├── README.txt             # This file
│   ├── run_all.R              # Master script (runs entire analysis)
│   └── foundation.R           # Project setup and configuration
│
├── 10_Data/
│   ├── 11_Processed/          # Cleaned datasets (created by scripts)
│   └── 12_Raw/                # Raw data from APIs (created by scripts)
│
├── 20_Images/                  # Generated visualizations (PNG, 300 dpi)
│
├── 30_Report/                  # Statistical results and documentation
│   ├── strucchange_results.csv           # High-Tech structural break
│   ├── strucchange_control_results.csv   # Traditional structural break
│   └── chow_test_comparison.csv          # Comparative analysis
│
├── 40_Scripts/                 # Analysis pipeline (run in order)
│   ├── 00_style.R             # Custom theme and color palette
│   ├── 01_data_pull.r         # Eurostat trade data (ECB Data Portal)
│   ├── 02_data_pull_BIS.R     # BIS banking statistics
│   ├── 03_bis_pull_all_indicators.R  # BIS comprehensive data
│   ├── 04_sitc_mapping.r      # SITC classification processing
│   ├── 05_first_look.R        # Exploratory visualizations
│   ├── 06_finance_x_imports_CN.R  # Trade-finance integration
│   ├── 07_strucchange.R       # Structural break detection (High-Tech)
│   ├── 08_strucchange_control.R  # Control group analysis (Traditional)
│   └── 09_dashboard.R         # Interactive Shiny dashboard
│
└── app.R                       # Shiny dashboard (for deployment)


DATA SOURCES
--------------------------------------------------------------------------------
1. EUROSTAT External Trade Statistics (ECB Data Portal)
   - Dataset: ext_st_easitc
   - Coverage: EA20 imports from CN, US, VN, EU (2020-2025)
   - Classification: SITC Rev. 4 (Sections 5, 6, 7, 8)
   - Frequency: Monthly
   - URL: https://ec.europa.eu/eurostat/data/database

2. BIS Locational Banking Statistics
   - Dataset: WS_LBS_D_PUB
   - Coverage: Eurozone banking claims on China (2020-2025)
   - Type: Cross-border positions, all sectors
   - Frequency: Quarterly (interpolated to monthly)
   - URL: https://stats.bis.org/

Both datasets are publicly available and accessed via API.


METHODOLOGY
--------------------------------------------------------------------------------
1. Data Collection & Processing:
   - Automated API retrieval from Eurostat and BIS
   - SITC classification into strategic categories:
     * High-Tech & Strategic: SITC 5 (Chemicals) + SITC 7 (Machinery)
     * Traditional & Basic: SITC 6 (Manufactured goods) + SITC 8 (Misc. goods)

2. Statistical Analysis:
   - Chow test for structural breaks (January 2023 break point)
   - F-statistics comparison between treatment and control groups
   - Time series indexing to 2022 baseline

3. Visualization:
   - Rolling averages (3-6 month windows) for trend smoothing
   - Indexed comparison charts (2022 = 100)
   - Cross-domain integration (trade + finance)
   - Interactive Shiny dashboard with filters


KEY RESULTS
--------------------------------------------------------------------------------
STRUCTURAL BREAK ANALYSIS (January 2023):

High-Tech & Strategic Imports:
  - Chow Test F-statistic: 55.12
  - P-value: 2.429e-10 (p < 0.0001)
  - Interpretation: HIGHLY SIGNIFICANT structural break

Traditional & Basic Imports:
  - Chow Test F-statistic: 12.37
  - P-value: 0.0007818 (p < 0.001)
  - Interpretation: Significant structural break

COMPARATIVE FINDING:
  - Intensity Ratio: 4.5x (55.12 / 12.37)
  - Conclusion: Strategic sectors experienced targeted de-risking
                4.5 times more intense than traditional sectors

POLICY IMPLICATION:
  EU Economic Security Strategy successfully achieved differential impact,
  confirming "selective" rather than general de-risking.


OUTPUTS
--------------------------------------------------------------------------------
Generated files (after running run_all.R):

1. Visualizations (20_Images/):
   - 02_eu_trade_china_sector_trends.png
   - 03_eu_trade_china_sector_indexed.png
   - 05_grand_unification_No_zoom.png
   - 06_banking_claims_CN_all_indic.png

2. Statistical Results (30_Report/):
   - strucchange_results.csv (High-Tech analysis)
   - strucchange_control_results.csv (Traditional analysis)
   - strucchange_results.rds (R data format)
   - strucchange_control_results.rds (R data format)

3. Processed Data (10_Data/11_Processed/):
   - 01_data_clean_sitc.csv (trade data by sector)
   - cleaned_BIS_monthly_all_indicators.csv (banking data)


SCRIPT EXECUTION ORDER
--------------------------------------------------------------------------------
The run_all.R script executes in this order:

1. foundation.R              → Setup environment, load packages
2. 01_data_pull.r            → Download Eurostat trade data (~2 min)
3. 02_data_pull_BIS.R        → Download BIS banking data (basic)
4. 03_bis_pull_all_indicators.R → Download BIS comprehensive data (~1 min)
5. 04_sitc_mapping.r         → Process SITC classifications
6. 05_first_look.R           → Generate exploratory plots
7. 06_finance_x_imports_CN.R → Create unified trade-finance chart
8. 07_strucchange.R          → Structural break test (High-Tech)
9. 08_strucchange_control.R  → Structural break test (Traditional)
10. 09_dashboard.R           → Launch interactive dashboard

Total execution time: ~5-10 minutes (depending on internet speed)


TROUBLESHOOTING
--------------------------------------------------------------------------------
Common issues and solutions:

1. "Package not found" error:
   → Run: source("00_BASE/foundation.R")
   → This will auto-install missing packages

2. "Cannot open connection" or API timeout:
   → Check internet connection
   → Eurostat/BIS servers may be temporarily down
   → Wait 5 minutes and retry

3. "Path not found" error:
   → Ensure working directory is project root
   → Run: setwd("[path-to-project]")
   → Then: source("00_BASE/run_all.R")

4. Dashboard won't launch:
   → Check that data files exist in 10_Data/11_Processed/
   → If missing, re-run scripts 01-04
   → Verify packages: shiny, shinydashboard, plotly installed

5. "Permission denied" when writing files:
   → Check folder permissions
   → On Windows: Run RStudio as Administrator
   → On Mac/Linux: Check write permissions on folders


CONTACT & SUPPORT
--------------------------------------------------------------------------------
Repository: https://github.com/Custod3s/Trade-Monitor-Visualizing-Selective-De-Risking
Issues: Open an issue on GitHub
Email: [Contact via GitHub]

For ESC Data Challenge 2026 inquiries:
Email: external_statistics_conference@ecb.europa.eu


CITATION
--------------------------------------------------------------------------------
If you use this code or methodology, please cite:

CUSTOD3S. (2026). "EU-China Trade Monitor: Visualizing Selective 
De-Risking". ESC Data Challenge 2026 Submission.
GitHub: https://github.com/Custod3s/Trade-Monitor-Visualizing-Selective-De-Risking


ACKNOWLEDGMENTS
--------------------------------------------------------------------------------
- European Central Bank (ECB) for hosting the Data Challenge
- Eurostat for external trade statistics
- Bank for International Settlements (BIS) for banking statistics
- National Bank of Poland (NBP) for special prize sponsorship


LICENSE
--------------------------------------------------------------------------------
This project is shared for educational and research purposes.
Data sources (Eurostat, BIS) retain their original licenses.


VERSION HISTORY
--------------------------------------------------------------------------------
v1.0 (2026-01-15) - Initial submission for ESC Data Challenge 2026
                  - Complete analysis pipeline
                  - Interactive dashboard
                  - Statistical validation


================================================================================
END OF README
For questions, see TROUBLESHOOTING section or contact via GitHub
================================================================================