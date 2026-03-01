## models/bootstrap.R
## given train data and response name
## return bootstrap estimates of logistic regression coefficients
## uses B resamples to estimate coefficient stability

library(boot) # boot

B <- 1000

#' given a dataframe, index vector, and response name
#' return logistic regression coefficients on bootstrap sample
boot_logistic_coef <- function(df, idx, response) {
  fit <- glm(as.formula(paste(response, "~ .")), data = df[idx, ], family = binomial)
  coef(fit)
}

#' given a dataframe and response name
#' return boot object with B bootstrap coefficient estimates
#' prints 95% CI for each coefficient
run_bootstrap <- function(df, response, B = 1000) {
  df[[response]] <- as.numeric(as.factor(df[[response]])) - 1
  result <- boot(df, statistic = function(d, i) boot_logistic_coef(d, i, response), R = B)
  message("bootstrap complete — B = ", B)
  result
}
