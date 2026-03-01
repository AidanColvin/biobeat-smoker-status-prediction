library(testthat)
source("src/preprocessing/data_cleaning/clean_colnames.R")

test_that("clean_colnames removes parentheses from column names", {
  df  <- data.frame("height(cm)" = 1:3, check.names = FALSE)
  out <- clean_colnames(df)
  expect_false(any(grepl("[()]", names(out))))
})

test_that("clean_colnames removes spaces from column names", {
  df  <- data.frame("blood pressure" = 1:3, check.names = FALSE)
  out <- clean_colnames(df)
  expect_false(any(grepl(" ", names(out))))
})

test_that("clean_colnames does not change already clean names", {
  df  <- data.frame(height_cm = 1:3, age = 1:3)
  out <- clean_colnames(df)
  expect_equal(names(out), names(df))
})
