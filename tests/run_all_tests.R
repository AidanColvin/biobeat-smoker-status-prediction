library(testthat)

test_files <- c(
  "tests/preprocessing/data_cleaning/test_remove_na.R",
  "tests/preprocessing/data_cleaning/test_impute_mean.R",
  "tests/preprocessing/data_cleaning/test_impute_median.R",
  "tests/preprocessing/data_cleaning/test_remove_duplicates.R",
  "tests/preprocessing/data_cleaning/test_to_numeric.R",
  "tests/preprocessing/data_cleaning/test_to_factor.R",
  "tests/preprocessing/data_cleaning/test_to_date.R",
  "tests/preprocessing/data_transformation/test_standardize.R",
  "tests/preprocessing/data_transformation/test_min_max.R",
  "tests/preprocessing/data_transformation/test_cap_outliers.R",
  "tests/preprocessing/data_transformation/test_log_transform.R",
  "tests/preprocessing/feature_engineering/test_one_hot_encode.R",
  "tests/preprocessing/feature_engineering/test_bin_continuous.R",
  "tests/preprocessing/dimensionality_reduction/test_apply_pca.R",
  "tests/preprocessing/dimensionality_reduction/test_drop_features.R",
  "tests/preprocessing/dimensionality_reduction/test_keep_features.R",
  "tests/cross_validate/test_cv_utils.R",
  "tests/cross_validate/test_cv_glm.R",
  "tests/cross_validate/test_cv_lda.R",
  "tests/cross_validate/test_cv_qda.R",
  "tests/cross_validate/test_cv_rf.R",
  "tests/cross_validate/test_cv_svm.R",
  "tests/train/test_train_logistic.R",
  "tests/train/test_train_lda.R",
  "tests/train/test_train_qda.R",
  "tests/train/test_train_rf.R",
  "tests/train/test_train_svm.R"
)

results <- lapply(test_files, function(f) {
  cat("\n── testing:", f, "\n")
  tryCatch(
    test_file(f, reporter = "minimal"),
    error = function(e) message("FAIL: ", f, "\n  ", conditionMessage(e))
  )
})

cat("\n══ all tests complete ══\n")
