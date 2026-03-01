## cross_validate/cv_utils.R
## shared utilities for cross validation
## used by all cv_*.R scripts

#' given a number of rows and number of folds
#' return integer vector assigning each row to a fold
make_folds <- function(n, k = 10) {
  set.seed(42)
  sample(rep(1:k, length.out = n))
}

#' given predictions and true labels
#' return classification error rate
classification_error <- function(preds, truth) {
  mean(preds != truth)
}