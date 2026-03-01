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
