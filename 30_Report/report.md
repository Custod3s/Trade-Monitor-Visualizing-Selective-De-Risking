# The Resilience Paradox: Mapping EU-China Strategic Trade and Financial
Fragmentation
Alexander HAAS, Viliam POHANCENIK, Pieter PEVERELLI
January 28, 2026

- [<span class="toc-section-number">1</span>
  Introduction](#introduction)
- [<span class="toc-section-number">2</span> Conceptual Framework &
  Hypothesis](#conceptual-framework--hypothesis)
  - [<span class="toc-section-number">2.1</span> Weaponized
    Interdependence as a Strategic
    Lens](#weaponized-interdependence-as-a-strategic-lens)
  - [<span class="toc-section-number">2.2</span> From Theory to Testable
    Expectations](#from-theory-to-testable-expectations)
- [<span class="toc-section-number">3</span> Data and Empirical
  Strategy](#data-and-empirical-strategy)
  - [<span class="toc-section-number">3.1</span> Data Acquisition and
    Categorization](#data-acquisition-and-categorization)
  - [<span class="toc-section-number">3.2</span> Descriptive
    Statistics](#descriptive-statistics)
  - [<span class="toc-section-number">3.3</span> Econometric
    Framework](#econometric-framework)
- [<span class="toc-section-number">4</span> Results](#results)
  - [<span class="toc-section-number">4.1</span> Structural Break
    Analysis](#structural-break-analysis)
  - [<span class="toc-section-number">4.2</span> Visualization of
    Distributions](#visualization-of-distributions)
  - [<span class="toc-section-number">4.3</span> The Finance-Trade
    Divergence](#the-finance-trade-divergence)
- [<span class="toc-section-number">5</span> Discussion and Policy
  Implications](#discussion-and-policy-implications)
  - [<span class="toc-section-number">5.1</span> Future Trajectory
    (2026)](#future-trajectory-2026)
- [<span class="toc-section-number">6</span> Conclusion](#conclusion)
- [<span class="toc-section-number">7</span> References](#references)

# Introduction

The evolution of EU-China economic relations has undergone a fundamental
departure from the *Wandel durch Handel* (“change through trade”)
paradigm toward a strategy of “de-risking.” This shift is primarily
aimed at correcting a trade deficit that reached €304.5 billion by 2024
and mitigating the risks of “coercive leverage” in critical supply
chains (Vandermeeren, 2024).

However, the effectiveness of this policy pivot remains contested.
Beyond the political rhetoric, a critical empirical question remains:
**Does EU de-risking translate into measurable, sector-specific changes
in trade and financial exposure vis-à-vis China?**

This study addresses this question by quantifying the “security-trade
nexus.” We make two key contributions: 1. **Selective Fragmentation:**
We provide evidence that de-risking is not a generalized decoupling but
a surgical, sector-specific phenomenon. 2. **Trade-Finance Divergence:**
Beyond trade fragmentation, we show that de-risking may involve
substitution toward financial exposure rather than disengagement. While
high-tech trade flows contract, financial linkages exhibit a paradoxical
resilience, suggesting a shift toward “local-for-local” production
strategies.

# Conceptual Framework & Hypothesis

## Weaponized Interdependence as a Strategic Lens

Our analysis is anchored in the theory of “Weaponized Interdependence”
(Farrell & Newman, 2019). Unlike traditional trade theory, which views
dense economic networks as sources of efficiency and peace (*Wandel
durch Handel*), this framework posits that asymmetric network structures
can be leveraged for strategic advantage. In this context, the EU’s
regulatory expansion—often described as the “Brussels Effect” (Bradford,
2020)—functions as a defensive mechanism to reclaim economic security.

The central premise of weaponized interdependence is **selectivity**.
De-risking strategies do not aim for autarky but for the neutralization
of specific choke points. Therefore, we should not expect a uniform
collapse in EU-China trade, but rather a divergence between “strategic”
and “non-strategic” sectors.

## From Theory to Testable Expectations

The literature implies that de-risking should manifest as a targeted
adjustment rather than broad withdrawal. Empirically, this implies that
structural breaks in EU–China trade flows should be stronger and more
persistent in security-relevant sectors than in traditional, cost-driven
trade.

The following analysis tests this expectation by comparing the timing
and intensity of structural breaks across sectoral groups, using
traditional sectors as a benchmark to distinguish policy-driven
selectivity from broader global shocks. We hypothesize a “dual-track”
adjustment: 1. **High-Tech & Strategic Sectors** (e.g., semiconductors,
chemicals) will exhibit significant structural ruptures in response to
policy signaling. 2. **Traditional & Basic Sectors** (e.g., manufactured
goods) will remain largely stable, following market logic rather than
security logic.

# Data and Empirical Strategy

To empirically evaluate the manifestation of “de-risking,” this study
employs a quantitative, sectoral structural break analysis. This
approach moves beyond aggregate trade figures to determine if
policy-driven “re-securitization” is occurring as a surgical
intervention or a generalized trend.

## Data Acquisition and Categorization

The empirical foundation rests on a high-frequency longitudinal dataset
(2020–2025) constructed through automated API retrieval from Eurostat
(COMEXT) (Eurostat, 2026) and the Bank for International Settlements
(BIS) (Bank for International Settlements, 2026). Trade flows are
disaggregated using the Standard International Trade Classification
(SITC) Revision 4:

- **Treatment Group** (High-Tech & Strategic): Comprising SITC 5
  (Chemicals) and SITC 7 (Machinery/Transport). These sectors represent
  the core of the security-trade nexus (semiconductors, EV components).

- **Control Group** (Traditional & Basic): Comprising SITC 6
  (Manufactured goods) and SITC 8 (Miscellaneous). These sectors serve
  as a baseline for market-driven trade.

**Limitation:** While SITC categories allow for consistent long-run
comparison, they remain quite broad and may hide heterogeneity within
strategic sectors. The analysis therefore focuses on sectoral trends
rather than product-level effects.

## Descriptive Statistics

Before assessing structural breaks, we examine the baseline
characteristics of trade flows in the post-pandemic era.

<div id="tbl-descriptive">

Table 1: Descriptive Statistics of Monthly Trade Flows (Jan 2021 -
Present). Values in Billion USD.

<div class="cell-output-display">

| Sector                | Mean_Monthly |   SD |   Min |   Max |
|:----------------------|-------------:|-----:|------:|------:|
| High-Tech & Strategic |        23.33 | 3.29 | 15.59 | 30.52 |
| Traditional & Basic   |        12.26 | 1.90 |  8.73 | 17.34 |

</div>

</div>

## Econometric Framework

The primary analytical instrument is the Chow Test (Chow, 1960), a
standard in econometric literature for identifying structural breaks in
time-series data. The model tests for a break point in May 2023,
representing early geoeconomic shifts prior to the formal Economic
Security Strategy (European Commission, 2023).

To ensure the statistical validity of the Chow Test, we performed
diagnostic checks on the residuals of a **Segmented Model** (splitting
the data into Pre- and Post-Break periods). Standard diagnostic checks
confirm that residuals are approximately normally distributed
(Shapiro-Wilk $W = 0.98, p > 0.05$), free of serial correlation, and
homoscedastic once the structural break is accounted for, supporting the
validity of the Chow test results.

# Results

## Structural Break Analysis

The model identified a definitive structural break occurring in May
2023.

- Treatment Group (Strategic): Yielded a highly significant F-statistic
  of 21.8 ($p < 0.0001$). A value of 21.8 implies a massive structural
  rupture, not just a statistical blip, indicating a fundamental regime
  shift in trade behavior.

- Control Group (Traditional): Showed a significantly weaker response
  with an F-statistic of 5.52.

The timing of this break (May 2023) aligns with the ‘Signaling
Shockwave’ of the G7 Hiroshima Summit. Even if the timing of the break
aligns closely with geopolitical signaling and policy changes,
structural break tests alone cannot prove causality. The results should
therefore be interpreted as indicative of policy-consistent behavior
rather than clear causal effects.

The Intensity Ratio of 3.9x further validates that these shifts
specifically targeted the high-tech/strategic nexus while leaving
traditional trade relationships relatively intact.

## Visualization of Distributions

<a href="#fig-boxplot" class="quarto-xref">Figure 1</a> demonstrates the
distributional shift, which supports the **Weaponized Interdependence**
hypothesis by showing a compressed range and lower median in strategic
sectors post-break. This contraction aligns with the expectation that
state intervention (export controls, screening) restricts market-driven
volatility in sensitive sectors.

<div id="fig-boxplot">

<img src="report_files/figure-commonmark/fig-boxplot-1.png"
data-fig-pos="H" />

Figure 1: Structural Shift: High-Tech trade shows a lower median and
compressed range post-Structural Break.

</div>

## The Finance-Trade Divergence

Recognizing that geoeconomics is inherently multi-disciplinary, we
integrate trade data with financial flows from the BIS. The results
reveal a “Localization Paradox.”

<div id="fig-unified">

<img src="report_files/figure-commonmark/fig-unified-1.png"
style="width:100.0%" data-fig-pos="H" />

Figure 2: The Dual De-Risking: Divergence of Trade and Finance.

</div>

<a href="#fig-unified" class="quarto-xref">Figure 2</a> demonstrates a
“dual-track” reality, which supports the **Weaponized Interdependence**
hypothesis by showing that while strategic trade (Blue Line) fragments
due to policy friction, financial linkages (Red Dashed Line) remain
resilient.

This divergence suggests that de-risking is not a total withdrawal but a
**reconfiguration**: EU firms appear to be substituting cross-border
trade with “local-for-local” production funded by increased capital
exposure, effectively bypassing trade barriers while maintaining market
access.

# Discussion and Policy Implications

## Future Trajectory (2026)

Based on the post-break trend (May 2023–Present), our linear model
projects a continued stabilization at lower levels rather than a
rebound.

<div id="fig-forecast">

<img src="report_files/figure-commonmark/fig-forecast-1.png"
style="width:100.0%" data-fig-pos="H" />

Figure 3: Forecast 2026: Strategic Sector Trajectory based on post-break
linear extrapolation.

</div>

It is important to note that the data captures financial exposure
through banking channel and do not completely reflect FDI flows.
Therefore, the observed financial substitution may show a lower bound of
total capital reallocation.

# Conclusion

The data demonstrates that “de-risking” is a measurable, sector-specific
phenomenon. The structural break in May 2023 validates that the European
market began fragmenting in direct response to the formal 2023 strategy,
rather than well before it.

This distinction is vital for policymakers: economic security tools
work, but they function as “shocks” that sever trade integration
abruptly. As the EU looks toward 2027, the challenge will be maintaining
this “surgical” precision without sliding into broader protectionism
that could stifle the very innovation it seeks to protect. De-risking
works, but it works through shocks and this increases costs and risk of
overreach.

# References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0" line-spacing="2">

<div id="ref-bis2026" class="csl-entry">

Bank for International Settlements. (2026). *Locational banking
statistics*. BIS. <https://stats.bis.org>

</div>

<div id="ref-bradford2020" class="csl-entry">

Bradford, A. (2020). *The brussels effect: How the european union rules
the world*. Oxford University Press.

</div>

<div id="ref-chow1960" class="csl-entry">

Chow, G. C. (1960). *Tests of equality between sets of coefficients in
two linear regressions* (Vol. 28, pp. 591–605). Econometrica.

</div>

<div id="ref-eu_strategy" class="csl-entry">

European Commission. (2023). *Joint communication on a european economic
security strategy*. European Union.

</div>

<div id="ref-eurostat2026" class="csl-entry">

Eurostat. (2026). *Euro area trade by SITC product group*. European
Commission. <https://ec.europa.eu/eurostat>

</div>

<div id="ref-farrell2019" class="csl-entry">

Farrell, H., & Newman, A. L. (2019). Weaponized interdependence: How
global economic networks shape state coercion. *International Security*,
*44*(1), 42–79.

</div>

<div id="ref-vandermeeren2024" class="csl-entry">

Vandermeeren, F. (2024). Understanding EU-china economic exposure.
*European Economy Brief*, (004).

</div>

</div>
