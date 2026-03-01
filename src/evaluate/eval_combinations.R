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
