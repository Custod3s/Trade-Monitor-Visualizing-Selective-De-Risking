# scripts/00_style.R
library(ggplot2)

# --- 1. The Corporate Color Palette ---
# Professional, color-blind friendly, and distinct
esc_colors <- c(
  "High-Tech & Strategic"   = "#005f73",  # Deep Teal (Strategic)
  "Traditional & Basic" = "#94a3b8",  # Cool Grey (Background/Control)
  "Financial Exposure (BIS)" = "#b91c1c"   # Bold Red (Warning/Capital Flight)
)

# --- 2. The Custom Theme (Zero Dependencies) ---
# Replicates the clean look of theme_ipsum using standard ggplot2
theme_esc <- function() {
  theme_minimal(base_size = 12, base_family = "serif") +
    theme(
      # Typography
      plot.title    = element_text(face = "bold", size = 16, color = "#1e293b", hjust = 0),
      plot.subtitle = element_text(size = 11, color = "#64748b", margin = margin(b = 15), hjust = 0),
      plot.caption  = element_text(size = 8, color = "#94a3b8", hjust = 1, margin = margin(t = 10)),
      
      # Grid Lines (Keep Y for reading values, remove X for clean look)
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_line(color = "#e2e8f0", linewidth = 0.5),
      panel.grid.minor.y = element_blank(),
      
      # Axes
      axis.title    = element_text(size = 10, face = "bold", color = "#475569"),
      axis.text     = element_text(size = 10, color = "#64748b"),
      axis.line.x   = element_line(color = "#cbd5e1"), # Add a subtle baseline
      
      # Legend (Top Left for quick scanning)
      legend.position = "top",
      legend.justification = "left",
      legend.title = element_blank(),
      legend.text = element_text(size = 10, color = "#475569"),
      
      # Background
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    )
}
