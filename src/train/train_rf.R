## train/train_rf.R
## given train data and response name
## return fitted random forest model on full training set

library(randomForest) # randomForest

#' given a dataframe, response name, and number of trees
#' return fitted random forest model with importance enabled
train_rf <- function(df, response, ntree = 500) {
  df[[response]] <- as.factor(df[[response]])
  randomForest(as.formula(paste(response, "~ .")), data = df, ntree = ntree, importance = TRUE)
}