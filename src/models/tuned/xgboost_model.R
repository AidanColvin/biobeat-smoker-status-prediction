## models/tuned/xgboost_model.R
## given train data and response name
## return cv-tuned xgboost model
## xgboost uses gradient boosting — consistently top performer on tabular clinical data

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
#' uses eta=0.1, max_depth=6, subsample=0.8 as strong defaults for clinical data
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
    params   = params,
    data     = dtrain,
    nrounds  = max_rounds,
    nfold    = k,
    early_stopping_rounds = 20,
    verbose  = 0
  )
  best_rounds <- cv_result$best_iteration
  message("xgboost best nrounds: ", best_rounds)
  xgb.train(params = params, data = dtrain, nrounds = best_rounds, verbose = 0)
}

#' given a fitted xgboost model and test dataframe
#' return predicted probabilities
predict_xgboost <- function(fit, test, response) {
  x <- as.matrix(test[, names(test) != response])
  predict(fit, xgb.DMatrix(data = x))
}
