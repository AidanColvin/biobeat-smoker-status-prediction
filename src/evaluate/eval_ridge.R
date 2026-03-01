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
