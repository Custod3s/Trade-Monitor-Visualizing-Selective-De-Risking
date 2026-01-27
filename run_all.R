# ==============================================================================
# MASTER SCRIPT: run_all.R
# PURPOSE: Execute the entire data pipeline from extraction to dashboard.
# ==============================================================================

# Helper function to run scripts and handle errors
run_script <- function(script_path) {
  cat(paste0("\n\n>>> 🚀 STARTING: ", script_path, " <<<
"))
  tryCatch({
    source(script_path, echo = TRUE, max.deparse.length = 10000)
    cat(paste0("\n>>> ✅ COMPLETED: ", script_path, " <<<
"))
  }, error = function(e) {
    cat(paste0("\n>>> ❌ ERROR in ", script_path, ": ", e$message, " <<<
"))
    stop("Pipeline halted due to error.")
  })
}

# 1. Setup & Styling
run_script("40_Scripts/00_style.R")

# 2. Data Extraction (Warning: Requires Internet & API Access)
#    Set run_extraction = FALSE to skip if data is already downloaded.
run_extraction <- FALSE 

if (run_extraction) {
  run_script("40_Scripts/01_data_pull.R")
  run_script("40_Scripts/02_data_pull_BIS.R")
  run_script("40_Scripts/03_bis_pull_all_indicators.R")
} else {
  cat("\n>>> ⏭️ SKIPPING DATA EXTRACTION (Set run_extraction = TRUE to run) <<<
")
}

# 3. Data Processing & Mapping
run_script("40_Scripts/04_sitc_mapping.R")

# 4. Exploratory Analysis & Merging
run_script("40_Scripts/05_first_look.R")
run_script("40_Scripts/06_finance_x_imports_CN.R")

# 5. Statistical Modeling & Structural Breaks
run_script("40_Scripts/07_precon_check.R")
run_script("40_Scripts/08_strucchange.R")         # Main Analysis (High-Tech) 
run_script("40_Scripts/09_strucchange_control.R") # Control Analysis (Low-Tech)

# 6. Forecasting
run_script("40_Scripts/10_prediction.R")

# 7. Documentation Update
run_script("40_Scripts/15_update_documentation.R")

# 8. Dashboard
cat("\n\n====================================================================")
cat("\n✅ PIPELINE COMPLETE!")
cat("\nTo launch the dashboard, run:")
cat("\n   runApp('40_Scripts/14_dashboard_v3.R')")
cat("\n====================================================================\n")
