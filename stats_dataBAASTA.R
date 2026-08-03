library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectTraining/Results/All/statsTableBAASTA_noOutliers.csv")
head(DATA)

DATA$Game <- factor(DATA$Game, levels = c("RW", "FB")) 
DATA$Time <- factor(DATA$Time, levels = c("Pre", "Post"))

# Define the specific contrasts for posthocs
contrasts(DATA$Game) <- contr.sum
contrasts(DATA$Time) <- contr.sum

# Define dependent variable of interest
var <- DATA$syncAccuracy

# Define model
model <- lmer(var ~ 1 + Game + Time + Time:Game + (1|ID), data = DATA)
summary(model)

Anova(model, type=3, test.statistic = "F")
eta_squared(model, partial = TRUE)

## Plot data
# Create a condition label
data_plot <- DATA %>%
  mutate(condition = paste0(Time, "_", Game))

# Specify the exact order you want on the x-axis
condition_order <- c(
  "Pre_RW", "Post_RW",
  "Pre_FB", "Post_FB"
)

data_plot$condition <- factor(data_plot$condition, levels = condition_order)

# Scatter plot with all data points
ggplot(data_plot, aes(x = condition, y = var, colour = Time)) +
  geom_boxplot(outlier.shape = NA, fill = "grey95", colour = "black") +
  geom_jitter(width = 0.15, height = 0, size = 2, alpha = 0.7) +
  scale_colour_manual(values = c(Pre = "blue", Post = "orange")) +
  labs(x = "Condition", y = "Sync Consistency (logit)", colour = "Time") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, hjust = 1),
    panel.grid.major.x = element_blank()
  )
