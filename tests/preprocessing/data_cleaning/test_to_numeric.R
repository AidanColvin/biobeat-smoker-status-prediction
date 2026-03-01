library(testthat)
source("src/preprocessing/data_cleaning/to_numeric.R")

test_that("to_numeric converts character column to numeric", {
  df  <- data.frame(a = c("1", "2", "3"), stringsAsFactors = FALSE)
  out <- to_numeric(df, "a")
  expect_true(is.numeric(out$a))
})
