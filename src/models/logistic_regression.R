## models/logistic_regression.R
## given train data and response name
## return fitted logistic regression glm model
## response must be binary (0/1 or factor)

#' given a dataframe and response name
#' return fitted logistic regression model
run_logistic <- function(df, response) {
  df[[response]] <- as.factor(df[[response]])
  glm(as.formula(paste(response, "~ .")), data = df, family = binomial)
}

#' given a fitted logistic model and test data
#' return predicted class labels using 0.5 threshold
predict_logistic <- function(fit, test, threshold = 0.5) {
  probs <- predict(fit, newdata = test, type = "response")
  ifelse(probs >= threshold, 1, 0)
}
