## cross_validate/cv_svm.R
## given train data and response name
## return k-fold cv classification error for svm

library(e1071) # svm

source("src/cross_validate/cv_utils.R")

K_FOLDS <- 10

#' given a dataframe and response name
#' return mean k-fold cv classification error for svm radial kernel
cv_svm <- function(df, response, k = K_FOLDS) {
  df[[response]] <- as.factor(df[[response]])
  folds  <- make_folds(nrow(df), k)
  errors <- rep(0, k)

  for (i in 1:k) {
    fit       <- svm(as.formula(paste(response, "~ .")), data = df[folds != i, ], kernel = "radial")
    preds     <- predict(fit, df[folds == i, ])
    errors[i] <- classification_error(preds, df[folds == i, ][[response]])
  }

  cv_error <- mean(errors)
  message("svm cv error: ", round(cv_error, 4))
  cv_error
}