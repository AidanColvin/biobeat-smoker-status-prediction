library(testthat)
source("src/models/pcr.R")

test_that("run_pcr returns model and best_ncomp", {
  df  <- data.frame(a = rnorm(50), b = rnorm(50), c = rnorm(50), smoking = rbinom(50, 1, 0.5))
  out <- run_pcr(df, "smoking", out_dir = tempdir())
  expect_true(!is.null(out$model))
  expect_true(is.numeric(out$best_ncomp))
})
