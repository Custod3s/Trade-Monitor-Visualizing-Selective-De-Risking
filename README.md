# 🇪🇺 EU-China Trade Monitor: Visualizing Selective De-Risking
### *Is the EU successfully 'de-risking' from China?*

![Status](https://img.shields.io/badge/Status-Active-success)
![Language](https://img.shields.io/badge/Language-R-blue)
![Data](https://img.shields.io/badge/Source-ECB%20SDW-orange)

---

## 📄 Executive Summary

This project investigates the hypothesis of **"Selective Fragmentation"** in EU-China trade relations. Following the [Joint Communication on a European Economic Security Strategy (2023)](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A52023JC0020), the EU aimed to reduce dependency in strategic sectors ("de-risking") while maintaining general economic openness.

[📄 **Read the Full Analysis Report**](30_Report/report.md)

Using monthly trade data from the **ECB Statistical Data Warehouse (2020–2025)** and the ***BIS***, this analysis separates import flows into **High-Tech/Strategic** (SITC 5+7) and **Traditional/Basic** (SITC 6+8) sectors.

**Key Finding:**
Visual and statistical analysis confirms a **structural divergence** beginning in **November 2023**. While traditional imports have stabilized near baseline levels, strategic high-tech imports have structurally declined by ~15%. This break coincides with a regulatory "perfect storm" in late 2023: the operationalization of the EU Economic Security Strategy, the launch of the EV anti-subsidy probe, and the alignment with tightened US export controls (Oct 17, 2023).
[Dashboard Link](https://custod3s.shinyapps.io/data_challenge/)


---

## [📊 The "Money Plot": Evidence of Divergence](https://custod3s.shinyapps.io/data_challenge/)

![Relative Trade Performance](20_Images/Dashboard_Top.png)
> **Panel 1: Dashboard Overview.** The dashboard captures the dual dynamics of the EU's shifting supply chain.
> * Panel 1a (The "Gap"): Visualizes the internal structural break within Chinese imports, where strategic High-Tech flows (Blue) have decoupled from the Traditional baseline (Grey) since Nov 2023.
> * Panel 1b (The Benchmarks): Contextualizes China's decline against alternative trading partners (US, Vietnam, Rest of EU). This comparison highlights whether the "lost" Chinese volume is being substituted by "Friend-shoring" partners or simply evaporating.

![Banking Claims & Forecast](20_Images/Dashboard_Middle.png)
> **Panel 2: EU Banking Claims in CN & Trend Forecast.** The dashboard showcases the EU banking claims in CHINA and a possible forecast of future trends.
> * Panel 2a (The "Claims"): **The Localization Paradox.** While trade flows fell, banking claims *rose* post-Nov 2023. This reveals that EU firms are substituting imports with local production ("In China, For China"). To de-risk supply chains (fewer imports), companies paradoxically had to "re-risk" balance sheets (capital investment for local factories), driving up financial exposure.
> * Panel 2b (The "Trend"): This forecast illustrates the 'New Normal'. Unlike the stable pre-2023 trend, the post-2023 trajectory shows a structural decline. If policy and market conditions remain unchanged, this model predicts where the relationship is heading.

![Trade & Finance Divergence](20_Images/Dashboard_Bottom.png)
> **Panel 3: The Substitution Effect (Index: Avg 2022 = 100).**
> The structural decline in "Strategic" imports (Blue) is mirrored by a *divergent* rise in EU Banking Exposure (Red Dashed) after late 2023 (Nov). This confirms a shift from **Trade Integration** (buying goods) to **Capital Integration** (funding local factories). The "break" in Nov 2023 triggered a "Local-for-Local" strategy: EU firms stopped importing but started investing to maintain market share.
>
---

### Methodology

Using structural break detection (Chow test) on monthly trade data 
(2022-2025), we identify a statistically significant break in November 2023.
This timing corresponds with the "regulatory shockwave" of late 2023: the alignment of the EU Economic Security Strategy with new US export controls (Oct 17) and the launch of the EU's anti-subsidy probe into Chinese EVs.

**Hypothesis:**
* **Null Hypothesis ($H_0$):** No structural break exists (trend is stable).
* **Break Point Tested:** November 2023 (Compound Effect: Economic Security Strategy Implementation + US Export Controls + EU Anti-Subsidy Probes).
* **Timeframe Note:** The structural break analysis (`08_strucchange.R`) intentionally restricts the search window to start from **January 2022** (excluding 2020-2021 data). This was done to filter out the extreme "COVID Recovery Noise" (e.g., supply chain bullwhip effects in late 2021) that would otherwise mask the more subtle policy-driven break in late 2023.

**Assumption Verification (Pre-Conditions):**
To ensure the validity of the Chow test, we performed the following diagnostic checks on the linear model residuals (Script `07_precon_check.R`):
*   **Normality:** Verified using the **Shapiro-Wilk test** and visual inspection of **QQ Plots**.
*   **Autocorrelation:** Assessed via the **Autocorrelation Function (ACF)** to check for serial dependence in the time series.
    *   [📄 View Visual ACF Plot](20_Images/Visual%20ACF.pdf)
*   **Homoscedasticity:** Visual inspection of residuals over time to confirm constant variance and rule out heteroscedasticity.

**Results:**


| Sector                | F-Statistic | P-Value  | Interpretation                  |
| :-------------------- | :---------- | :------- | :------------------------------ |
| High-Tech (Strategic) | 38.78       | < 0.0001 | Massive Break (Policy + Market) |
| Low-Tech (Control)    | 24.05        | < 0.0001   | Minor Deviation (Stable Trend)  |



### Key Statistical Finding







Both High-Tech and Traditional sectors show significant structural breaks at 



Nov 2023 (p < 0.001), but the magnitude differs dramatically:



- **High-Tech & Strategic**: F = 38.78 (p < 0.0001)

- **Traditional & Basic**: F = 24.05 (p < 0.0001)

- **Intensity Ratio**: ~2x stronger in strategic sectors



**Interpretation**: While strategic trade collapsed (F=38.78), traditional trade showed significantly less structural change (F=24.05). This confirms that "De-risking" was surgical, affecting only the targeted sectors while leaving general trade largely untouched.

**Conclusion**: The structural break in strategic goods is **~2x more intense** than in general trade,
  confirming that "De-risking" effectively decoupled the high-tech sector beyond normal market fluctuations.



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


