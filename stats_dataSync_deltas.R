library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/statsTableSync_noOutliers.csv")
head(DATA)

DATA$Game <- factor(DATA$Game, levels = c("RW", "FB")) 
DATA$Movement <- factor(DATA$Movement, levels = c("Tap", "Walk")) 
DATA$Load <- factor(DATA$Load, levels = c("ST", "DT"))

# Define the specific contrasts for posthocs
contrasts(DATA$Game) <- contr.sum
contrasts(DATA$Movement) <- contr.sum
contrasts(DATA$Load) <- contr.sum

# Define model
model <- lmer(stabilityIndex ~ 1 + Game + Movement + Load + Movement:Game + Movement:Load + Load:Game + Movement:Load:Game + (1|ID), data = DATA)
summary(model)

Anova(model, type=3, test.statistic = "F")
eta_squared(model, partial = TRUE)

emm_Game <- emmeans(model, ~ Game)
summary(emm_Game)

emm_Mvt <- emmeans(model, ~ Movement)
summary(emm_Mvt)

emm_Load <- emmeans(model, ~ Load)
summary(emm_Load)

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