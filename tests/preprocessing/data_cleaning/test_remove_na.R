library(testthat)
source("src/preprocessing/data_cleaning/remove_na.R")

test_that("remove_na drops rows with NA", {
  df  <- data.frame(a = c(1, NA, 3), b = c(4, 5, NA))
  out <- remove_na(df)
  expect_equal(nrow(out), 1)
  expect_false(anyNA(out))
})

test_that("remove_na returns full df when no NAs", {
  df  <- data.frame(a = 1:3, b = 4:6)
  out <- remove_na(df)
  expect_equal(nrow(out), 3)
})
