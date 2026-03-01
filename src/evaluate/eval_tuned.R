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
