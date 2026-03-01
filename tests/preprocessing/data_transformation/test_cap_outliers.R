library(testthat)
source("src/preprocessing/data_transformation/cap_outliers.R")

test_that("cap_outliers removes extreme values beyond bounds", {
  df  <- data.frame(a = c(1, 2, 3, 4, 1000))
  out <- cap_outliers(df, lower = 0.05, upper = 0.95)
  expect_lt(max(out$a), 1000)
})
