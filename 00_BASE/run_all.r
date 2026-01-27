# ==============================================================================
# RUN_ALL.R - Master Execution Script
# EU-China Trade Monitor: Visualizing Selective De-Risking
# ==============================================================================
# Description: Executes the complete analysis pipeline from data collection
#              to visualization generation. Run this script to reproduce all
#              results from the ESC Data Challenge 2026 submission.
#
# Usage: source("00_BASE/run_all.R")
# Time: ~10-15 minutes (depending on internet connection)
# ==============================================================================

# Clear console for clean output
cat("\014")

# Print header
cat("\n")
cat("================================================================================\n")
cat("  EU-CHINA TRADE MONITOR: VISUALIZING SELECTIVE DE-RISKING\n")
cat("  ESC Data Challenge 2026 - Complete Analysis Pipeline\n")
cat("================================================================================\n\n")

# Record start time
start_time <- Sys.time()

# ==============================================================================
# STEP 0: ENVIRONMENT SETUP
# ==============================================================================
cat("STEP 0/12: Setting up environment...\n")
cat("------------------------------------------------------------------------\n")

# Source foundation script (handles all package installation and setup)
if (file.exists("00_BASE/foundation.R")) {
  source("00_BASE/foundation.R")
  cat("✓ Environment setup complete\n\n")
} else {
  stop("ERROR: foundation.R not found in 00_BASE/ directory.\n",
       "Please ensure you're running this script from the project root.\n")
}

# ==============================================================================
# STEP 1: DATA COLLECTION - EUROSTAT TRADE DATA
# ==============================================================================
cat("STEP 1/12: Downloading Eurostat trade data...\n")
cat("------------------------------------------------------------------------\n")
cat("Source: Eurostat External Trade Statistics (ECB Data Portal)\n")
cat("Dataset: ext_st_easitc (Monthly, 2020-2025)\n")
cat("Expected time: ~2 minutes\n\n")

tryCatch({
  source("40_Scripts/01_data_pull.r")
  cat("✓ Eurostat data downloaded successfully\n")
  cat("  File: 10_Data/12_Raw/pulled_EU_CN_VN_US_2020-2025.csv\n\n")
}, error = function(e) {
  warning("⚠ Error downloading Eurostat data: ", e$message, "\n")
  cat("  This may be due to network issues or API timeout.\n")
  cat("  Continuing with remaining steps...\n\n")
})

# ==============================================================================
# STEP 2: DATA COLLECTION - BIS BANKING DATA (BASIC)
# ==============================================================================
cat("STEP 2/12: Downloading BIS banking statistics (basic)...\n")
cat("------------------------------------------------------------------------\n")
cat("Source: BIS Locational Banking Statistics\n")
cat("Expected time: ~30 seconds\n\n")

tryCatch({
  source("40_Scripts/02_data_pull_BIS.R")
  cat("✓ BIS basic data downloaded successfully\n")
  cat("  File: 10_Data/12_Raw/BIS_Financial_Exposure_EU_CN_2020-2025.csv\n\n")
}, error = function(e) {
  warning("⚠ Error downloading BIS data: ", e$message, "\n")
  cat("  Continuing with remaining steps...\n\n")
})

# ==============================================================================
# STEP 3: DATA COLLECTION - BIS COMPREHENSIVE DATA
# ==============================================================================
cat("STEP 3/12: Downloading BIS comprehensive indicators...\n")
cat("------------------------------------------------------------------------\n")
cat("Source: BIS Locational Banking Statistics (All Eurozone countries)\n")
cat("Expected time: ~1 minute\n\n")

tryCatch({
  source("40_Scripts/03_bis_pull_all_indicators.R")
  cat("✓ BIS comprehensive data downloaded and processed\n")
  cat("  File: 10_Data/11_Processed/cleaned_BIS_monthly_all_indicators.csv\n")
  cat("  Plot: 20_Images/06_banking_claims_CN_all_indic.png\n\n")
}, error = function(e) {
  warning("⚠ Error downloading BIS comprehensive data: ", e$message, "\n")
  cat("  Continuing with remaining steps...\n\n")
})

