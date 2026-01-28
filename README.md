# 🇪🇺 EU-China Trade Monitor: Visualizing Selective De-Risking
### *Is the EU successfully 'de-risking' from China?*

![Status](https://img.shields.io/badge/Status-Active-success)
![Language](https://img.shields.io/badge/Language-R-blue)
![Data](https://img.shields.io/badge/Source-ECB%20SDW-orange)

---

## 📄 Executive Summary

This project investigates the hypothesis of **"Selective Fragmentation"** in EU-China trade relations. Following the [Joint Communication on a European Economic Security Strategy (2023)](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A52023JC0020), the EU aimed to reduce dependency in strategic sectors ("de-risking") while maintaining general economic openness.

[📄 **Read the Full Analysis Report**](30_Report/report.md)
> 
[📄 **Open the Interactive Dashboard**](https://custod3s.shinyapps.io/data_challenge/)

Using monthly trade data from the **ECB Statistical Data Warehouse (2020–2025)** and the ***BIS***, this analysis separates import flows into **High-Tech/Strategic** (SITC 5+7) and **Traditional/Basic** (SITC 6+8) sectors.

**Key Finding:**
Visual and statistical analysis confirms a **structural divergence** beginning in **May 2023**. While traditional imports have stabilized near baseline levels, strategic high-tech imports have structurally declined by ~15%. The algorithm identifies the most significant break point in **May 2023**, coinciding exactly with the **G7 Hiroshima Summit (19-21 May)** where "De-risking" was formally adopted as a global consensus. This suggests that the market reacted to the **political signal** of the G7 and Ursula von der Leyen's earlier "De-risking" speech (March 30) before the official EU Strategy document was even published in June.

---

## [📊 The "Money Plot": Evidence of Divergence](https://custod3s.shinyapps.io/data_challenge/)

![Relative Trade Performance](20_Images/Dashboard_Top.png)
> **Panel 1: Dashboard Overview.** The dashboard captures the dual dynamics of the EU's shifting supply chain.
> * Panel 1a (The "Gap"): Visualizes the internal structural break within Chinese imports. Since the **G7 Hiroshima Summit (May 2023)**, strategic High-Tech flows (Blue) have decoupled from the Traditional baseline (Grey), reacting to the global signal even before formal EU policy.
> * Panel 1b (The Benchmarks): Contextualizes China's decline against alternative trading partners. This comparison highlights whether the "lost" Chinese volume is being substituted by "Friend-shoring" partners or simply evaporating in response to the de-risking mandate.

![Banking Claims & Forecast](20_Images/Dashboard_Middle.png)
> **Panel 2: EU Banking Claims in CN & Trend Forecast.** The dashboard showcases the EU banking claims in CHINA and a possible forecast of future trends.
> * Panel 2a (The "Claims"): **The Localization Paradox.** While trade flows fell, banking claims *rose* post-May 2023. This suggests that in response to the **G7 de-risking mandate**, EU firms are substituting imports with local production ("In China, For China") to maintain market access while reducing supply chain exposure.
> * Panel 2b (The "Trend"): This forecast illustrates the 'New Normal'. Unlike the stable pre-G7 trend, the post-Hiroshima trajectory shows a structural decline in high-tech imports.

![Trade & Finance Divergence](20_Images/Dashboard_Bottom.png)
> **Panel 3: The Substitution Effect (Index: Avg 2022 = 100).**
> The structural decline in "Strategic" imports (Blue) is mirrored by a *divergent* rise in EU Banking Exposure (Red Dashed) after the **G7 Hiroshima Consensus (May 2023)**. This confirms a rapid shift from **Trade Integration** (buying goods) to **Capital Integration** (funding local factories) as firms front-run regulatory risk.
>
---

### Methodology

Using structural break detection (Chow test) on monthly trade data 
(2022-2025), we searched for the optimal break point starting from **May 2023** (accounting for anticipatory effects).
The algorithm identified **May 2023** as the statistically most significant structural shift. This timing corresponds with the **"Signaling Shockwave"**: the combination of Ursula von der Leyen's landmark "De-risking" speech (March 30) and the formal adoption of de-risking by the G7 leaders in Hiroshima (May 19-21).

**Hypothesis:**
* **Null Hypothesis ($H_0$):** No structural break exists (trend is stable).
* **Break Point Tested:** Dynamic Search (Restricted to **May 2023** onwards). 
    *   *Rationale:* We start the search two months prior to the official Strategy release (June 2023) to capture potential **anticipatory effects** (market "pricing-in" of leaks or drafts) and ensure boundary stability for the statistical test. We then identify the point of maximum structural deviation occurring within this "Strategy Era."
* **Timeframe Note:** The structural break analysis (`08_strucchange.R`) intentionally restricts the search window to start from **January 2022** (excluding 2020-2021 data). This was done to filter out the extreme "COVID Recovery Noise" (e.g., supply chain bullwhip effects in late 2021) that would otherwise mask the more subtle policy-driven break in late 2023.

**Assumption Verification (Pre-Conditions):**
To ensure the validity of the Chow test, we performed the following diagnostic checks on the residuals of a **Segmented Model** (splitting the data into Pre- and Post-Break periods). This approach correctly accounts for the structural shift, preventing false positives in diagnostic tests.

*   **Normality (Confirmed):** Verified using the **Shapiro-Wilk test** on the segmented residuals.
    *   Result: *W = 0.9769, p-value = 0.4698* (p > 0.05, fails to reject normality).
    *   [📄 View Segmented QQ Plot](20_Images/07.1_normality_qq.png)
*   **Autocorrelation:** Assessed via the **Autocorrelation Function (ACF)** separately for Pre- and Post-break periods to rule out serial dependence bias.
    *   [📄 View Segmented ACF Plot](20_Images/07.2_autocorrelation_acf.png)
*   **Homoscedasticity:** Visual inspection of residuals over time (Pre/Post) to confirm constant variance.
    *   [📄 View Segmented Residuals Plot](20_Images/07.3_heteroscedasticity.png)

**Results:**


| Sector                | F-Statistic | P-Value  | Interpretation                  |
| :-------------------- | :---------- | :------- | :------------------------------ |
| High-Tech (Strategic) | 21.80       | < 0.0001 | Massive Break (Policy + Market) |
| Low-Tech (Control)    | 5.52        | 0.0232   | Significant Break (General Volatility) |



### Key Statistical Finding







Both High-Tech and Traditional sectors show significant structural breaks at 



May 2023 (p < 0.05), but the magnitude differs dramatically:



- **High-Tech & Strategic**: F = 21.80 (p < 0.0001)

- **Traditional & Basic**: F = 5.52 (p 0.0232)

- **Intensity Ratio**: ~4x stronger in strategic sectors



**Interpretation**: While strategic trade collapsed (F=21.80), traditional trade showed significantly less structural change (F=5.52). This confirms that "De-risking" was surgical, affecting only the targeted sectors while leaving general trade largely untouched.

**Conclusion**: The structural break in strategic goods is **~4x more intense** than in general trade,
  confirming that "De-risking" successfully triggered a targeted decoupling in high-tech sectors that far exceeds general market volatility.



## 🚀 How to Run
1. Run `00_style.R`- Create a common theme for plots and visual across the whole project
2. Run `01_data_pull.R` - Pulls trade data from Eurostat
3. Run `02_data_pull_BIS.R` & `03_bis_pull_all_indicators.R` - Pulls financial data from the BIS and Visualisation of Banking Claims (Table 2)
4. Run `04_sitc_mapping.R` - Categorizes trade data according to SITC codes
5. Run `05_first_look.R` - Creates a first look (Table 1)
6. Run `06_finance_x_imports_CN.R` - Combines trade & financial data (Table 3)
7. Run `07_precon_check.R` - Diagnostic checks for model assumptions (Normality, Autocorrelation, Homoscedasticity)
8. Run `08_strucchange.R` - Statistical proof of the structural break
9. Run `09_strucchange_control.R` - Confirm / Deny hypotheses of decoupling mechanism
10. Run `10_prediction.R` - Forecast/Prediction models
11. Run `14_dashboard_v3.R` - The main interactive dashboard
12. Run `15_update_documentation.R` - Automatically updates this README with the latest stats


