library(testthat)
source("src/preprocessing/data_transformation/min_max.R")

test_that("min_max scales values to [0, 1]", {
  df  <- data.frame(a = c(0, 5, 10))
  out <- min_max(df)
  expect_equal(min(out$a), 0)
  expect_equal(max(out$a), 1)
})
