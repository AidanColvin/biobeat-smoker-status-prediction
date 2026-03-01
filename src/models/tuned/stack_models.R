library(xgboost)
library(randomForest)
library(glmnet)
source("src/models/tuned/xgboost_model.R")

#' given train data and response name
#' return stacked ensemble using out-of-fold predictions as meta features
#' level 1: xgboost + random forest
#' level 2: logistic regression on oof predictions
run_stacking <- function(df, response, k = 10, ntree = 300, xgb_rounds = 150) {
  df[[response]] <- as.factor(df[[response]])
  set.seed(42)
  n       <- nrow(df)
  folds   <- sample(rep(1:k, length.out = n))
  oof_xgb <- rep(0, n)
  oof_rf  <- rep(0, n)

  message("building out-of-fold predictions for stacking...")
  for (i in 1:k) {
    tr    <- df[folds != i, ]
    val   <- df[folds == i, ]
    x_tr  <- as.matrix(tr[,  names(tr)  != response])
    x_val <- as.matrix(val[, names(val) != response])
    y_tr  <- as.numeric(as.character(tr[[response]]))
    xgb_fit <- xgb.train(
      params  = list(objective = "binary:logistic", eval_metric = "auc",
                     eta = 0.05, max_depth = 4, subsample = 0.8,
                     colsample_bytree = 0.8, min_child_weight = 5),
      data    = xgb.DMatrix(x_tr, label = y_tr),
      nrounds = xgb_rounds, verbose = 0
    )
    oof_xgb[folds == i] <- predict(xgb_fit, xgb.DMatrix(x_val))
    rf_fit  <- randomForest(as.formula(paste(response, "~ .")), data = tr, ntree = ntree)
    oof_rf[folds == i]  <- predict(rf_fit, val, type = "prob")[, 2]
    message("  fold ", i, "/", k, " done")
  }

  meta_train <- data.frame(xgb = oof_xgb, rf = oof_rf, y = as.numeric(as.character(df[[response]])))
  message("fitting meta learner (logistic)...")
  meta_fit <- glm(y ~ xgb + rf, data = meta_train, family = binomial)

  message("fitting final level-1 models on full train...")
  x_full <- as.matrix(df[, names(df) != response])
  y_full <- as.numeric(as.character(df[[response]]))
  xgb_final <- xgb.train(
    params  = list(objective = "binary:logistic", eval_metric = "auc",
                   eta = 0.05, max_depth = 4, subsample = 0.8,
                   colsample_bytree = 0.8, min_child_weight = 5),
    data    = xgb.DMatrix(x_full, label = y_full),
    nrounds = xgb_rounds, verbose = 0
  )
  rf_final <- randomForest(as.formula(paste(response, "~ .")), data = df, ntree = ntree)
  list(xgb = xgb_final, rf = rf_final, meta = meta_fit)
}

#' given stacked model and test data
#' return predicted probabilities from meta learner
predict_stack <- function(stack, test, response) {
  x     <- as.matrix(test[, names(test) != response])
  p_xgb <- predict(stack$xgb, xgb.DMatrix(x))
  p_rf  <- predict(stack$rf,  test, type = "prob")[, 2]
  predict(stack$meta, newdata = data.frame(xgb = p_xgb, rf = p_rf), type = "response")
}
