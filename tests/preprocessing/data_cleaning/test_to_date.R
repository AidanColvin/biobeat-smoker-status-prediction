library(testthat)
source("src/preprocessing/data_cleaning/to_date.R")

test_that("to_date converts character column to Date", {
  df  <- data.frame(d = c("2024-01-01", "2024-06-15"), stringsAsFactors = FALSE)
  out <- to_date(df, "d")
  expect_true(inherits(out$d, "Date"))
})
