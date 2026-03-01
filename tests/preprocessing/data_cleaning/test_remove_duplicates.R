library(testthat)
source("src/preprocessing/data_cleaning/remove_duplicates.R")

test_that("remove_duplicates drops duplicate rows", {
  df  <- data.frame(a = c(1, 1, 2), b = c("x", "x", "y"))
  out <- remove_duplicates(df)
  expect_equal(nrow(out), 2)
})

test_that("remove_duplicates keeps all rows when none are duplicate", {
  df  <- data.frame(a = 1:3)
  out <- remove_duplicates(df)
  expect_equal(nrow(out), 3)
})
