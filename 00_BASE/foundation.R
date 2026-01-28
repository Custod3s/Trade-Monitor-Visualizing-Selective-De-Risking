# =============================================================================
# FOUNDATION.R - Project Setup and Configuration
# Trade Monitor: Visualizing Selective De-Risking
# =============================================================================
# Description: Central configuration file for project setup, package management,
#              and environment initialization
# Author: Alexander Haas
# Last Updated: 2025-01-15
# =============================================================================

# Suppress startup messages
options(warn = -1)

cat("\n=== TRADE MONITOR PROJECT INITIALIZATION ===\n\n")

# -----------------------------------------------------------------------------
# 1. PROJECT PATHS SETUP
# -----------------------------------------------------------------------------
cat("📁 Setting up project paths...\n")

# Use here package for robust path management (install if needed)
if (!require("here", quietly = TRUE)) {
  install.packages("here")
  library(here)
}

# Define project root and key directories
proj_root <- here::here()
setwd(proj_root)

# Define directory structure
dirs <- list(
  data_raw = "10_Data/12_Raw",
  data_processed = "10_Data/11_Processed",
  scripts = "40_Scripts",
  images = "20_Images",
  report = "30_Report",
  config = "config",
  docs = "docs",
  tests = "50_Tests"
)

# Create directories if they don't exist
for (dir_name in names(dirs)) {
  dir_path <- file.path(proj_root, dirs[[dir_name]])
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
    cat(sprintf("  ✓ Created: %s\n", dirs[[dir_name]]))
  }
}

# Create .gitkeep files in output directories to preserve structure
gitkeep_dirs <- c("20_Images", "30_Report", "10_Data/11_Processed")
for (gk_dir in gitkeep_dirs) {
  gitkeep_path <- file.path(proj_root, gk_dir, ".gitkeep")
  if (!file.exists(gitkeep_path)) {
    file.create(gitkeep_path)
  }
}

cat("  ✓ Directory structure verified\n\n")

# -----------------------------------------------------------------------------
# 2. REQUIRED PACKAGES
# -----------------------------------------------------------------------------
cat("📦 Checking and installing required packages...\n")

# Core packages
required_packages <- c(
  # Data manipulation
  "tidyverse",      # Complete data science toolkit
  "data.table",     # Fast data processing
  "lubridate",      # Date handling
  "janitor",        # Data cleaning
  
  # API and web
  "httr",           # API requests
  "jsonlite",       # JSON parsing
  "rvest",          # Web scraping (if needed)
  
  # Statistical analysis
  "strucchange",    # Structural break detection
  "tseries",        # Time series analysis
  "forecast",       # Forecasting methods
  
  # Visualization
  "ggplot2",        # Already in tidyverse, but explicit
  "scales",         # Scale functions for ggplot2
  "patchwork",      # Combining plots
  "plotly",         # Interactive plots
  "ggthemes",       # Additional themes
  "viridis",        # Color palettes
  
  # Reporting
  "knitr",          # Dynamic reports
  "rmarkdown",      # R Markdown
  "DT",             # Interactive tables
  
  # Project management
  "here",           # Path management
  "glue",           # String interpolation
  "cli"             # Pretty console output
)

# Function to install missing packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
  if (length(new_packages) > 0) {
    cat(sprintf("  Installing: %s\n", paste(new_packages, collapse = ", ")))
    install.packages(new_packages, dependencies = TRUE, quiet = TRUE)
  }
}

# Install missing packages
install_if_missing(required_packages)

# Load all packages silently
suppressPackageStartupMessages({
  invisible(lapply(required_packages, library, character.only = TRUE, quietly = TRUE))
})

cat("  ✓ All packages loaded successfully\n\n")

# -----------------------------------------------------------------------------
# 3. DEPENDENCY MANAGEMENT (renv)
# -----------------------------------------------------------------------------
cat("🔒 Checking dependency management...\n")

if (!file.exists("renv.lock")) {
  cat("  ⚠ No renv.lock found. Consider initializing renv for reproducibility:\n")
  cat("    Run: renv::init() then renv::snapshot()\n")
} else {
  if (!require("renv", quietly = TRUE)) {
    install.packages("renv")
  }
  cat("  ✓ renv detected - dependency management active\n")
}
cat("\n")

# -----------------------------------------------------------------------------
# 4. GLOBAL OPTIONS AND SETTINGS
# -----------------------------------------------------------------------------
cat("⚙️  Configuring global options...\n")

# General options
options(
  scipen = 999,              # Disable scientific notation
  digits = 4,                # Decimal places
  max.print = 1000,          # Max print items
  stringsAsFactors = FALSE,  # Never auto-convert to factors
  encoding = "UTF-8"         # Character encoding
)

# Tidyverse options
options(
  dplyr.summarise.inform = FALSE,  # Suppress grouping messages
  tidyverse.quiet = TRUE            # Quiet package loading
)

# ggplot2 theme
theme_set(theme_minimal(base_size = 12))

# Data.table options (if using)
options(datatable.print.class = TRUE)

cat("  ✓ Global options configured\n\n")

# -----------------------------------------------------------------------------
# 5. HELPER FUNCTIONS
# -----------------------------------------------------------------------------
cat("🔧 Loading helper functions...\n")

