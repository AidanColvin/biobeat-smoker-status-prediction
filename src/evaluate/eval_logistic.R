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
