library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)
library(dplyr) 
library(ggplot2)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/statsTable_gameOrderEffect_Walk_noOutliers.csv")
head(DATA)

# Define dependent variable of interest
var <- DATA$CV

DATA$Group <- factor(DATA$Group, levels = c("RW", "FB")) 
DATA$Day   <- factor(DATA$Day, levels = c("T1", "T2")) 
DATA$Time  <- factor(DATA$Time, levels = c("pre", "post"))
DATA$Load  <- factor(DATA$Load, levels = c("SP", "ST", "DT"))

# Define the specific contrasts for posthocs
contrasts(DATA$Group) <- contr.sum
contrasts(DATA$Day)   <- contr.sum
contrasts(DATA$Time)  <- contr.sum
contrasts(DATA$Load)  <- contr.sum

# Define model
model <- lmer(var ~ 1 + Group + Day + Time + Load + Group:Day + Group:Time + Group:Load + Day:Time + Day:Load + Time:Load + Group:Day:Time + Group:Day:Load + Group:Time:Load + Day:Time:Load + Group:Day:Time:Load + (1|ID), data = DATA)
summary(model)

Anova(model, type=3, test.statistic = "F")
eta_squared(model, partial = TRUE)

## Compute post hoc for Movement * Game interaction
emm_groupDay <- emmeans(model, ~ Group * Day)
summary(emm_groupDay)

contrast_groupDay <- list(
  "RW T1 - FB T1" = c(1, -1, 0, 0),  
  "RW T2 - FB T2" = c(0, 0, 1, -1),
  "RW T1 - RW T2" = c(1, 0, -1, 0),
  "FB T1 - FB T2" = c(0, 1, 0, -1)
)

# Run targeted comparisons with Bonferroni correction
contrast(emm_groupDay, contrast_groupDay, adjust = "bonferroni")
