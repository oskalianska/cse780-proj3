rm(list=ls())

#install.packages("ggcorrplot")

library(rsample)      # data splitting 
library(randomForest) # basic implementation
library(ranger)       # a faster implementation of randomForest
library(caret)        # an aggregator package for performing many machine learning models
library(h2o)          # an extremely fast java-based platform
library(tree)
library(dplyr)       # data wrangling
library(rpart)       # performing regression trees
library(rpart.plot)  # plotting regression trees
library(ipred)       # bagging
library(gbm)
library(ggplot2)
library(GGally)
library(ggcorrplot)
library(list.plot)


# Create training (80%) and test (20%) sets for the data.
set.seed(1234)
split <- initial_split(AmesHousing::make_ames(), prop = .8)
train <- training(split)
test  <- testing(split)

#ggpairs(train, cardinality_threshold = 29)

glimpse(train)

# Correlation Matrix
cordata = train[,c(3,4,19,20,26,34,36:38,43:52,54,56,60,61,65:70,74:76,79:81)]
corr <- round(cor(cordata), 1)
corr

# Correlation Plot
ggcorrplot(corr, hc.order = TRUE, type = "lower", lab = TRUE, lab_size = 3, method="circle", colors = c("blue", "white", "red"), outline.color = "gray", show.legend = TRUE, show.diag = FALSE, title="Correlogram of variables")

# Regression Trees
decisionTrees <- rpart(
  formula = Sale_Price ~ .,
  data    = train,
  method  = "anova")

#summary(decisionTrees)

rpart.plot(decisionTrees)

# Bagging 

# train bagged model
bagged <- bagging(formula = Sale_Price ~ ., data = train)

bagged

pred <- predict(bagged, test)
RMSE(pred, test$Sale_Price)

# Random forest

# for reproduciblity
set.seed(1234)

# default RF model
randomForest <- randomForest(formula = Sale_Price ~ ., data = train)

randomForest
plot(randomForest)

pred_randomForest <- predict(randomForest, test)
head(pred_randomForest)

RMSE(pred_randomForest, test$Sale_Price)

# variable importance
importance(randomForest)

varImpPlot(randomForest)

# boosting

set.seed(1234)

# train GBM model, shrinkage = 0.01
boosting1 <- gbm(
  formula = Sale_Price ~ .,
  distribution = "gaussian",
  data = train,
  n.trees = 10000,
  interaction.depth = 1,
  shrinkage = 0.01,
  cv.folds = 5,
  n.cores = NULL, # will use all cores by default
  verbose = FALSE
)  

print(boosting)

summary(boosting)

pred_boost <- predict(boosting, test)
#head(pred_boost)

RMSE(pred_boost, test$Sale_Price)

# train GBM model, shrinkage = 0.001
boosting1 <- gbm(
  formula = Sale_Price ~ .,
  distribution = "gaussian",
  data = train,
  n.trees = 10000,
  interaction.depth = 1,
  shrinkage = 0.001,
  cv.folds = 5,
  n.cores = NULL, # will use all cores by default
  verbose = FALSE
)  

pred_boost1 <- predict(boosting1, test)

RMSE(pred_boost1, test$Sale_Price)
