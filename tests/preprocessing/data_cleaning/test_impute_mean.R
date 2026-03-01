library(testthat)
source("src/preprocessing/data_cleaning/impute_mean.R")

test_that("impute_mean fills NAs with column mean", {
  df  <- data.frame(a = c(1, NA, 3))
  out <- impute_mean(df)
  expect_false(anyNA(out))
  expect_equal(out$a[2], mean(c(1, 3)))
})

test_that("impute_mean does not change non-NA values", {
  df  <- data.frame(a = c(2, NA, 4))
  out <- impute_mean(df)
  expect_equal(out$a[1], 2)
  expect_equal(out$a[3], 4)
})
