## cross_validate/run_all_cv.R
## sources all cv scripts and runs each
## passes cv_results and best_degree to train/run_all_train.R

source("src/cross_validate/cv_glm.R")
source("src/cross_validate/cv_lda.R")
source("src/cross_validate/cv_qda.R")
source("src/cross_validate/cv_rf.R")
source("src/cross_validate/cv_svm.R")

RESPONSE <- "smoker_status"

glm_result  <- cv_glm(train_clean, RESPONSE)
lda_error   <- cv_lda(train_clean, RESPONSE)
qda_error   <- cv_qda(train_clean, RESPONSE)
rf_error    <- cv_rf(train_clean,  RESPONSE)
svm_error   <- cv_svm(train_clean, RESPONSE)

cv_results <- list(
  logistic      = glm_result$cv_errors[glm_result$best_degree],
  lda           = lda_error,
  qda           = qda_error,
  random_forest = rf_error,
  svm           = svm_error
)

best_degree <- glm_result$best_degree

message("\n── cv summary ────────────────────────")
for (name in names(cv_results)) message(sprintf("  %-15s %.4f", name, cv_results[[name]]))
message("──────────────────────────────────────")