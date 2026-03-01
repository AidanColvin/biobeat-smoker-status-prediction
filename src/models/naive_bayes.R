## models/naive_bayes.R
## given train data and response name
## return fitted naive bayes model

library(e1071) # naiveBayes

#' given a dataframe and response name
#' return fitted naive bayes classifier
run_naive_bayes <- function(df, response) {
  df[[response]] <- as.factor(df[[response]])
  naiveBayes(as.formula(paste(response, "~ .")), data = df)
}

#' given a fitted naive bayes model and test data
#' return predicted class labels
predict_naive_bayes <- function(fit, test) {
  predict(fit, newdata = test)
}
