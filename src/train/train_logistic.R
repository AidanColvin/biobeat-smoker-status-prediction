## train/train_logistic.R
## given train data, response name, and best_degree from cv
## return fitted logistic regression model

#' given a dataframe, response name, and polynomial degree
#' return fitted glm logistic regression model
train_logistic <- function(df, response, degree) {
  glm(
    as.formula(paste(response, "~ poly(horsepower,", degree, ")")),
    data   = df,
    family = binomial
  )
}