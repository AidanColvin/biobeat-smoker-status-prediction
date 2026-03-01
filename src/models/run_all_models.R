source("src/models/knn.R")
source("src/models/linear_regression.R")
source("src/models/logistic_regression.R")
source("src/models/naive_bayes.R")
source("src/models/nonlinearity.R")
source("src/models/bootstrap.R")
source("src/models/ridge_lasso.R")
source("src/models/pcr.R")
source("src/train/train_rf.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"

message("fitting linear...")
message("fitting logistic...")
message("fitting naive bayes...")
message("fitting ridge...")
message("fitting lasso...")
message("fitting pcr...")
message("fitting bootstrap B=200...")
message("fitting random forest - may take 60 seconds...")

model_results <- list(
  linear        = run_linear_regression(train_clean, RESPONSE),
  logistic      = run_logistic(train_clean,           RESPONSE),
  naive_bayes   = run_naive_bayes(train_clean,        RESPONSE),
  ridge         = run_ridge(train_clean,              RESPONSE),
  lasso         = run_lasso(train_clean,              RESPONSE),
  pcr           = run_pcr(train_clean,                RESPONSE, OUT_DIR),
  bootstrap     = run_bootstrap(train_clean,          RESPONSE, B = 200),
  random_forest = train_rf(train_clean,               RESPONSE, ntree = 300)
)

message("all models fitted: ", paste(names(model_results), collapse = ", "))
