## train/train_svm.R
## given train data and response name
## return fitted svm model with radial kernel on full training set

library(e1071) # svm

#' given a dataframe and response name
#' return fitted svm model with radial kernel
train_svm <- function(df, response) {
  df[[response]] <- as.factor(df[[response]])
  svm(as.formula(paste(response, "~ .")), data = df, kernel = "radial", probability = TRUE)
}