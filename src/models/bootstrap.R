library(boot)

boot_logistic_coef <- function(df, idx, response) {
  fit <- glm(as.formula(paste(response, "~ .")), data = df[idx, ], family = binomial)
  coef(fit)
}

run_bootstrap <- function(df, response, B = 1000) {
  df[[response]] <- as.numeric(as.factor(df[[response]])) - 1
  boot(df, statistic = function(d, i) boot_logistic_coef(d, i, response), R = B)
}
