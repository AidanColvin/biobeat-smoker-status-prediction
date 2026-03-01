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
