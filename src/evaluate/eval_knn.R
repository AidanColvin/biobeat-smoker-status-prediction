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