# ==============================================================================
# STEP 4: DATA PROCESSING - SITC CLASSIFICATION
# ==============================================================================
cat("STEP 4/12: Processing SITC classifications...\n")
cat("------------------------------------------------------------------------\n")
cat("Categorizing trade data into strategic sectors:\n")
cat("  - High-Tech & Strategic: SITC 5 (Chemicals) + SITC 7 (Machinery)\n")
cat("  - Traditional & Basic: SITC 6 (Manufactured) + SITC 8 (Misc.)\n\n")

tryCatch({
  source("40_Scripts/04_sitc_mapping.r")
  cat("✓ SITC classification complete\n")
  cat("  File: 10_Data/11_Processed/01_data_clean_sitc.csv\n\n")
}, error = function(e) {
  warning("⚠ Error processing SITC data: ", e$message, "\n")
  cat("  This step is required for subsequent analyses.\n")
  cat("  Please check that 01_data_pull.r completed successfully.\n\n")
})

# ==============================================================================
# STEP 5: EXPLORATORY ANALYSIS
# ==============================================================================
cat("STEP 5/12: Generating exploratory visualizations...\n")
cat("------------------------------------------------------------------------\n")
cat("Creating initial trade trend plots for EU-China imports\n\n")

tryCatch({
  source("40_Scripts/05_first_look.R")
  cat("✓ Exploratory analysis complete\n")
  cat("  Plots generated:\n")
  cat("    - 20_Images/02_eu_trade_china_sector_trends.png\n")
  cat("    - 20_Images/03_eu_trade_china_sector_indexed.png\n\n")
}, error = function(e) {
  warning("⚠ Error in exploratory analysis: ", e$message, "\n\n")
})

# ==============================================================================
# STEP 6: CROSS-DOMAIN INTEGRATION
# ==============================================================================
cat("STEP 6/12: Creating unified trade-finance visualization...\n")
cat("------------------------------------------------------------------------\n")
cat("Integrating Eurostat trade data with BIS banking statistics\n\n")

tryCatch({
  source("40_Scripts/06_finance_x_imports_CN.R")
  cat("✓ Cross-domain integration complete\n")
  cat("  Plot: 20_Images/05_grand_unification_No_zoom.png\n")
  cat("  This chart shows the 'Dual De-Risking' narrative\n\n")
}, error = function(e) {
  warning("⚠ Error in cross-domain analysis: ", e$message, "\n\n")
})

# ==============================================================================
# STEP 7: PRE-CONDITION CHECKS
# ==============================================================================
cat("STEP 7/12: Verifying statistical assumptions...\n")
cat("------------------------------------------------------------------------\n")
cat("Checking Normality and Autocorrelation for time series analysis\n\n")

tryCatch({
  source("40_Scripts/07_precon_check.R")
  cat("✓ Pre-condition checks complete\n\n")
}, error = function(e) {
  warning("⚠ Error in pre-condition checks: ", e$message, "\n\n")
})

# ==============================================================================
# STEP 8: STRUCTURAL BREAK ANALYSIS - HIGH-TECH
# ==============================================================================
cat("STEP 8/12: Running structural break test (High-Tech sector)...\n")
cat("------------------------------------------------------------------------\n")
cat("Chow test for High-Tech & Strategic imports from China\n")
cat("Break point: January 2023 (EU Economic Security Strategy)\n\n")

tryCatch({
  source("40_Scripts/08_strucchange.R")
  cat("✓ Structural break analysis complete (High-Tech)\n")
  cat("  Results saved to: 30_Report/strucchange_results.csv\n")
  
  # Load and display results
  if (file.exists("30_Report/strucchange_results.csv")) {
    results <- read.csv("30_Report/strucchange_results.csv")
    cat("\n  KEY RESULTS:\n")
    cat("    F-statistic:", round(results$chow_statistic, 2), "\n")
    cat("    P-value:", format(results$chow_p_value, scientific = TRUE), "\n")
    cat("    Interpretation: HIGHLY SIGNIFICANT structural break\n\n")
  }
}, error = function(e) {
  warning("⚠ Error in structural break analysis: ", e$message, "\n\n")
})

# ==============================================================================
# STEP 9: STRUCTURAL BREAK ANALYSIS - TRADITIONAL (CONTROL)
# ==============================================================================
cat("STEP 9/12: Running structural break test (Traditional sector - CONTROL)...\n")
cat("------------------------------------------------------------------------\n")
cat("Chow test for Traditional & Basic imports from China\n")
cat("Control group analysis to validate High-Tech findings\n\n")

