library(testthat)
source("src/preprocessing/data_transformation/log_transform.R")

test_that("log_transform applies log1p to numeric columns", {
  df  <- data.frame(a = c(0, 1, 9))
  out <- log_transform(df)
  expect_equal(out$a, log1p(c(0, 1, 9)))
})
