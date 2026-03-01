library(xgboost)
library(randomForest)
source("src/models/tuned/remove_id.R")
source("src/models/tuned/stack_models.R")
source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

#' given kaggle test data and trained stack
#' return submission dataframe with id and smoking columns
make_submission <- function(stack, kaggle_test, response) {
  test_no_id <- remove_id(kaggle_test)
  probs      <- predict_stack(stack, test_no_id, response)
  preds      <- ifelse(probs >= 0.5, 1, 0)
  data.frame(id = kaggle_test$id, smoking = preds)
}

message("retraining stack on full 15k for submission...")
full_train  <- remove_id(rbind(train_clean, test_clean))
stack_final <- run_stacking(full_train, RESPONSE, k = 10, ntree = 300, xgb_rounds = 150)

message("generating kaggle predictions...")
submission  <- make_submission(stack_final, kaggle_test, RESPONSE)

out_path <- file.path(OUT_DIR, "sample_submission.csv")
write.csv(submission, out_path, row.names = FALSE)
message("saved: ", out_path)
message("rows: ",      nrow(submission))
message("smoking=1: ", sum(submission$smoking))
message("smoking=0: ", sum(submission$smoking == 0))
