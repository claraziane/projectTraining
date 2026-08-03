library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/statsTableBehav_noOutliers.csv")
head(DATA)

# Define dependent variable of interest
var <- DATA$IMI

DATA$Game <- factor(DATA$Game, levels = c("RW", "FB")) 
DATA$Movement <- factor(DATA$Movement, levels = c("Tap", "Walk")) 
DATA$Load <- factor(DATA$Load, levels = c("SP", "ST", "DT"))
DATA$Time <- factor(DATA$Time, levels = c("pre", "post"))

# Define the specific contrasts for posthocs
contrasts(DATA$Game) <- contr.sum
contrasts(DATA$Movement) <- contr.sum
contrasts(DATA$Load) <- contr.sum
contrasts(DATA$Time) <- contr.sum

# Define model
model <- lmer(var ~ 1 + Game + Movement + Load + Time + Movement:Game + Movement:Load + Load:Game + Time:Game + Time:Movement + Time:Load + Movement:Load:Game + Movement:Load:Time + Movement:Game:Time + Load:Game:Time + Movement:Load:Game:Time + (1|ID), data = DATA)
summary(model)

Anova(model, type=3, test.statistic = "F")
eta_squared(model, partial = TRUE)

## Plot data
# Create a condition label
data_plot <- DATA %>%
  mutate(condition = paste0(Time, Movement, Load, "_", Game))

# Specify condition order for the x-axis
condition_order <- c(
  "preTapSP_RW", "postTapSP_RW",
  "preTapST_RW", "postTapST_RW",
  "preTapDT_RW", "postTapDT_RW",
  "preWalkSP_RW", "postWalkSP_RW",
  "preWalkST_RW", "postWalkST_RW",
  "preWalkDT_RW", "postWalkDT_RW",
  "preTapSP_FB", "postTapSP_FB",
  "preTapST_FB", "postTapST_FB",
  "preTapDT_FB", "postTapDT_FB",
  "preWalkSP_FB", "postWalkSP_FB",
  "preWalkST_FB", "postWalkST_FB",
  "preWalkDT_FB", "postWalkDT_FB"
)

data_plot$condition <- factor(data_plot$condition, levels = condition_order)

# Compute means for each condition
data_means <- data_plot %>%
  group_by(condition, Time) %>%
  summarise(mean_var = mean(var, na.rm = TRUE), .groups = "drop")

# Plot
ggplot(data_plot, aes(x = condition, y = var, colour = Time)) +
  
  # Individual data points
  geom_jitter(width = 0.15, height = 0, size = 2, alpha = 0.7) +
  
  # Mean points (larger, black outline, coloured fill)
  geom_point(data = data_means,
             aes(x = condition, y = mean_var, fill = Time),
             shape = 21,        # allows separate fill and outline
             size = 3.5,
             stroke = 1.2,
             colour = "black") +
  
  # Colours
  scale_colour_manual(values = c(pre = "blue", post = "orange")) +
  scale_fill_manual(values = c(pre = "blue", post = "orange")) +
  
  labs(x = "Condition", y = "CV") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, hjust = 1),
    panel.grid.major.x = element_blank()
  )

emm_Mvt <- emmeans(model, ~ Movement)
summary(emm_Mvt)

emm_Time <- emmeans(model, ~ Time)
summary(emm_Time)


## Compute post hoc for Load effect
contrast_Load <- list(
  "SP - ST" = c(1, -1, 0),  
  "SP - DT" = c(1, 0, -1),
  "ST - DT" = c(0, 1, -1)
)
emm_Load <- emmeans(model, ~ Load)
summary(emm_Load)

# Run targeted comparisons with Bonferroni correction
contrast(emm_Load, contrast_Load, adjust = "bonferroni")

## Compute post hoc for Movement * Load interaction
emm_mvtLoad <- emmeans(model, ~ Movement * Load)
summary(emm_mvtLoad)

contrast_mvtLoad <- list(
  "Tap SP - Tap ST"   = c(1, 0, -1, 0, 0, 0),  
  "Walk SP - Walk ST" = c(0, 1, 0, -1, 0, 0),
  "Tap SP - Walk SP"  = c(1, -1, 0, 0, 0, 0),
  "Tap ST - Walk ST"  = c(0, 0, 1, -1, 0, 0),
  "Tap SP - Tap DT"  = c(1, 0, 0, 0, -1, 0),
  "Tap ST - Tap DT"  = c(0, 0, 1, 0, -1, 0),
  "Walk SP - Walk DT"  = c(0, 1, 0, 0, 0, -1),
  "Walk ST - Walk DT"  = c(0, 0, 0, 1, 0, -1),
  "Tap DT - Walk DT"  = c(0, 0, 0, 0, 1, -1)
)

contrast(emm_mvtLoad, contrast_mvtLoad, adjust = "bonferroni") # Run targeted comparisons with Bonferroni correction

## Compute post hoc for Movement * Time interaction
emm_mvtTime <- emmeans(model, ~ Movement * Time)
summary(emm_mvtTime)

contrast_mvtTime <- list(
  "Tap pre - Tap post"   = c(1, 0, -1, 0),  
  "Walk pre - Walk post" = c(0, 1, 0, -1),
  "Tap pre - Walk pre"   = c(1, -1, 0, 0),
  "Tap post - Walk post"  = c(0, 0, 1, -1)
)

contrast(emm_mvtTime, contrast_mvtTime, adjust = "bonferroni") # Run targeted comparisons with Bonferroni correction