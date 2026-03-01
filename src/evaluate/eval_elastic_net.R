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
