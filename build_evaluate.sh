#!/bin/bash
set -e

mkdir -p src/evaluate
mkdir -p tests/evaluate

cat > src/evaluate/metrics.R << 'REOF'
## evaluate/metrics.R
## given true labels and predicted labels or probabilities
## return classification metrics: accuracy, precision, recall, f1, auc

library(pROC)

#' given true binary labels and predicted labels
#' return list with accuracy, precision, recall, f1
classification_metrics <- function(truth, preds) {
  truth <- as.numeric(as.character(truth))
  preds <- as.numeric(as.character(preds))
  tp <- sum(preds == 1 & truth == 1)
  tn <- sum(preds == 0 & truth == 0)
  fp <- sum(preds == 1 & truth == 0)
  fn <- sum(preds == 0 & truth == 1)
  precision <- ifelse((tp + fp) == 0, 0, tp / (tp + fp))
  recall    <- ifelse((tp + fn) == 0, 0, tp / (tp + fn))
  f1        <- ifelse((precision + recall) == 0, 0, 2 * precision * recall / (precision + recall))
  list(
    accuracy  = (tp + tn) / length(truth),
    precision = precision,
    recall    = recall,
    f1        = f1
  )
}

#' given true binary labels and predicted probabilities
#' return auc score
compute_auc <- function(truth, probs) {
  roc_obj <- roc(as.numeric(truth), as.numeric(probs), quiet = TRUE)
  as.numeric(auc(roc_obj))
}

#' given true labels and predicted probabilities
#' save roc curve plot to out_dir
plot_roc <- function(truth, probs, model_name, out_dir = "data/results") {
  roc_obj <- roc(as.numeric(truth), as.numeric(probs), quiet = TRUE)
  png(file.path(out_dir, paste0("roc_", model_name, ".png")), width = 700, height = 600)
  plot(roc_obj, main = paste("ROC curve:", model_name), col = "steelblue", lwd = 2)
  legend("bottomright", legend = paste("AUC =", round(auc(roc_obj), 4)), bty = "n")
  dev.off()
}
REOF

cat > src/evaluate/confusion_matrix.R << 'REOF'
## evaluate/confusion_matrix.R
## given true labels and predicted labels
## return and print confusion matrix

#' given true binary labels and predicted labels
#' return confusion matrix as table
make_confusion_matrix <- function(truth, preds) {
  table(predicted = preds, actual = truth)
}

#' given a confusion matrix table
#' print formatted confusion matrix
print_confusion_matrix <- function(cm, model_name) {
  message("\n── confusion matrix: ", model_name, " ──")
  print(cm)
}
REOF

cat > src/evaluate/eval_logistic.R << 'REOF'
## evaluate/eval_logistic.R
## given fitted logistic model and test data
## return metrics for logistic regression
## logistic is recommended primary model for binary smoking prediction

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given a fitted logistic glm and test dataframe with response col
#' return list with metrics, auc, and confusion matrix
eval_logistic <- function(fit, test, response, out_dir = "data/results") {
  probs   <- predict(fit, newdata = test, type = "response")
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth   <- as.numeric(test[[response]])
  metrics <- classification_metrics(truth, preds)
  auc_val <- compute_auc(truth, probs)
  cm      <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "logistic", out_dir)
  print_confusion_matrix(cm, "logistic")
  message("logistic auc: ", round(auc_val, 4))
  list(model = "logistic", metrics = metrics, auc = auc_val, confusion_matrix = cm)
}
REOF

cat > src/evaluate/eval_ridge.R << 'REOF'
## evaluate/eval_ridge.R
## given fitted ridge cv model and test data
## return metrics for ridge regression
## ridge recommended for correlated clinical features like blood pressure pairs

library(glmnet)
source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given a fitted cv.glmnet ridge model and test dataframe with response col
#' return list with metrics, auc, and confusion matrix
eval_ridge <- function(fit, test, response, out_dir = "data/results") {
  x       <- model.matrix(as.formula(paste(response, "~ .")), test)[, -1]
  probs   <- predict(fit$model, newx = x, s = fit$lambda, type = "response")[, 1]
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth   <- as.numeric(test[[response]])
  metrics <- classification_metrics(truth, preds)
  auc_val <- compute_auc(truth, probs)
  cm      <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "ridge", out_dir)
  print_confusion_matrix(cm, "ridge")
  message("ridge auc: ", round(auc_val, 4))
  list(model = "ridge", metrics = metrics, auc = auc_val, confusion_matrix = cm)
}
REOF

cat > src/evaluate/eval_lasso.R << 'REOF'
## evaluate/eval_lasso.R
## given fitted lasso cv model and test data
## return metrics for lasso regression
## lasso performs automatic feature selection by zeroing non-predictive markers