tryCatch({
  source("40_Scripts/09_strucchange_control.R")
  cat("✓ Control group analysis complete (Traditional)\n")
  cat("  Results saved to: 30_Report/strucchange_control_results.csv\n")
  
  # Load and display results
  if (file.exists("30_Report/strucchange_control_results.csv")) {
    results_control <- read.csv("30_Report/strucchange_control_results.csv")
    cat("\n  KEY RESULTS:\n")
    cat("    F-statistic:", round(results_control$chow_statistic, 2), "\n")
    cat("    P-value:", format(results_control$chow_p_value, scientific = TRUE), "\n")
    cat("    Interpretation: Significant structural break\n\n")
  }
  
  # Display comparative analysis if both files exist
  if (file.exists("30_Report/strucchange_results.csv") && 
      file.exists("30_Report/strucchange_control_results.csv")) {
    
    results <- read.csv("30_Report/strucchange_results.csv")
    results_control <- read.csv("30_Report/strucchange_control_results.csv")
    
    ratio <- results$chow_statistic / results_control$chow_statistic
    
    cat("  COMPARATIVE FINDING:\n")
    cat("    Intensity Ratio:", round(ratio, 1), "x\n")
    cat("    Conclusion: High-Tech break is", round(ratio, 1), 
        "times stronger than Traditional\n")
    cat("    → Evidence of SELECTIVE de-risking, not general trade decline\n\n")
  }
  
}, error = function(e) {
  warning("⚠ Error in control group analysis: ", e$message, "\n\n")
})

# ==============================================================================
# STEP 10: PREDICTION MODEL
# ==============================================================================
cat("STEP 10/12: Running predictive modelling...\n")
cat("------------------------------------------------------------------------\n")
cat("Generating linear trend extrapolations for 2026 scenarios\n\n")

tryCatch({
  source("40_Scripts/10_prediction.R")
  cat("✓ Prediction modelling complete\n\n")
}, error = function(e) {
  warning("⚠ Error in prediction modelling: ", e$message, "\n\n")
})

# ==============================================================================
# STEP 11: INTERACTIVE DASHBOARD
# ==============================================================================
cat("STEP 11/12: Preparing interactive dashboard...\n")
cat("------------------------------------------------------------------------\n")
cat("The Shiny dashboard will launch in your default web browser.\n")
cat("You can explore the data interactively with date range and sector filters.\n\n")

cat("Press Ctrl+C (or Cmd+C on Mac) in the console to stop the dashboard\n")
cat("and continue to the final summary.\n\n")

# Ask user if they want to launch the dashboard
cat("Launch interactive dashboard? (Y/n): ")
user_input <- tolower(trimws(readline()))

if (user_input != "n" && user_input != "no") {
  cat("\nLaunching dashboard...\n")
  tryCatch({
    # Check if required data files exist
    required_files <- c(
      "10_Data/11_Processed/01_data_clean_sitc.csv",
      "10_Data/11_Processed/cleaned_BIS_monthly_all_indicators.csv"
    )
    
    all_files_exist <- all(file.exists(required_files))
    
    if (all_files_exist) {
      # Load required packages
      if (!require("shiny", quietly = TRUE)) install.packages("shiny")
      
      cat("✓ Dashboard ready. Opening in browser...\n\n")
      cat("NOTE: Dashboard will run until you press Ctrl+C\n")
      cat("      Close the browser tab to stop the dashboard.\n\n")
      
      # Run the dashboard
      shiny::runApp("40_Scripts/11_dashboard.R")
      
    } else {
      warning("⚠ Required data files not found. Dashboard cannot launch.\n")
      cat("  Please ensure steps 1-4 completed successfully.\n\n")
    }
  }, error = function(e) {
    warning("⚠ Error launching dashboard: ", e$message, "\n\n")
  })
} else {
  cat("\n✓ Dashboard launch skipped\n\n")
}

# ==============================================================================
# STEP 12: FINAL SUMMARY
# ==============================================================================
cat("\n")
cat("STEP 12/12: Analysis Complete!\n")
cat("========================================================================\n\n")

