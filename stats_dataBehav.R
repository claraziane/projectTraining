library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/statsTableBehav_noOutliers.csv")
head(DATA)

DATA$Game <- factor(DATA$Game, levels = c("RW", "FB")) 
DATA$Movement <- factor(DATA$Movement, levels = c("Tap", "Walk")) 
DATA$Load <- factor(DATA$Load, levels = c("SP", "ST", "DT"))

# Define the specific contrasts for posthocs
contrasts(DATA$Game) <- contr.sum
contrasts(DATA$Movement) <- contr.sum
contrasts(DATA$Load) <- contr.sum

# Define model
model <- lmer(IMI ~ 1 + Game + Movement + Load + Movement:Game + Movement:Load + Load:Game + Movement:Load:Game + (1|ID), data = DATA)
summary(model)

Anova(model, type=3, test.statistic = "F")
eta_squared(model, partial = TRUE)

emm_Mvt <- emmeans(model, ~ Movement)
summary(emm_Mvt)

## Compute post hoc for Movement * Load interaction
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
emm_mvtLoad <- emmeans(model, ~ Movement * Load)
summary(emm_mvtLoad)

# Run targeted comparisons with Bonferroni correction
contrast(emm_mvtLoad, contrast_mvtLoad, adjust = "bonferroni")