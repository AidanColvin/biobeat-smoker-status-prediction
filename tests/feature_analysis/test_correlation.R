library(testthat)
source("src/feature_analysis/correlation.R")

test_that("correlate_features returns named numeric vector", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- correlate_features(df, "smoking", out_dir = tempdir())
  expect_true(is.numeric(out))
  expect_true(!is.null(names(out)))
})
