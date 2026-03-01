## models/tuned/tune_rf.R
## given train data and response name
## return tuned random forest using 10-fold cv over mtry and ntree
## mtry controls features per split — key hyperparameter for rf

library(randomForest)
source("src/cross_validate/cv_utils.R")

#' given a dataframe, response name, and mtry value
#' return 10-fold cv classification error for random forest at that mtry
cv_rf_mtry <- function(df, response, mtry_val, k = 10, ntree = 300) {
  df[[response]] <- as.factor(df[[response]])
  folds  <- make_folds(nrow(df), k)
  errors <- rep(0, k)
  for (i in 1:k) {
    fit       <- randomForest(as.formula(paste(response, "~ .")), data = df[folds != i, ], ntree = ntree, mtry = mtry_val)
    preds     <- predict(fit, df[folds == i, ])
    errors[i] <- mean(preds != df[folds == i, ][[response]])
  }
  mean(errors)
}

#' given a dataframe and response name
#' return fitted random forest with best mtry from cv search
#' searches mtry in range 2 to sqrt(p)*2
tune_rf <- function(df, response, ntree = 500, k = 10) {
  df[[response]] <- as.factor(df[[response]])
  p         <- ncol(df) - 1
  mtry_vals <- unique(c(2, floor(sqrt(p)), floor(sqrt(p)) + 2, floor(sqrt(p)) + 4, p %/% 3))
  message("tuning mtry over: ", paste(mtry_vals, collapse = ", "))
  errors <- sapply(mtry_vals, function(m) {
    message("  cv mtry=", m, "...")
    cv_rf_mtry(df, response, m, k = k, ntree = 200)
  })
  best_mtry <- mtry_vals[which.min(errors)]
  message("best mtry: ", best_mtry, " (cv error: ", round(min(errors), 4), ")")
  randomForest(as.formula(paste(response, "~ .")), data = df, ntree = ntree, mtry = best_mtry, importance = TRUE)
}
