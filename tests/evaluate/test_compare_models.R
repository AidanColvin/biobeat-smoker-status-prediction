library(testthat)
source("src/evaluate/compare_models.R")

test_that("compare_models returns sorted dataframe with auc column", {
  results <- list(
    list(model = "a", metrics = list(accuracy = 0.8, precision = 0.7, recall = 0.75, f1 = 0.72), auc = 0.85),
    list(model = "b", metrics = list(accuracy = 0.75, precision = 0.65, recall = 0.7, f1 = 0.67), auc = 0.80)
  )
  out <- compare_models(results, out_dir = tempdir())
  expect_equal(out$model[1], "a")
  expect_true("auc" %in% names(out))
})
