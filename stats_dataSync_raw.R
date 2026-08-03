library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)
library(dplyr) 
library(ggplot2)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/statsTableSync_noOutliers.csv")
head(DATA)

# Define dependent variable of interest
var <- DATA$Power

DATA$Game <- factor(DATA$Game, levels = c("RW", "FB")) 
DATA$Movement <- factor(DATA$Movement, levels = c("Tap", "Walk")) 
DATA$Load <- factor(DATA$Load, levels = c("ST", "DT"))
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

# Specify the exact order you want on the x-axis
condition_order <- c(
  "preTapST_RW", "postTapST_RW",
  "preTapDT_RW", "postTapDT_RW",
  "preWalkST_RW", "postWalkST_RW",
  "preWalkDT_RW", "postWalkDT_RW",
  "preTapST_FB", "postTapST_FB",
  "preTapDT_FB", "postTapDT_FB",
  "preWalkST_FB", "postWalkST_FB",
  "preWalkDT_FB", "postWalkDT_FB"
)

data_plot$condition <- factor(data_plot$condition, levels = condition_order)

# Scatter plot with all data points
ggplot(data_plot, aes(x = condition, y = var, colour = Time)) +
  geom_boxplot(outlier.shape = NA, fill = "grey95", colour = "black") +
  geom_jitter(width = 0.15, height = 0, size = 2, alpha = 0.7) +
  scale_colour_manual(values = c(pre = "blue", post = "orange")) +
  labs(x = "Condition", y = "Phase Coupling (logit)", colour = "Time") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, hjust = 1),
    panel.grid.major.x = element_blank()
  )

emm_Game <- emmeans(model, ~ Game)
summary(emm_Game)

emm_Mvt <- emmeans(model, ~ Movement)
summary(emm_Mvt)

emm_Load <- emmeans(model, ~ Load)
summary(emm_Load)

emm_Time <- emmeans(model, ~ Time)
summary(emm_Time)

## Compute post hoc for Movement * Game interaction
contrast_mvtGame <- list(
  "Tap RW - Tap FB"   = c(1, 0, -1, 0),  
  "Walk RW - Walk FB" = c(0, 1, 0, -1),
  "Tap RW - Walk RW"  = c(1, -1, 0, 0),
  "Tap FB - Walk FB"  = c(0, 0, 1, -1)
)
emm_mvtGame <- emmeans(model, ~ Movement * Game)
summary(emm_mvtGame)

# Run targeted comparisons with Bonferroni correction
contrast(emm_mvtGame, contrast_mvtGame, adjust = "bonferroni")

## Compute post hoc for Movement * Load interaction
contrast_mvtLoad <- list(
  "Tap ST - Tap DT"   = c(1, 0, -1, 0),  
  "Walk ST - Walk DT" = c(0, 1, 0, -1),
  "Tap ST - Walk ST"  = c(1, -1, 0, 0),
  "Tap DT - Walk DT"  = c(0, 0, 1, -1)
)
emm_mvtLoad <- emmeans(model, ~ Movement * Load)
summary(emm_mvtLoad)

# Run targeted comparisons with Bonferroni correction
contrast(emm_mvtLoad, contrast_mvtLoad, adjust = "bonferroni")

## Compute post hoc for Time * Load interaction
contrast_timeLoad <- list(
  "pre ST - post ST"   = c(1, -1, 0, 0),  
  "pre DT - post DT"   = c(0, 0, 1, -1),
  "pre ST - pre DT"    = c(1, 0, -1, 0),
  "post ST - post DT"  = c(0, 1, 0, -1)
)
emm_timeLoad <- emmeans(model, ~ Time * Load)
summary(emm_timeLoad)

# Run targeted comparisons with Bonferroni correction
contrast(emm_timeLoad, contrast_timeLoad, adjust = "bonferroni")

## Compute post hoc for Game * Load * Movement interaction
contrast_gameLoadMvt <- list(
  "RW ST Tap - FB ST Tap"   = c(1, -1, 0, 0, 0, 0, 0, 0),  
  "RW DT Tap - FB DT Tap"   = c(0, 0, 1, -1, 0, 0, 0, 0),
  "RW ST Walk - FB ST Walk" = c(0, 0, 0, 0, 1, -1, 0, 0),
  "RW DT Walk - FB DT Walk" = c(0, 0, 0, 0, 0, 0, 1, -1)
)
emm_gameLoadMvt <- emmeans(model, ~ Game * Load * Movement)
summary(emm_gameLoadMvt)

# Run targeted comparisons with Bonferroni correction
contrast(emm_gameLoadMvt, contrast_gameLoadMvt, adjust = "bonferroni")
