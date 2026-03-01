run_linear_regression <- function(df, response) {
  lm(as.formula(paste(response, "~ .")), data = df)
}
