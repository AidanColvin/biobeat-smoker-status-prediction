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