# Function to safely source scripts
safe_source <- function(file_path, verbose = TRUE) {
  full_path <- here::here(file_path)
  if (file.exists(full_path)) {
    source(full_path)
    if (verbose) cat(sprintf("  ✓ Sourced: %s\n", file_path))
    return(TRUE)
  } else {
    warning(sprintf("  ✗ File not found: %s\n", file_path))
    return(FALSE)
  }
}

# Function to check if data files exist
check_data <- function(filename, dir = "10_Data/12_Raw") {
  file_path <- here::here(dir, filename)
  exists <- file.exists(file_path)
  status <- if (exists) "✓" else "✗"
  cat(sprintf("  %s %s\n", status, filename))
  return(exists)
}

# Function to save processed data with timestamp
save_processed <- function(data, filename, add_timestamp = FALSE) {
  if (add_timestamp) {
    name_parts <- tools::file_path_sans_ext(filename)
    ext <- tools::file_ext(filename)
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    filename <- sprintf("%s_%s.%s", name_parts, timestamp, ext)
  }
  
  save_path <- here::here("10_Data/11_Processed", filename)
  
  if (grepl("\\.csv$", filename)) {
    readr::write_csv(data, save_path)
  } else if (grepl("\\.rds$", filename)) {
    saveRDS(data, save_path)
  }
  
  cat(sprintf("  ✓ Saved: %s\n", filename))
  return(save_path)
}

# Function to load API links
load_api_links <- function() {
  api_file <- here::here("10_Data/12_Raw/API_links.txt")
  if (file.exists(api_file)) {
    links <- readLines(api_file)
    cat(sprintf("  ✓ Loaded %d API links\n", length(links)))
    return(links)
  } else {
    warning("  ✗ API_links.txt not found\n")
    return(NULL)
  }
}

cat("  ✓ Helper functions loaded\n\n")

# -----------------------------------------------------------------------------
# 6. LOAD STYLING (if exists)
# -----------------------------------------------------------------------------
cat("🎨 Loading custom styling...\n")

style_script <- "40_Scripts/00_style.R"
if (file.exists(here::here(style_script))) {
  safe_source(style_script, verbose = FALSE)
  cat("  ✓ Custom styling loaded from 00_style.R\n")
} else {
  cat("  ℹ No custom styling file found (optional)\n")
}
cat("\n")

# -----------------------------------------------------------------------------
# 7. ENVIRONMENT VALIDATION
# -----------------------------------------------------------------------------
cat("✅ Validating environment...\n")

# Check R version
r_version <- paste(R.version$major, R.version$minor, sep = ".")
cat(sprintf("  R Version: %s\n", r_version))

if (as.numeric(R.version$major) < 4) {
  warning("  ⚠ R version < 4.0 detected. Consider upgrading for best compatibility.\n")
}

# Check working directory
cat(sprintf("  Working Directory: %s\n", getwd()))

# Check critical directories
critical_dirs <- c("10_Data", "40_Scripts")
all_exist <- all(sapply(critical_dirs, function(d) dir.exists(here::here(d))))

if (all_exist) {
  cat("  ✓ All critical directories present\n")
} else {
  warning("  ⚠ Some critical directories missing\n")
}

cat("\n")

# -----------------------------------------------------------------------------
# 8. CREATE .gitignore (if missing)
# -----------------------------------------------------------------------------
if (!file.exists(here::here(".gitignore"))) {
  cat("📝 Creating .gitignore file...\n")
  
  gitignore_content <- "# System files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Thumbs.db

# R files
.Rhistory
.RData
.Rproj.user/
*.Rproj

# Data files (uncomment to exclude data from repo)
# 10_Data/12_Raw/*.csv
# 10_Data/12_Raw/*.xlsx
# 10_Data/11_Processed/*.csv
!10_Data/12_Raw/API_links.txt

# Outputs (uncomment if outputs shouldn't be versioned)
# 20_Images/*.png
# 20_Images/*.pdf
# 30_Report/*.html
# 30_Report/*.pdf

# Credentials
.env
credentials.R
api_keys.txt
.Renviron

# renv
renv/library/
renv/staging/
"
  
  writeLines(gitignore_content, here::here(".gitignore"))
  cat("  ✓ .gitignore created\n\n")
}

# -----------------------------------------------------------------------------
# 9. SUMMARY
# -----------------------------------------------------------------------------
cat("=== INITIALIZATION COMPLETE ===\n\n")

cat("📊 Project Summary:\n")
cat(sprintf("  Project Root: %s\n", proj_root))
cat(sprintf("  Packages Loaded: %d\n", length(required_packages)))
cat("\n")

cat("📋 Next Steps:\n")
cat("  1. Run: source('40_Scripts/01_data_pull.r') to fetch data\n")
cat("  2. Run: source('40_Scripts/02_sitc_mapping.r') to process classifications\n")
cat("  3. Run: source('40_Scripts/09_dashboard.R') to generate visualizations\n")
cat("\n")

cat("💡 Useful Commands:\n")
cat("  - check_data('filename.csv')  : Check if data file exists\n")
cat("  - save_processed(df, 'name')  : Save processed data\n")
cat("  - load_api_links()            : Load API endpoints\n")
cat("\n")

cat("For full workflow, see README.md\n")
cat("=====================================\n\n")

# Restore warnings
options(warn = 0)

# Return invisible list of paths for programmatic access
invisible(list(
  root = proj_root,
  dirs = dirs,
  packages = required_packages
))