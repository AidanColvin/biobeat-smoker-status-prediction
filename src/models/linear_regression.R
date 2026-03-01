## models/linear_regression.R
## given train data and response name
## return fitted lm model
## note: used for coefficient interpretation, not final prediction

#' given a dataframe and response name
#' return fitted linear regression model
run_linear_regression <- function(df, response) {
  lm(as.formula(paste(response, "~ .")), data = df)
}
