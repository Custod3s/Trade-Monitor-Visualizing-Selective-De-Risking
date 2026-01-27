# ==============================================================================
# SCRIPT: 15_update_documentation.R
# PURPOSE: Automatically update README.md with the latest statistical results.
# ==============================================================================

library(readr)
library(stringr)
library(here)

# 1. Load Results
# ------------------------------------------------------------------------------
# High-Tech Results
if (file.exists(here("30_Report/strucchange_results.rds"))) {
  res_ht <- readRDS(here("30_Report/strucchange_results.rds"))
} else {
  stop("High-Tech results not found. Run 08_strucchange.R first.")
}

# Control Results
if (file.exists(here("30_Report/strucchange_control_results.rds"))) {
  res_ct <- readRDS(here("30_Report/strucchange_control_results.rds"))
} else {
  stop("Control results not found. Run 09_strucchange_control.R first.")
}

# 2. Format Statistics
# ------------------------------------------------------------------------------
fmt_f <- function(x) sprintf("%.2f", x)
fmt_p <- function(x) {
  if (x < 0.0001) return("< 0.0001")
  return(sprintf("%.4f", x))
}

# Values for High-Tech
ht_f <- fmt_f(res_ht$chow_statistic)
ht_p <- fmt_p(res_ht$chow_p_value)
break_date <- res_ht$break_date

# Values for Control
ct_f <- fmt_f(res_ct$chow_statistic)
ct_p <- fmt_p(res_ct$chow_p_value)

# Intensity Ratio (How much stronger is the break in High-Tech?)
ratio <- round(res_ht$chow_statistic / res_ct$chow_statistic, 0)

print(paste("Updating README with -> HT F:", ht_f, "| CT F:", ct_f, "| Date:", break_date))

# 3. Read README.md
# ------------------------------------------------------------------------------
readme_path <- here("README.md")
readme_lines <- read_lines(readme_path)

# 4. Perform Replacements (Regex)
# ------------------------------------------------------------------------------

# A. Update the Results Table
# Pattern: Starts with "| High-Tech (Strategic)"
line_ht_idx <- which(str_detect(readme_lines, "\\| High-Tech \\(Strategic\\)"))
if (length(line_ht_idx) > 0) {
  readme_lines[line_ht_idx] <- sprintf("| High-Tech (Strategic) | %s       | %s | Massive Break (Policy + Market) |", ht_f, ht_p)
}

# Pattern: Starts with "| Low-Tech (Control)"
line_ct_idx <- which(str_detect(readme_lines, "\\| Low-Tech \\(Control\\)"))
if (length(line_ct_idx) > 0) {
  interp_ct <- if(res_ct$chow_p_value < 0.05) "Significant Break (General Volatility)" else "No Break (Stable Trend)"
  readme_lines[line_ct_idx] <- sprintf("| Low-Tech (Control)    | %s        | %s   | %s |", ct_f, ct_p, interp_ct)
}

# B. Update the Key Statistical Finding Bullet Points
# Pattern: "- **High-Tech & Strategic**: F ="
line_bull_ht <- which(str_detect(readme_lines, "- \\*\\*High-Tech & Strategic\\*\\*: F ="))
if (length(line_bull_ht) > 0) {
  readme_lines[line_bull_ht] <- sprintf("- **High-Tech & Strategic**: F = %s (p %s)", ht_f, ht_p)
}

# Pattern: "- **Traditional & Basic**: F ="
line_bull_ct <- which(str_detect(readme_lines, "- \\*\\*Traditional & Basic\\*\\*: F ="))
if (length(line_bull_ct) > 0) {
  readme_lines[line_bull_ct] <- sprintf("- **Traditional & Basic**: F = %s (p %s)", ct_f, ct_p)
}

# C. Update Intensity Ratio
# Pattern: "- **Intensity Ratio**: ~"
line_ratio <- which(str_detect(readme_lines, "- \\*\\*Intensity Ratio\\*\\*: ~"))
if (length(line_ratio) > 0) {
  readme_lines[line_ratio] <- sprintf("- **Intensity Ratio**: ~%sx stronger in strategic sectors", ratio)
}

# D. Update Interpretation Paragraph
# Pattern: "While strategic trade collapsed (F="
line_interp <- which(str_detect(readme_lines, "While strategic trade collapsed \\(F="))
if (length(line_interp) > 0) {
  # We replace the whole line to ensure consistency
  readme_lines[line_interp] <- sprintf("**Interpretation**: While strategic trade collapsed (F=%s), traditional trade showed significantly less structural change (F=%s). This confirms that \"De-risking\" was surgical, affecting only the targeted sectors while leaving general trade largely untouched.", ht_f, ct_f)
}

# E. Update Conclusion (Intensity)
line_concl <- which(str_detect(readme_lines, "The structural break in strategic goods is \\*\\*~"))
if (length(line_concl) > 0) {
  readme_lines[line_concl] <- sprintf("**Conclusion**: The structural break in strategic goods is **~%sx more intense** than in general trade,", ratio)
}

# 5. Write Back
# ------------------------------------------------------------------------------
write_lines(readme_lines, readme_path)
print("✅ README.md successfully updated with latest statistics.")
