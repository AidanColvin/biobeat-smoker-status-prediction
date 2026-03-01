library(testthat)
source("src/evaluate/confusion_matrix.R")

test_that("make_confusion_matrix returns a 2x2 table", {
  truth <- c(1, 0, 1, 0, 1)
  preds <- c(1, 0, 0, 0, 1)
  cm    <- make_confusion_matrix(truth, preds)
  expect_true(is.table(cm))
})