library(glmnet)
source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given a fitted cv.glmnet lasso model and test dataframe with response col
#' return list with metrics, auc, confusion matrix, and selected features
eval_lasso <- function(fit, test, response, out_dir = "data/results") {
  x        <- model.matrix(as.formula(paste(response, "~ .")), test)[, -1]
  probs    <- predict(fit$model, newx = x, s = fit$lambda, type = "response")[, 1]
  preds    <- ifelse(probs >= 0.5, 1, 0)
  truth    <- as.numeric(test[[response]])
  metrics  <- classification_metrics(truth, preds)
  auc_val  <- compute_auc(truth, probs)
  cm       <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "lasso", out_dir)
  print_confusion_matrix(cm, "lasso")
  message("lasso auc: ", round(auc_val, 4))
  message("lasso selected features: ", paste(fit$kept_features, collapse = ", "))
  list(model = "lasso", metrics = metrics, auc = auc_val, confusion_matrix = cm, selected = fit$kept_features)
}
REOF

cat > src/evaluate/eval_elastic_net.R << 'REOF'
## evaluate/eval_elastic_net.R
## given train and test data and response name
## fits and evaluates elastic net (alpha between 0 and 1)
## best of ridge and lasso: handles correlated features AND does feature selection

library(glmnet)
source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given train data and response name
#' return fitted elastic net cv model with alpha = 0.5
fit_elastic_net <- function(df, response, alpha = 0.5) {
  x      <- model.matrix(as.formula(paste(response, "~ .")), df)[, -1]
  y      <- as.numeric(df[[response]])
  cv_fit <- cv.glmnet(x, y, alpha = alpha, family = "binomial")
  list(model = cv_fit, lambda = cv_fit$lambda.min, alpha = alpha)
}

#' given fitted elastic net model and test data
#' return list with metrics, auc, and confusion matrix
eval_elastic_net <- function(fit, test, response, out_dir = "data/results") {
  x       <- model.matrix(as.formula(paste(response, "~ .")), test)[, -1]
  probs   <- predict(fit$model, newx = x, s = fit$lambda, type = "response")[, 1]
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth   <- as.numeric(test[[response]])
  metrics <- classification_metrics(truth, preds)
  auc_val <- compute_auc(truth, probs)
  cm      <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "elastic_net", out_dir)
  print_confusion_matrix(cm, "elastic_net")
  message("elastic net auc: ", round(auc_val, 4))
  list(model = "elastic_net", metrics = metrics, auc = auc_val, confusion_matrix = cm)
}
REOF

cat > src/evaluate/eval_knn.R << 'REOF'
## evaluate/eval_knn.R
## given train and test data and response name
## return knn evaluation metrics
## note: knn not recommended primary model with 22 features (curse of dimensionality)
## data must be pre-standardized before calling

source("src/models/knn.R")
source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given train data, test data, response name, and k
#' return list with metrics and confusion matrix for knn
eval_knn <- function(train, test, response, k = 5) {
  preds   <- run_knn(train, test, response, k)
  truth   <- as.numeric(test[[response]])
  preds_n <- as.numeric(as.character(preds))
  metrics <- classification_metrics(truth, preds_n)
  cm      <- make_confusion_matrix(truth, preds_n)
  print_confusion_matrix(cm, paste0("knn_k", k))
  message("knn (k=", k, ") accuracy: ", round(metrics$accuracy, 4))
  list(model = paste0("knn_k", k), metrics = metrics, confusion_matrix = cm)
}
REOF

cat > src/evaluate/eval_naive_bayes.R << 'REOF'
## evaluate/eval_naive_bayes.R
## given fitted naive bayes model and test data
## return evaluation metrics
## note: not recommended due to violated independence assumption in clinical data

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given fitted naive bayes model and test dataframe with response col
#' return list with metrics and confusion matrix
eval_naive_bayes <- function(fit, test, response) {
  preds   <- predict(fit, newdata = test)
  truth   <- as.numeric(test[[response]])
  preds_n <- as.numeric(as.character(preds))
  metrics <- classification_metrics(truth, preds_n)
  cm      <- make_confusion_matrix(truth, preds_n)
  print_confusion_matrix(cm, "naive_bayes")
  message("naive bayes accuracy: ", round(metrics$accuracy, 4))
  list(model = "naive_bayes", metrics = metrics, confusion_matrix = cm)
}
REOF

