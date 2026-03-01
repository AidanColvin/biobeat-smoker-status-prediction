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
