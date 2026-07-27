library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/statsTableBAASTA.csv")
head(DATA)

DATA$Game <- factor(DATA$Game, levels = c("RW", "FB")) 

# Define the specific contrasts for posthocs
contrasts(DATA$Game) <- contr.sum

# Define model
model <- lmer(musicConsistency ~ 1 + Game + (1|ID), data = DATA)
summary(model)

Anova(model, type=3, test.statistic = "F")
eta_squared(model, partial = TRUE)