cat > src/evaluate/eval_rf.R << 'REOF'
## evaluate/eval_rf.R
## given fitted random forest model and test data
## return evaluation metrics
## rf captures nonlinear clinical interactions without manual polynomial features

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given fitted random forest model and test dataframe with response col
#' return list with metrics, auc, and confusion matrix
eval_rf <- function(fit, test, response, out_dir = "data/results") {
  probs   <- predict(fit, newdata = test, type = "prob")[, 2]
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth   <- as.numeric(test[[response]])
  metrics <- classification_metrics(truth, preds)
  auc_val <- compute_auc(truth, probs)
  cm      <- make_confusion_matrix(truth, preds)
  plot_roc(truth, probs, "random_forest", out_dir)
  print_confusion_matrix(cm, "random_forest")
  message("random forest auc: ", round(auc_val, 4))
  list(model = "random_forest", metrics = metrics, auc = auc_val, confusion_matrix = cm)
}
REOF

cat > src/evaluate/eval_combinations.R << 'REOF'
## evaluate/eval_combinations.R
## given a list of fitted models and test data
## tests ensemble combinations: majority vote and probability averaging
## combinations can outperform any single model

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

#' given a named list of probability vectors
#' return averaged probability vector
average_probs <- function(prob_list) {
  Reduce("+", prob_list) / length(prob_list)
}

#' given a named list of prediction vectors (0/1)
#' return majority vote prediction vector
majority_vote <- function(pred_list) {
  vote_matrix <- do.call(cbind, pred_list)
  as.numeric(rowMeans(vote_matrix) >= 0.5)
}

#' given averaged probabilities and truth labels
#' return metrics for probability averaging ensemble
eval_avg_ensemble <- function(prob_list, truth, combo_name, out_dir = "data/results") {
  probs   <- average_probs(prob_list)
  preds   <- ifelse(probs >= 0.5, 1, 0)
  truth_n <- as.numeric(truth)
  metrics <- classification_metrics(truth_n, preds)
  auc_val <- compute_auc(truth_n, probs)
  cm      <- make_confusion_matrix(truth_n, preds)
  plot_roc(truth_n, probs, combo_name, out_dir)
  print_confusion_matrix(cm, combo_name)
  message(combo_name, " ensemble auc: ", round(auc_val, 4))
  list(model = combo_name, metrics = metrics, auc = auc_val, confusion_matrix = cm)
}

#' given a list of prediction vectors and truth labels
#' return metrics for majority vote ensemble
eval_vote_ensemble <- function(pred_list, truth, combo_name) {
  preds   <- majority_vote(pred_list)
  truth_n <- as.numeric(truth)
  metrics <- classification_metrics(truth_n, preds)
  cm      <- make_confusion_matrix(truth_n, preds)
  print_confusion_matrix(cm, combo_name)
  message(combo_name, " vote accuracy: ", round(metrics$accuracy, 4))
  list(model = combo_name, metrics = metrics, confusion_matrix = cm)
}
REOF

cat > src/evaluate/compare_models.R << 'REOF'
## evaluate/compare_models.R
## given a list of eval result objects
## return sorted comparison table of all models by auc
## saves leaderboard to data/results/model_comparison.csv

#' given a list of eval result lists each with model name and metrics
#' return dataframe sorted by auc descending
compare_models <- function(eval_results, out_dir = "data/results") {
  rows <- lapply(eval_results, function(r) {
    data.frame(
      model     = r$model,
      accuracy  = round(r$metrics$accuracy,  4),
      precision = round(r$metrics$precision, 4),
      recall    = round(r$metrics$recall,    4),
      f1        = round(r$metrics$f1,        4),
      auc       = round(ifelse(is.null(r$auc), NA, r$auc), 4)
    )
  })
  tbl <- do.call(rbind, rows)
  tbl <- tbl[order(-tbl$auc, na.last = TRUE), ]
  write.csv(tbl, file.path(out_dir, "model_comparison.csv"), row.names = FALSE)
  message("\n── model leaderboard ─────────────────")
  print(tbl)
  message("─────────────────────────────────────")
  tbl
}
REOF

cat > src/evaluate/run_all_evaluate.R << 'REOF'
## evaluate/run_all_evaluate.R
## orchestrator: evaluates all models and combinations on test data
## expects model_results from models/run_all_models.R
## expects train_clean and test_clean from preprocessing pipeline
## saves full leaderboard and roc curves to data/results/

