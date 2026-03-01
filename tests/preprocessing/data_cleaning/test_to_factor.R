library(testthat)
source("src/preprocessing/data_cleaning/to_factor.R")

test_that("to_factor converts column to factor", {
  df  <- data.frame(a = c("yes", "no", "yes"), stringsAsFactors = FALSE)
  out <- to_factor(df, "a")
  expect_true(is.factor(out$a))
})
