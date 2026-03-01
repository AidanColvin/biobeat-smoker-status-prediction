## cross_validate/cv_rf.R
## given train data and response name
## return k-fold cv classification error for random forest

library(randomForest) # randomForest

source("src/cross_validate/cv_utils.R")

K_FOLDS <- 10

#' given a dataframe, response name, and number of trees
#' return mean k-fold cv classification error for random forest
cv_rf <- function(df, response, k = K_FOLDS, ntree = 500) {
  df[[response]] <- as.factor(df[[response]])
  folds  <- make_folds(nrow(df), k)
  errors <- rep(0, k)

  for (i in 1:k) {
    fit       <- randomForest(as.formula(paste(response, "~ .")), data = df[folds != i, ], ntree = ntree)
    preds     <- predict(fit, df[folds == i, ])
    errors[i] <- classification_error(preds, df[folds == i, ][[response]])
  }

  cv_error <- mean(errors)
  message("random forest cv error: ", round(cv_error, 4))
  cv_error
}