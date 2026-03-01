library(testthat)
source("src/models/logistic_regression.R")

test_that("run_logistic returns a glm object", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  fit <- run_logistic(df, "smoking")
  expect_s3_class(fit, "glm")
})
