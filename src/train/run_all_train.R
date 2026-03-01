## train/run_all_train.R
## sources all train scripts and fits each model on full train_clean
## expects train_clean and best_degree from prior pipeline steps
## passes models list to evaluate.R

source("src/train/train_logistic.R")
source("src/train/train_lda.R")
source("src/train/train_qda.R")
source("src/train/train_rf.R")
source("src/train/train_svm.R")

RESPONSE <- "smoker_status"

models <- list(
  logistic      = train_logistic(train_clean, RESPONSE, best_degree),
  lda           = train_lda(train_clean,      RESPONSE),
  qda           = train_qda(train_clean,      RESPONSE),
  random_forest = train_rf(train_clean,       RESPONSE),
  svm           = train_svm(train_clean,      RESPONSE)
)

message("fitted: ", paste(names(models), collapse = ", "))