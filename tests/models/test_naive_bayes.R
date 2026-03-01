library(testthat)
source("src/models/naive_bayes.R")

test_that("run_naive_bayes returns a naiveBayes object", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  fit <- run_naive_bayes(df, "smoking")
  expect_s3_class(fit, "naiveBayes")
})
