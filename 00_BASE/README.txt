# Trade Monitor: Visualizing Selective De-Risking

A data analysis and visualization project examining international trade patterns and financial exposure, with focus on selective de-risking in global trade relationships.

## 📋 Project Overview

This repository contains R-based analytical tools for processing, analyzing, and visualizing trade data from multiple sources including BIS (Bank for International Settlements) financial exposure data and international trade statistics.

## 🏗️ Project Structure

```
├── foundation.R                 # Core setup and configuration
│
├── 10_Data/                     # Data storage directory
│   ├── 11_Processed/           # Cleaned and processed datasets
│   │   ├── 01_data_clean_sitc.csv
│   │   ├── cleaned_BIS_monthly_LG.csv
│   │   └── cleaned_BIS_monthly_all_indic...
│   └── 12_Raw/                 # Raw data files
│       ├── API_links.txt
│       ├── BIS_Financial_Exposure_EU_C...
│       └── pulled_EU_CN_VN_US_2020-2...
│
├── 20_Images/                   # Generated visualizations and plots
│
├── 30_Report/                   # Report outputs and documentation
│
└── 40_Scripts/                  # Analysis and processing scripts
    ├── 00_style.R              # Styling and theming configuration
    ├── 01_data_pull.r          # Data retrieval from APIs
    ├── 02_sitc_mapping.r       # SITC classification mapping
    ├── 03_first_look.R         # Initial exploratory analysis
    ├── 04_data_pull_BIS.R      # BIS data extraction
    ├── 05_finance_x_imports_CN.R  # Cross-analysis: finance & imports
    ├── 06_bis_pull_all_indicators.R  # Comprehensive BIS indicators
    ├── 07_strucchange.R        # Structural change detection
    ├── 08_strucchange_control.R  # Control analysis for structural changes
    ├── 09_dashboard.R          # Main dashboard generation
    └── 10_dashboard_alt.R      # Alternative dashboard view
```

## 🚀 Getting Started

### Prerequisites

- R (version 4.0 or higher recommended)
- RStudio (optional but recommended)
- Required R packages (see Dependencies section)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Custod3s/Trade-Monitor-Visualizing-Selective-De-Risking.git
cd Trade-Monitor-Visualizing-Selective-De-Risking
```

2. Open `foundation.R` in R/RStudio to set up the project environment

3. Install required packages (automatically handled by foundation.R)

## 📊 Data Sources

The project integrates data from multiple sources:

- **BIS (Bank for International Settlements)**: Financial exposure data
- **International Trade APIs**: Trade flow statistics
- **SITC Classification**: Standard International Trade Classification for product categorization

API endpoints and documentation links are stored in `10_Data/12_Raw/API_links.txt`

## 🔄 Workflow

### 1. Data Collection
Run scripts in order:
```r
source("40_Scripts/01_data_pull.r")          # Pull trade data
source("40_Scripts/04_data_pull_BIS.R")      # Pull BIS financial data
source("40_Scripts/06_bis_pull_all_indicators.R")  # Pull all BIS indicators
```

### 2. Data Processing
```r
source("40_Scripts/02_sitc_mapping.r")       # Map SITC classifications
# Processed data saved to 10_Data/11_Processed/
```

### 3. Analysis
```r
source("40_Scripts/03_first_look.R")         # Exploratory analysis
source("40_Scripts/05_finance_x_imports_CN.R")  # Cross-sectional analysis
source("40_Scripts/07_strucchange.R")        # Detect structural breaks
source("40_Scripts/08_strucchange_control.R")  # Control analysis
```

### 4. Visualization
```r
source("40_Scripts/09_dashboard.R")          # Generate main dashboard
source("40_Scripts/10_dashboard_alt.R")      # Generate alternative views
# Outputs saved to 20_Images/ and 30_Report/
```

## 📈 Key Features

- **Automated Data Retrieval**: Scripts for pulling data from multiple APIs
- **SITC Mapping**: Standardized trade classification mapping
- **Structural Break Analysis**: Detection of significant changes in trade patterns
- **Financial-Trade Cross-Analysis**: Examining relationships between financial exposure and trade flows
- **Interactive Dashboards**: Visual exploration of trade de-risking patterns
- **Focus Regions**: Analysis of EU, China, Vietnam, and US trade relationships (2020-present)

## 🔍 Analysis Components

### Structural Change Detection
The `strucchange` scripts identify statistically significant breaks in trade patterns that may indicate selective de-risking strategies.

### Cross-Sectional Analysis
Analysis of the relationship between financial exposure (from BIS data) and import patterns, particularly focusing on China-related trade flows.

### Dashboard Visualization
Interactive visualizations showing:
- Trade flow trends over time
- Financial exposure patterns
- Risk concentration indicators
- Geographic distribution of trade relationships

## 📝 Output

Analysis outputs are organized as follows:
- **Processed Data**: `10_Data/11_Processed/`
- **Visualizations**: `20_Images/`
- **Reports**: `30_Report/`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

[Specify your license here]

## 👥 Authors

- [Your Name/Organization]

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

## 🙏 Acknowledgments

- Bank for International Settlements (BIS) for financial statistics
- [Other data providers and contributors]

---

**Note**: Ensure all API keys and credentials are stored securely and never committed to version control. Use environment variables or a separate configuration file (added to `.gitignore`) for sensitive information.