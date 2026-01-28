================================================================================
EU-CHINA TRADE MONITOR: VISUALIZING SELECTIVE DE-RISKING
ESC Data Challenge 2026 Submission
================================================================================

PROJECT OVERVIEW
--------------------------------------------------------------------------------
This project investigates whether the EU is successfully implementing 
"selective de-risking" from China following the global adoption of the 
de-risking concept (May 2023). Using structural break detection and 
cross-domain analysis (trade + finance), we provide empirical evidence 
that strategic high-tech sectors experienced significantly stronger breaks 
than traditional sectors, coinciding with the G7 Hiroshima Summit.

KEY FINDING: High-Tech imports show a structural break ~4x more intense than 
Traditional imports (F=21.80 vs F=5.52, both p<0.05), confirming targeted 
"selective de-risking" concentrated in strategic sectors.


QUICK START
--------------------------------------------------------------------------------
1. Open R/RStudio
2. Set working directory to the project root folder
3. Run: source("run_all.R")
4. Wait ~2-5 minutes for processing (Extraction is skipped by default)
5. Dashboard will open manually via: runApp('40_Scripts/14_dashboard_v3.R')

ALTERNATIVE: View the live dashboard at:
https://custod3s.shinyapps.io/data_challenge/


SYSTEM REQUIREMENTS
--------------------------------------------------------------------------------
- R version 4.0 or higher (tested on R 4.3+)
- Internet connection (for initial data download)
- Recommended: 8GB RAM, modern web browser
- Operating System: macOS, Windows, or Linux


REPOSITORY STRUCTURE
--------------------------------------------------------------------------------
.
├── run_all.R                   # Master pipeline script
├── README.md                   # Detailed project documentation (Markdown)
├── Data Challenge.Rproj        # RStudio Project file
│
├── 00_BASE/
│   └── README.txt              # This file (Submission Summary)
│
├── 10_Data/
│   ├── 11_Processed/           # Cleaned datasets
│   └── 12_Raw/                 # Raw data from APIs
│
├── 20_Images/                   # Generated visualizations (PNG)
│
├── 30_Report/                   # Statistical results
│   ├── strucchange_results.rds           # High-Tech result object
│   ├── strucchange_control_results.rds   # Traditional result object
│   └── strucchange_results.csv           # Tabular results
│
├── 40_Scripts/                  # Analysis pipeline
│   ├── 00_style.R              # Custom theme and color palette
│   ├── 01_data_pull.R          # Eurostat trade data extraction
│   ├── 02_data_pull_BIS.R      # BIS banking statistics extraction
│   ├── 03_bis_pull_all_indicators.R # BIS comprehensive indicators
│   ├── 04_sitc_mapping.R       # SITC classification processing
│   ├── 05_first_look.R         # Exploratory visualizations
│   ├── 06_finance_x_imports_CN.R # Trade-finance integration
│   ├── 07_precon_check.R       # Assumption verification (Normality/ACF)
│   ├── 08_strucchange.R        # Main structural break analysis (May '23)
│   ├── 09_strucchange_control.R # Control group analysis
│   ├── 10_prediction.R         # Forecasting models into 2026
│   ├── 14_dashboard_v3.R       # Interactive Shiny dashboard
│   └── 15_update_documentation.R # Automatic README.md updater
│
└── rsconnect/                  # Shiny deployment configuration


DATA SOURCES
--------------------------------------------------------------------------------
1. EUROSTAT External Trade Statistics (ECB Data Portal)
   - Coverage: EU imports from CN, US, VN, Extra-EU (2020-2025)
   - Classification: SITC Rev. 4 (Sections 5, 6, 7, 8)
   - Frequency: Monthly

2. BIS Locational Banking Statistics
   - Coverage: Eurozone banking claims on China (2020-2025)
   - Type: Cross-border positions, all sectors
   - Frequency: Quarterly (interpolated to monthly)


METHODOLOGY
--------------------------------------------------------------------------------
1. Clean Data Window: Analysis restricted to Jan 2022 onwards to exclude 
   extreme COVID-19 recovery noise and supply chain bullwhip effects.

2. Restricted Search: Structural break detection (Chow Test) restricted to 
   May 2023 onwards to capture the "Strategy Era" and anticipatory effects.

3. Signaling Effect: Identification of the May 2023 break point as a 
   reaction to the G7 Hiroshima Summit consensus on "De-risking".

4. Intensity Ratio: Calculating the relative strength of decoupling in 
   strategic sectors (SITC 5+7) vs. traditional sectors (SITC 6+8).

5. Assumption Verification: Diagnostic checks (Normality, Autocorrelation) 
   performed on the residuals of a **Segmented Model** (Pre- vs. Post-Break). 
   This ensures that the structural shift is correctly accounted for, preventing 
   false positives in statistical tests.


KEY RESULTS
--------------------------------------------------------------------------------
STRUCTURAL BREAK ANALYSIS (May 2023):

High-Tech & Strategic Imports:
  - Chow Test F-statistic: 21.80
  - P-value: < 0.0001
  - Interpretation: MASSIVE structural break following G7 signal

Traditional & Basic Imports:
  - Chow Test F-statistic: 5.52
  - P-value: 0.0232
  - Interpretation: Significant but weaker break (General volatility)

COMPARATIVE FINDING:
  - Intensity Ratio: ~4x
  - Conclusion: The structural decoupling in strategic sectors is 4 times 
                more intense than general trade volatility, confirming 
                successful "sector-concentrated" de-risking.


OUTPUTS
--------------------------------------------------------------------------------
Generated files (after running run_all.R):

1. Visualizations (20_Images/):
   - 02_eu_trade_china_sector_trends.png: Visualizes raw monthly trends and 
     6-month rolling averages for strategic vs. traditional trade flows.
   - 03_eu_trade_china_sector_indexed.png: Normalizes trade data to a 2022 
     baseline (=100) to highlight the divergence in sector performance.
   - 05_grand_unification.png: Merges trade and financial data to demonstrate 
     the "Substitution Effect" (Trade decline vs. Capital rise).
   - 06_banking_claims_CN.png: Tracks Eurozone banking exposure to China, 
     revealing the "Localization Paradox".
   - 07_normality_qq.png: Segmented QQ-Plot verifying the normality of 
     residuals (Pre- vs Post-Break) for the statistical validity of the Chow Test.
   - 07_autocorrelation_acf.png: Segmented ACF plot checking for serial 
     correlation in time-series residuals across both periods.
   - 07_heteroscedasticity.png: Segmented variance check ensuring constant 
     error spread before and after the structural break.
   - 07_forecast_linear.png: 2026 Projection based on the structural trend 
     established after the de-risking signal.

2. Statistical Results (30_Report/):
   - strucchange_results.rds (High-Tech analysis)
   - strucchange_control_results.rds (Traditional analysis)


SCRIPT EXECUTION ORDER
--------------------------------------------------------------------------------
The run_all.R script executes the full pipeline:
00 -> 04 -> 05 -> 06 -> 07 -> 08 -> 09 -> 10 -> 15


CONTACT & SUPPORT
--------------------------------------------------------------------------------
Repository: https://github.com/Custod3s/Trade-Monitor-Visualizing-Selective-De-Risking


CITATION
--------------------------------------------------------------------------------
CUSTOD3S. (2026). "EU-China Trade Monitor: Visualizing Selective 
De-Risking". ESC Data Challenge 2026 Submission.


================================================================================
END OF README
================================================================================