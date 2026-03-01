library(xgboost)
source("src/models/tuned/xgboost_model.R")

#' given a dataframe and response name
#' return best xgboost model from grid search over depth and eta
#' searches max_depth in 4,6,8 and eta in 0.01,0.05
deep_tune_xgboost <- function(df, response, k = 10) {
  dtrain <- make_xgb_matrix(df, response)
  grid <- expand.grid(
    max_depth = c(4, 6, 8),
    eta       = c(0.01, 0.05),
    subsample = c(0.7, 0.9),
    colsample = c(0.7, 0.9)
  )
  best_auc    <- 0
  best_params <- NULL
  best_rounds <- 300

  for (i in seq_len(nrow(grid))) {
    params <- list(
      objective        = "binary:logistic",
      eval_metric      = "auc",
      eta              = grid$eta[i],
      max_depth        = grid$max_depth[i],
      subsample        = grid$subsample[i],
      colsample_bytree = grid$colsample[i],
      min_child_weight = 5,
      gamma            = 0.1
    )
    cv <- xgb.cv(params = params, data = dtrain, nrounds = 500,
                 nfold = k, early_stopping_rounds = 30,
                 verbose = 0, maximize = TRUE)
    auc <- max(cv$evaluation_log$test_auc_mean)
    rounds <- which.max(cv$evaluation_log$test_auc_mean)
    message(sprintf("  depth=%d eta=%.2f sub=%.1f col=%.1f -> auc=%.4f rounds=%d",
                    grid$max_depth[i], grid$eta[i], grid$subsample[i], grid$colsample[i], auc, rounds))
    if (auc > best_auc) {
      best_auc    <- auc
      best_params <- params
      best_rounds <- rounds
    }
  }
  message("best cv auc: ", round(best_auc, 4), " — fitting final model")
  xgb.train(params = best_params, data = dtrain, nrounds = best_rounds, verbose = 0)
}
