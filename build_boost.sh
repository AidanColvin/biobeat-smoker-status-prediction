#!/bin/bash
set -e

mkdir -p src/models/tuned
mkdir -p tests/models/tuned

cat > src/models/tuned/remove_id.R << 'REOF'
## models/tuned/remove_id.R
## given a dataframe
## return dataframe with id column removed
## id is a row identifier not a clinical predictor

#' given a dataframe
#' return dataframe without id column
remove_id <- function(df) {
  df[, names(df) != "id", drop = FALSE]
}
REOF

cat > src/models/tuned/tune_rf.R << 'REOF'
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
REOF

cat > src/models/tuned/xgboost_model.R << 'REOF'
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
REOF

cat > src/models/tuned/lightgbm_model.R << 'REOF'
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
REOF

cat > src/models/tuned/elastic_net_tuned.R << 'REOF'
## models/tuned/elastic_net_tuned.R
## given train data and response name
## return best elastic net by searching alpha in [0, 0.25, 0.5, 0.75, 1]
## searches both alpha and lambda via 10-fold cv

library(glmnet)

#' given a dataframe, response name, and alpha value
#' return 10-fold cv auc for elastic net at that alpha
cv_elastic_alpha <- function(df, response, alpha_val, k = 10) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = alpha_val, family = "binomial", type.measure = "auc", nfolds = k)
  max(cv_fit$cvm)
}

#' given a dataframe and response name
#' return fitted elastic net at best alpha from grid search
tune_elastic_net <- function(df, response, k = 10) {
  alphas  <- c(0, 0.25, 0.5, 0.75, 1)
  message("searching alpha: ", paste(alphas, collapse = ", "))
  aucs    <- sapply(alphas, function(a) {
    message("  cv alpha=", a, "...")
    cv_elastic_alpha(df, response, a, k)
  })
  best_alpha <- alphas[which.max(aucs)]
  message("best alpha: ", best_alpha, " (cv auc: ", round(max(aucs), 4), ")")
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = best_alpha, family = "binomial", type.measure = "auc", nfolds = k)
  list(model = cv_fit, lambda = cv_fit$lambda.min, alpha = best_alpha)
}
REOF

cat > src/models/tuned/run_tuned_models.R << 'REOF'
## models/tuned/run_tuned_models.R
## orchestrator: fits all tuned models on train_clean with id removed
## expects train_clean from load_data.R
## passes tuned_results to evaluate

source("src/models/tuned/remove_id.R")
source("src/models/tuned/tune_rf.R")
source("src/models/tuned/xgboost_model.R")
source("src/models/tuned/elastic_net_tuned.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

train_tuned <- remove_id(train_clean)
test_tuned  <- remove_id(test_clean)

message("fitting tuned random forest (10-fold cv mtry search)...")
rf_tuned <- tune_rf(train_tuned, RESPONSE, ntree = 500, k = 10)

message("fitting tuned elastic net (alpha grid search)...")
elastic_tuned <- tune_elastic_net(train_tuned, RESPONSE, k = 10)

message("fitting xgboost (10-fold cv nrounds)...")
xgb_fit <- tune_xgboost(train_tuned, RESPONSE, max_rounds = 300, k = 10)

tuned_results <- list(
  rf_tuned      = rf_tuned,
  elastic_tuned = elastic_tuned,
  xgb           = xgb_fit
)

message("tuned models ready: ", paste(names(tuned_results), collapse = ", "))
REOF

cat > src/evaluate/eval_tuned.R << 'REOF'
## evaluate/eval_tuned.R
## given tuned model results and test data
## return full evaluation including xgboost and tuned rf
## compares tuned vs baseline leaderboard

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")
source("src/models/tuned/xgboost_model.R")
source("src/models/tuned/remove_id.R")

#' given tuned rf model and test data
#' return eval result list
eval_tuned_rf <- function(fit, test, response, out_dir = "data/results") {
  probs   <- predict(fit, newdata = test, type = "prob")[, 2]
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth   <- as.numeric(test[[response]])
  metrics <- classification_metrics(truth, preds)
  auc_val <- compute_auc(truth, probs)
  cm      <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "rf_tuned", out_dir)
  print_confusion_matrix(cm, "rf_tuned")
  message("tuned rf auc: ", round(auc_val, 4))
  list(model = "rf_tuned", metrics = metrics, auc = auc_val, confusion_matrix = cm)
}