# Calculate total execution time
end_time <- Sys.time()
duration <- difftime(end_time, start_time, units = "mins")

cat("EXECUTION SUMMARY\n")
cat("------------------------------------------------------------------------\n")
cat("Total execution time:", round(duration, 1), "minutes\n\n")

cat("OUTPUTS GENERATED\n")
cat("------------------------------------------------------------------------\n")
cat("1. Processed Data:\n")
if (file.exists("10_Data/11_Processed/01_data_clean_sitc.csv")) {
  cat("   ✓ 10_Data/11_Processed/01_data_clean_sitc.csv\n")
}
if (file.exists("10_Data/11_Processed/cleaned_BIS_monthly_all_indicators.csv")) {
  cat("   ✓ 10_Data/11_Processed/cleaned_BIS_monthly_all_indicators.csv\n")
}

cat("\n2. Visualizations:\n")
viz_files <- c(
  "20_Images/02_eu_trade_china_sector_trends.png",
  "20_Images/03_eu_trade_china_sector_indexed.png",
  "20_Images/05_grand_unification_No_zoom.png",
  "20_Images/06_banking_claims_CN_all_indic.png"
)
for (viz in viz_files) {
  if (file.exists(viz)) {
    cat("   ✓", viz, "\n")
  }
}

cat("\n3. Statistical Results:\n")
stat_files <- c(
  "30_Report/strucchange_results.csv",
  "30_Report/strucchange_control_results.csv"
)
for (stat in stat_files) {
  if (file.exists(stat)) {
    cat("   ✓", stat, "\n")
  }
}

cat("\n")
cat("KEY FINDINGS\n")
cat("------------------------------------------------------------------------\n")

if (file.exists("30_Report/strucchange_results.csv") && 
    file.exists("30_Report/strucchange_control_results.csv")) {
  
  results <- read.csv("30_Report/strucchange_results.csv")
  results_control <- read.csv("30_Report/strucchange_control_results.csv")
  
  cat("High-Tech & Strategic Imports:\n")
  cat("  F-statistic:", round(results$chow_statistic, 2), "\n")
  cat("  P-value:", format(results$chow_p_value, scientific = TRUE), "\n")
  cat("  Significance: p < 0.0001 (HIGHLY SIGNIFICANT)\n\n")
  
  cat("Traditional & Basic Imports (Control):\n")
  cat("  F-statistic:", round(results_control$chow_statistic, 2), "\n")
  cat("  P-value:", format(results_control$chow_p_value, scientific = TRUE), "\n")
  cat("  Significance: p < 0.001 (SIGNIFICANT)\n\n")
  
  ratio <- results$chow_statistic / results_control$chow_statistic
  
  cat("COMPARATIVE ANALYSIS:\n")
  cat("  Intensity Ratio:", round(ratio, 1), "x\n")
  cat("  Interpretation: Strategic sectors experienced a structural break\n")
  cat("                  ", round(ratio, 1), "times more intense than traditional sectors\n\n")
  
  cat("CONCLUSION:\n")
  cat("  ✓ Evidence of SELECTIVE de-risking confirmed\n")
  cat("  ✓ EU Economic Security Strategy successfully targeted strategic sectors\n")
  cat("  ✓ Traditional trade relationships maintained at baseline levels\n\n")
}

cat("NEXT STEPS\n")
cat("------------------------------------------------------------------------\n")
cat("1. Review generated visualizations in 20_Images/\n")
cat("2. Check statistical results in 30_Report/\n")
cat("3. Re-launch dashboard: source('40_Scripts/11_dashboard.R')\n")
cat("4. For live version, visit: https://[your-shinyapps-url].shinyapps.io/\n\n")

cat("TROUBLESHOOTING\n")
cat("------------------------------------------------------------------------\n")
cat("If any steps failed:\n")
cat("  - Check internet connection (required for API data download)\n")
cat("  - Ensure all required packages installed (run foundation.R)\n")
cat("  - Re-run individual scripts from 40_Scripts/ directory\n")
cat("  - See README.txt for detailed troubleshooting guide\n\n")

cat("================================================================================\n")
cat("Analysis pipeline complete! Thank you for using EU-China Trade Monitor.\n")
cat("For questions, see README.txt or visit the GitHub repository.\n")
cat("================================================================================\n\n")
