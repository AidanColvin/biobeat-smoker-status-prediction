library(xgboost)

#' given a dataframe and response name
#' return xgb.DMatrix object
make_xgb_matrix <- function(df, response) {
  x <- as.matrix(df[, names(df) != response])
  y <- as.numeric(df[[response]])
  xgb.DMatrix(data = x, label = y)
}

#' given a dataframe and response name
#' return cv-tuned xgboost model using 10-fold cv to find best nrounds
tune_xgboost <- function(df, response, max_rounds = 300, k = 10) {
  dtrain <- make_xgb_matrix(df, response)
  params <- list(
    objective        = "binary:logistic",
    eval_metric      = "auc",
    eta              = 0.05,
    max_depth        = 6,
    subsample        = 0.8,
    colsample_bytree = 0.8,
    min_child_weight = 5
  )
  message("running xgboost cv to find best nrounds...")
  cv_result <- xgb.cv(
    params                = params,
    data                  = dtrain,
    nrounds               = max_rounds,
    nfold                 = k,
    early_stopping_rounds = 20,
    verbose               = 0,
    maximize              = TRUE
  )
  best_rounds <- which.max(cv_result$evaluation_log$test_auc_mean)
  if (is.null(best_rounds) || length(best_rounds) == 0 || best_rounds == 0) {
    best_rounds <- max_rounds
  }
  message("xgboost best nrounds: ", best_rounds)
  xgb.train(params = params, data = dtrain, nrounds = best_rounds, verbose = 0)
}

#' given a fitted xgboost model and test dataframe
#' return predicted probabilities
predict_xgboost <- function(fit, test, response) {
  x <- as.matrix(test[, names(test) != response])
  predict(fit, xgb.DMatrix(data = x))
}
