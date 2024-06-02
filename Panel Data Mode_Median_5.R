# Panel Data Model
# a) estimate model with ﬁxed and random eﬀects estimators, check whether individual eﬀects are signiﬁcant;
# b) perform the Hausman speciﬁcation test;
# c) general-to-speciﬁc method to variables selection;
# d) at least one interaction between variables;
# e) diagnostic tests for the ﬁnal model;
# f ) interpret the ﬁnal model parameters;
# g) present the general model, and the ﬁnal model (the speciﬁc model) in one quality table. If there is space, at least one intermediate model might be presented.




# Load the package---------------
# install.packages("tseries")
library(tseries)
library(MASS)
library(sandwich)
library(zoo)
library(car)
library(lmtest)
library(Formula)
library(plm)
library(stargazer)
library(dplyr)


# Read the data---------------
data <- read.csv("data.csv")
head(data)
str(data)

# preparation for the model----------
# Convert variables to factor if they are categorical
data$country <- as.factor(data$country)
data$year <- as.factor(data$year)

# Add a variable Finland or not 
data <- data %>%
  mutate(is_finland = ifelse(country == "FIN", 1, 0))

# Create Interactiion Term----------------
data <- data %>%
  mutate(finland_ses_interaction = is_finland * median_ses)

#  Estimate both fixed effect and random effect models with median---------------
# Fixed Effects Model including the interaction term
fe_model <- plm(median_score ~ median_ses + median_interest + finland_ses_interaction, data = data,index = c("country", "year") , model = "within")
fe_model_1 <- plm(median_score ~ median_ses + median_interest, data = data,index = c("country", "year") , model = "within")

# Random Effects Model including the interaction term
re_model <- plm(median_score ~ median_ses + median_interest + finland_ses_interaction, data = data,index = c("country", "year"), model = "random")
re_model_1 <- plm(median_score ~ median_ses + median_interest , data = data,index = c("country", "year"), model = "random")
# Summary of models
summary(fe_model)
summary(re_model)
summary(fe_model_1)
summary(re_model_1)

# Hausman Specification Test-----------
hausman_test <- phtest(fe_model, re_model)
print(hausman_test)
# the p-value is big (typically >0.05), it suggests we cannot reject the null hypothesis, favoring the random effects model.

hausman_test_1 <- phtest(fe_model_1, re_model_1)
print(hausman_test_1)
# the p-value is small (typically < 0.05), it suggests we can reject the null hypothesis, favoring the fixed effects model.

# OLS model---------------
ols_median <- lm(median_score ~ median_ses + median_interest + finland_ses_interaction, data = data)
summary(ols_median)
ols_median_1 <- lm(median_score ~ median_ses + median_interest, data = data)
summary(ols_median_1)

# Check the linear form of the model with reset test
reset <- resettest(ols_median, power=2:3, type="fitted")
reset
reset_1 <- resettest(ols_median_1, power=2:3, type="fitted")
reset_1
# P-value  is great cannot reject H0. So, it meets the first assumption of OLS--> linear format

# Check the homoscedaticity 
# H0: homoscedasticity
# H1: heteroscedasticity
# Breusch's and Pagan's test
bp <- bptest(ols_median, studentize=TRUE)
bp

bp_1 <- bptest(ols_median_1, studentize=TRUE)
bp_1
# P- value >0.05, so favoring H0. It meets the assumption of homoscedaticity of error for OLS


# Check if it is no autocorrelation with Breusch-Godfrey Test
bg <- bgtest(ols_median, order = 1)  
bg
bg_1 <- bgtest(ols_median_1, order = 1)  
bg_1
# P_value < 0.05, so reject h0. It doesn't meet the condition of OLS. 


# check if the residuals are normally distributed
jb <- jarque.bera.test(ols_median$residuals)
jb_1 <- jarque.bera.test(ols_median_1$residuals)
# P- value > 0.05, so we cannot reject H0. Residuals are normally distributed. 

# Check if should reduce to OLS---------------
# For model_1, we need to use pF test to compare OLS and fixed effects model
pFtest(fe_model_1, ols_median_1)
# p-value < 0.05: This result suggests that there is a statistically significant difference between the two models.So we should use fixed effects model for model_1

# Pooled OLS Model
pooled_model <- plm(median_score ~ median_ses + median_interest + finland_ses_interaction, data = data, model = "pooling")
pooltest(re_model, pooled_model)


# For both of the median model, the OLS model cannot be applied to because of the autocorrelation
# For the model with interaction part with Finland, it should use random effects model
# For the model without interaction part, it should use the fixed effects model

# summarize in one table ------------------
library(stargazer)
# table for model with interaction which should use random effects model
stargazer(fe_model, re_model, type = "text") 
# table for model without interaction which should use fixed effects model
stargazer(fe_model_1, re_model_1, type = "text") 
