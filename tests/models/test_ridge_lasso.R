library(testthat)
source("src/models/ridge_lasso.R")

test_that("run_ridge returns model and lambda", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- run_ridge(df, "smoking")
  expect_true(!is.null(out$lambda))
})

test_that("run_lasso returns kept_features", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- run_lasso(df, "smoking")
  expect_true(is.character(out$kept_features))
})
