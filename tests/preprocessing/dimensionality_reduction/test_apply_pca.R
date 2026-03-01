library(testthat)
source("src/preprocessing/dimensionality_reduction/apply_pca.R")

test_that("apply_pca returns n_components columns", {
  df  <- data.frame(a = rnorm(20), b = rnorm(20), c = rnorm(20))
  out <- apply_pca(df, n_components = 2)
  expect_equal(ncol(out$data), 2)
  expect_true(!is.null(out$model))
})
