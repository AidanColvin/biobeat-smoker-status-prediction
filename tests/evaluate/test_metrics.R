library(testthat)
source("src/evaluate/metrics.R")

test_that("classification_metrics returns correct accuracy", {
  truth <- c(1, 0, 1, 0)
  preds <- c(1, 0, 0, 0)
  out   <- classification_metrics(truth, preds)
  expect_equal(out$accuracy, 0.75)
})

test_that("classification_metrics returns correct f1", {
  truth <- c(1, 1, 0, 0)
  preds <- c(1, 0, 0, 0)
  out   <- classification_metrics(truth, preds)
  expect_gt(out$f1, 0)
})
