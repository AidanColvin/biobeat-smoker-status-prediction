library(testthat)
source("src/preprocessing/data_transformation/standardize.R")

test_that("standardize produces mean ~0 and sd ~1", {
  df  <- data.frame(a = c(10, 20, 30, 40, 50))
  out <- standardize(df)
  expect_lt(abs(mean(out$a)), 1e-10)
  expect_lt(abs(sd(out$a) - 1), 1e-10)
})
