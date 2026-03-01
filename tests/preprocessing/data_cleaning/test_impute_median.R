library(testthat)
source("src/preprocessing/data_cleaning/impute_median.R")

test_that("impute_median fills NAs with column median", {
  df  <- data.frame(a = c(1, NA, 3, 100))
  out <- impute_median(df)
  expect_false(anyNA(out))
  expect_equal(out$a[2], median(c(1, 3, 100)))
})
