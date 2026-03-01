## evaluate/confusion_matrix.R
## given true labels and predicted labels
## return and print confusion matrix

#' given true binary labels and predicted labels
#' return confusion matrix as table
make_confusion_matrix <- function(truth, preds) {
  table(predicted = preds, actual = truth)
}

#' given a confusion matrix table
#' print formatted confusion matrix
print_confusion_matrix <- function(cm, model_name) {
  message("\n── confusion matrix: ", model_name, " ──")
  print(cm)
}
