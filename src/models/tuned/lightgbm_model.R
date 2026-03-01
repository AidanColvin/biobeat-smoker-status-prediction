## models/tuned/lightgbm_model.R
## given train data and response name
## return cv-tuned lightgbm model
## lightgbm is faster than xgboost and often achieves higher auc on clinical data

library(lightgbm)

#' given a dataframe and response name
#' return fitted lightgbm model with cv-tuned nrounds
tune_lightgbm <- function(df, response, k = 10, max_rounds = 500) {
  x <- as.matrix(df[, names(df) != response])
  y <- as.numeric(df[[response]])
  dtrain <- lgb.Dataset(x, label = y)
  params <- list(
    objective        = "binary",
    metric           = "auc",
    learning_rate    = 0.05,
    num_leaves       = 63,
    max_depth        = -1,
    min_data_in_leaf = 20,
    feature_fraction = 0.8,
    bagging_fraction = 0.8,
    bagging_freq     = 5,
    verbose          = -1
  )
  message("running lightgbm cv...")
  cv_result <- lgb.cv(
    params   = params,
    data     = dtrain,
    nrounds  = max_rounds,
    nfold    = k,
    early_stopping_rounds = 20,
    verbose  = -1
  )
  best_rounds <- cv_result$best_iter
  message("lightgbm best rounds: ", best_rounds)
  lgb.train(params = params, data = dtrain, nrounds = best_rounds, verbose = -1)
}

#' given a fitted lightgbm model and test dataframe
#' return predicted probabilities
predict_lightgbm <- function(fit, test, response) {
  x <- as.matrix(test[, names(test) != response])
  predict(fit, x)
}
