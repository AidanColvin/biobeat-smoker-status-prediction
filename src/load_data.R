library(readr)
library(dplyr)
source("src/preprocessing/data_cleaning/clean_colnames.R")

RAW_DIR   <- file.path("data", "raw")
TRAIN_CSV <- "train_biobeat_smoker_status_prediction.csv"
TEST_CSV  <- "test_biobeat_smoker_status_prediction.csv"

#' given a filepath to a csv
#' return a tibble of the raw data
#' stops with a clear message if file is not found
load_csv <- function(filepath) {
  if (!file.exists(filepath)) stop("file not found: ", filepath)
  read_csv(filepath, show_col_types = FALSE)
}

#' given a dataframe and split proportion
#' return list with train and validation splits
#' uses set.seed for reproducibility
train_val_split <- function(df, prop = 0.8, seed = 42) {
  set.seed(seed)
  n     <- nrow(df)
  idx   <- sample(seq_len(n), size = floor(prop * n))
  list(train = df[idx, ], val = df[-idx, ])
}

#' given the raw directory path
#' return list with train, val, and kaggle test tibbles
#' column names sanitized on load
load_raw_data <- function(raw_dir = RAW_DIR) {
  raw_train <- clean_colnames(load_csv(file.path(raw_dir, TRAIN_CSV)))
  kaggle_test <- clean_colnames(load_csv(file.path(raw_dir, TEST_CSV)))
  splits    <- train_val_split(raw_train)
  message("train: ",      nrow(splits$train), " rows x ", ncol(splits$train), " cols")
  message("validation: ", nrow(splits$val),   " rows x ", ncol(splits$val),   " cols")
  message("kaggle test: ", nrow(kaggle_test),  " rows x ", ncol(kaggle_test),  " cols")
  list(train = splits$train, val = splits$val, kaggle_test = kaggle_test)
}

raw         <- load_raw_data()
train_raw   <- raw$train
val_raw     <- raw$val
kaggle_test <- raw$kaggle_test
train_clean <- train_raw
test_clean  <- val_raw