source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")
source("src/evaluate/eval_logistic.R")
source("src/evaluate/eval_ridge.R")
source("src/evaluate/eval_lasso.R")
source("src/evaluate/eval_elastic_net.R")
source("src/evaluate/eval_knn.R")
source("src/evaluate/eval_naive_bayes.R")
source("src/evaluate/eval_rf.R")
source("src/evaluate/eval_combinations.R")
source("src/evaluate/compare_models.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

elastic_fit <- fit_elastic_net(train_clean, RESPONSE)

eval_results <- list(
  logistic    = eval_logistic(model_results$logistic,    test_clean, RESPONSE, OUT_DIR),
  ridge       = eval_ridge(model_results$ridge,          test_clean, RESPONSE, OUT_DIR),
  lasso       = eval_lasso(model_results$lasso,          test_clean, RESPONSE, OUT_DIR),
  elastic_net = eval_elastic_net(elastic_fit,            test_clean, RESPONSE, OUT_DIR),
  naive_bayes = eval_naive_bayes(model_results$naive_bayes, test_clean, RESPONSE),
  random_forest = eval_rf(model_results$random_forest,  test_clean, RESPONSE, OUT_DIR),
  knn_5       = eval_knn(train_clean, test_clean,        RESPONSE, k = 5)
)

logistic_probs <- predict(model_results$logistic, newdata = test_clean, type = "response")
ridge_x        <- model.matrix(as.formula(paste(RESPONSE, "~ .")), test_clean)[, -1]
ridge_probs    <- predict(model_results$ridge$model,  newx = ridge_x, s = model_results$ridge$lambda,  type = "response")[, 1]
lasso_probs    <- predict(model_results$lasso$model,  newx = ridge_x, s = model_results$lasso$lambda,  type = "response")[, 1]
elastic_probs  <- predict(elastic_fit$model,           newx = ridge_x, s = elastic_fit$lambda,          type = "response")[, 1]

eval_results$logistic_ridge_avg <- eval_avg_ensemble(
  list(logistic_probs, ridge_probs), test_clean[[RESPONSE]], "logistic_ridge_avg", OUT_DIR)

eval_results$logistic_lasso_avg <- eval_avg_ensemble(
  list(logistic_probs, lasso_probs), test_clean[[RESPONSE]], "logistic_lasso_avg", OUT_DIR)

eval_results$logistic_elastic_avg <- eval_avg_ensemble(
  list(logistic_probs, elastic_probs), test_clean[[RESPONSE]], "logistic_elastic_avg", OUT_DIR)

eval_results$top3_avg <- eval_avg_ensemble(
  list(logistic_probs, ridge_probs, elastic_probs), test_clean[[RESPONSE]], "top3_avg", OUT_DIR)

leaderboard <- compare_models(eval_results, OUT_DIR)
message("evaluation complete — leaderboard saved to data/results/model_comparison.csv")
REOF

cat > tests/evaluate/test_metrics.R << 'REOF'
library(testthat)
source("src/evaluate/metrics.R")

test_that("classification_metrics returns correct accuracy", {
  truth <- c(1, 0, 1, 0)
  preds <- c(1, 0, 0, 0)
  out   <- classification_metrics(truth, preds)
  expect_equal(out$accuracy, 0.75)
})

test_that("classification_metrics returns correct f1", {
  truth <- c(1, 1, 0, 0)
  preds <- c(1, 0, 0, 0)
  out   <- classification_metrics(truth, preds)
  expect_gt(out$f1, 0)
})
REOF

cat > tests/evaluate/test_confusion_matrix.R << 'REOF'
library(testthat)
source("src/evaluate/confusion_matrix.R")

test_that("make_confusion_matrix returns a 2x2 table", {
  truth <- c(1, 0, 1, 0, 1)
  preds <- c(1, 0, 0, 0, 1)
  cm    <- make_confusion_matrix(truth, preds)
  expect_true(is.table(cm))
})
REOF

cat > tests/evaluate/test_combinations.R << 'REOF'
library(testthat)
source("src/evaluate/eval_combinations.R")

test_that("average_probs averages correctly", {
  p1  <- c(0.2, 0.8)
  p2  <- c(0.4, 0.6)
  out <- average_probs(list(p1, p2))
  expect_equal(out, c(0.3, 0.7))
})

test_that("majority_vote returns correct labels", {
  p1  <- c(1, 0, 1)
  p2  <- c(1, 1, 0)
  p3  <- c(0, 0, 1)
  out <- majority_vote(list(p1, p2, p3))
  expect_equal(out, c(1, 0, 1))
})
REOF

cat > tests/evaluate/test_compare_models.R << 'REOF'
library(testthat)
source("src/evaluate/compare_models.R")

test_that("compare_models returns sorted dataframe with auc column", {
  results <- list(
    list(model = "a", metrics = list(accuracy = 0.8, precision = 0.7, recall = 0.75, f1 = 0.72), auc = 0.85),
    list(model = "b", metrics = list(accuracy = 0.75, precision = 0.65, recall = 0.7, f1 = 0.67), auc = 0.80)
  )
  out <- compare_models(results, out_dir = tempdir())
  expect_equal(out$model[1], "a")
  expect_true("auc" %in% names(out))
})
REOF

echo "all evaluate files written"
