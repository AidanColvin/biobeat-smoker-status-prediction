## load_data.R
## entry point for the preprocessing pipeline
## reads raw train/test CSVs from data/raw/
## returns cleaned tibbles ready for the next script

library(readr)
library(dplyr)

# ── paths ──────────────────────────────────────────────────────────────────────

RAW_DIR   <- file.path("data", "raw")
TRAIN_CSV <- file.path(RAW_DIR, "train_biobeat_smoker_status_p.csv")
TEST_CSV  <- file.path(RAW_DIR, "test_biobeat_smoker_status_p.csv")

# ── loaders ───────────────────────────────────────────────────────────────────

#' given a filepath to a csv
#' return a tibble of the raw data
#' stops with a clear message if file is not found
load_csv <- function(filepath) {
  if (!file.exists(filepath)) stop("file not found: ", filepath)
  read_csv(filepath, show_col_types = FALSE)
}

#' given the raw directory path
#' return list with train and test tibbles
#' prints shape of each on load
load_raw_data <- function(raw_dir = RAW_DIR) {
  train <- load_csv(file.path(raw_dir, basename(TRAIN_CSV)))
  test  <- load_csv(file.path(raw_dir, basename(TEST_CSV)))

  message("train: ", nrow(train), " rows x ", ncol(train), " cols")
  message("test:  ", nrow(test),  " rows x ", ncol(test),  " cols")

  list(train = train, test = test)
}

# ── run ───────────────────────────────────────────────────────────────────────

raw <- load_raw_data()

# pass forward to next script
train_raw <- raw$train
test_raw  <- raw$test