#' given tuned xgboost model and test data
#' return eval result list
eval_xgboost <- function(fit, test, response, out_dir = "data/results") {
  probs   <- predict_xgboost(fit, test, response)
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth   <- as.numeric(test[[response]])
  metrics <- classification_metrics(truth, preds)
  auc_val <- compute_auc(truth, probs)
  cm      <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "xgboost", out_dir)
  print_confusion_matrix(cm, "xgboost")
  message("xgboost auc: ", round(auc_val, 4))
  list(model = "xgboost", metrics = metrics, auc = auc_val, confusion_matrix = cm)
}

#' given tuned elastic net and test data
#' return eval result list
eval_tuned_elastic <- function(fit, test, response, out_dir = "data/results") {
  x       <- model.matrix(as.formula(paste(response, "~ .")), test)[, -1]
  probs   <- predict(fit$model, newx = x, s = fit$lambda, type = "response")[, 1]
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth   <- as.numeric(test[[response]])
  metrics <- classification_metrics(truth, preds)
  auc_val <- compute_auc(truth, probs)
  cm      <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "elastic_tuned", out_dir)
  print_confusion_matrix(cm, "elastic_tuned")
  message("tuned elastic net auc: ", round(auc_val, 4))
  list(model = "elastic_tuned", metrics = metrics, auc = auc_val, confusion_matrix = cm)
}
REOF

cat > src/evaluate/run_tuned_evaluate.R << 'REOF'
## evaluate/run_tuned_evaluate.R
## runs evaluation on all tuned models
## expects tuned_results from models/tuned/run_tuned_models.R
## saves updated leaderboard to data/results/tuned_comparison.csv

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")
source("src/evaluate/compare_models.R")
source("src/evaluate/eval_tuned.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

test_tuned <- remove_id(test_clean)

tuned_eval <- list(
  rf_tuned      = eval_tuned_rf(tuned_results$rf_tuned,      test_tuned, RESPONSE, OUT_DIR),
  xgboost       = eval_xgboost(tuned_results$xgb,            test_tuned, RESPONSE, OUT_DIR),
  elastic_tuned = eval_tuned_elastic(tuned_results$elastic_tuned, test_tuned, RESPONSE, OUT_DIR)
)

leaderboard <- compare_models(tuned_eval, OUT_DIR)
write.csv(leaderboard, file.path(OUT_DIR, "tuned_comparison.csv"), row.names = FALSE)
message("tuned leaderboard saved to data/results/tuned_comparison.csv")
REOF

cat > tests/models/tuned/test_remove_id.R << 'REOF'
library(testthat)
source("src/models/tuned/remove_id.R")

test_that("remove_id drops id column", {
  df  <- data.frame(id = 1:5, a = rnorm(5), b = rnorm(5))
  out <- remove_id(df)
  expect_false("id" %in% names(out))
  expect_true("a" %in% names(out))
})

test_that("remove_id returns df unchanged if no id column", {
  df  <- data.frame(a = 1:3, b = 4:6)
  out <- remove_id(df)
  expect_equal(names(out), names(df))
})
REOF

cat > tests/models/tuned/test_xgboost.R << 'REOF'
library(testthat)
source("src/models/tuned/xgboost_model.R")

test_that("make_xgb_matrix returns xgb.DMatrix", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  mat <- make_xgb_matrix(df, "smoking")
  expect_s4_class(mat, "xgb.DMatrix")
})

test_that("predict_xgboost returns probabilities between 0 and 1", {
  df    <- data.frame(a = rnorm(100), b = rnorm(100), smoking = rbinom(100, 1, 0.5))
  fit   <- tune_xgboost(df, "smoking", max_rounds = 10, k = 3)
  preds <- predict_xgboost(fit, df, "smoking")
  expect_true(all(preds >= 0 & preds <= 1))
})
REOF

echo "all tuned model files written"
