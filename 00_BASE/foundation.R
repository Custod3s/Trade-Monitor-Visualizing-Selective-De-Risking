# --- PROJECT SETUP SCRIPT ---

# 1. Create the Folders
dirs <- c("data/raw", "data/processed", "scripts", "report", "images")
lapply(dirs, dir.create, recursive = TRUE)

# 2. Create Placeholder Files (so the folders aren't empty)
# (Git ignores empty folders, so we put a small note in them)
file.create("scripts/01_etl_mapping.R")
file.create("scripts/02_strucchange.R")
file.create("scripts/03_visualization.R")
file.create("report/EU_Economic_Security_Briefing.qmd")

# 3. Create the README (Overwriting the default one)
readme_text <- "# 🇪🇺 EU-China Trade Monitor: Visualizing Selective De-Risking
### *Is the EU successfully 'de-risking' from China?*

![Status](https://img.shields.io/badge/Status-Active-success)

## 📂 Repository Structure
* **data/**: Raw CSVs and processed RDS files.
* **scripts/**: R code for ETL, Stats, and Viz.
* **report/**: Final Quarto analysis.

## 🚀 How to Run
1. Run `scripts/01_etl_mapping.R`
2. Run `scripts/03_visualization.R`
"
writeLines(readme_text, "README.md")

print("✅ Project Structure Created Successfully!")