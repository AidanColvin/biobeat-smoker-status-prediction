# Biobeat Smoker Status Prediction

A modular, production-grade machine learning pipeline in R for binary classification of individual smoking status from clinical and physiological biomarkers. Built for the Kaggle Biobeat Smoker Status Prediction competition.

---

## Table of Contents

- [Overview](#overview)
- [Dataset](#dataset)
- [Project Structure](#project-structure)
- [Pipeline Architecture](#pipeline-architecture)
- [Installation](#installation)
- [Usage](#usage)
- [Models](#models)
- [Feature Analysis](#feature-analysis)
- [Results](#results)
- [Testing](#testing)
- [Design Principles](#design-principles)
- [Contributing](#contributing)

---

## Overview

This project predicts whether an individual is a smoker based on 22 clinical and physiological features collected from a population health dataset of 15,000 training records and 10,000 test records. The primary evaluation metric is ROC AUC.

The pipeline is structured around strict modularity: every file has exactly one job, every function has exactly one responsibility, and all data transformations are reproducible and independently testable.

**Best result achieved:** XGBoost stacked ensemble, AUC 0.8919 on held-out validation.

---

## Dataset

**Source:** Kaggle — Biobeat Smoker Status Prediction

**Training set:** 15,000 rows, 24 columns (including `smoking` response)

**Test set:** 10,000 rows, 23 columns (no `smoking` label)

**Response variable:** `smoking` — binary integer (0 = non-smoker, 1 = smoker)

**Features:**

| Feature | Description |
|---|---|
| `age` | Age in years |
| `height_cm` | Height in centimeters |
| `weight_kg` | Weight in kilograms |
| `waist_cm` | Waist circumference |
| `eyesight_left` | Left eye visual acuity |
| `eyesight_right` | Right eye visual acuity |
| `hearing_left` | Left ear hearing score |
| `hearing_right` | Right ear hearing score |
| `systolic` | Systolic blood pressure |
| `relaxation` | Diastolic blood pressure |
| `fasting_blood_sugar` | Fasting blood glucose |
| `Cholesterol` | Total cholesterol |
| `triglyceride` | Triglyceride level |
| `HDL` | HDL cholesterol |
| `LDL` | LDL cholesterol |
| `hemoglobin` | Hemoglobin concentration |
| `Urine_protein` | Urine protein level |
| `serum_creatinine` | Serum creatinine |
| `AST` | Aspartate aminotransferase (liver enzyme) |
| `ALT` | Alanine aminotransferase (liver enzyme) |
| `Gtp` | Gamma-glutamyl transferase |
| `dental_caries` | Presence of dental caries |

Column names with special characters (parentheses, spaces) are sanitized on load via `clean_colnames()`.

---

## Project Structure

```
biobeat-smoker-status-prediction/
|
├── data/
│   ├── raw/
│   │   ├── train_biobeat_smoker_status_prediction.csv
│   │   ├── test_biobeat_smoker_status_prediction.csv
│   │   └── sample_submission_biobeat_smoker_status_prediction.csv
│   ├── preprocessed/
│   └── results/
│       ├── model_comparison.csv
│       ├── tuned_comparison.csv
│       ├── predictor_weights.csv
│       ├── feature_importance.csv
│       ├── anova_results.csv
│       ├── mutual_info.csv
│       ├── correlation.csv
│       └── roc_*.png
│
├── src/
│   ├── load_data.R                          # entry point: loads, sanitizes, splits
│   ├── requirements.R                       # installs all dependencies
│   │
│   ├── preprocessing/
│   │   ├── data_cleaning/
│   │   │   ├── clean_colnames.R             # sanitize special chars in column names
│   │   │   ├── remove_na.R                  # drop rows with NA values
│   │   │   ├── impute_mean.R                # fill NAs with column mean
│   │   │   ├── impute_median.R              # fill NAs with column median
│   │   │   ├── remove_duplicates.R          # drop duplicate rows
│   │   │   ├── to_numeric.R                 # cast columns to numeric
│   │   │   ├── to_factor.R                  # cast columns to factor
│   │   │   └── to_date.R                    # cast columns to Date
│   │   ├── data_transformation/
│   │   │   ├── standardize.R                # z-score normalization
│   │   │   ├── min_max.R                    # min-max scaling to [0, 1]
│   │   │   ├── cap_outliers.R               # winsorize at percentile bounds
│   │   │   └── log_transform.R              # log1p transformation
│   │   ├── feature_engineering/
│   │   │   ├── one_hot_encode.R             # dummy encode factor columns
│   │   │   ├── bin_continuous.R             # cut numeric into labeled bins
│   │   │   └── clinical_features.R          # domain-specific engineered features
│   │   └── dimensionality_reduction/
│   │       ├── apply_pca.R                  # PCA via prcomp
│   │       ├── drop_features.R              # remove columns by name
│   │       └── keep_features.R              # retain columns by name
│   │
│   ├── feature_analysis/
│   │   ├── correlation.R                    # Pearson correlation with response
│   │   ├── anova_test.R                     # ANOVA F-statistic per feature
│   │   ├── chi_square_test.R                # chi-square for factor features
│   │   ├── mutual_info.R                    # mutual information via infotheo
│   │   ├── feature_importance.R             # random forest MeanDecreaseGini
│   │   ├── weight_predictors.R              # unified weight: cor + anova + rf
│   │   └── run_all_analysis.R               # orchestrator
│   │
│   ├── cross_validate/
│   │   ├── cv_utils.R                       # make_folds, classification_error
│   │   ├── cv_glm.R                         # 10-fold CV for logistic regression
│   │   ├── cv_lda.R                         # 10-fold CV for LDA
│   │   ├── cv_qda.R                         # 10-fold CV for QDA
│   │   ├── cv_rf.R                          # 10-fold CV for random forest
│   │   ├── cv_svm.R                         # 10-fold CV for SVM
│   │   └── run_all_cv.R                     # orchestrator
│   │
│   ├── models/
│   │   ├── knn.R                            # K-nearest neighbors
│   │   ├── linear_regression.R              # OLS for coefficient interpretation
│   │   ├── logistic_regression.R            # logistic regression + predict
│   │   ├── naive_bayes.R                    # Naive Bayes via e1071
│   │   ├── nonlinearity.R                   # polynomial + natural spline fits
│   │   ├── bootstrap.R                      # bootstrap coefficient estimation
│   │   ├── ridge_lasso.R                    # ridge and lasso via glmnet
│   │   ├── pcr.R                            # principal components regression
│   │   ├── run_all_models.R                 # orchestrator
│   │   └── tuned/
│   │       ├── remove_id.R                  # drop id column before modeling
│   │       ├── tune_rf.R                    # 10-fold CV over mtry values
│   │       ├── xgboost_model.R              # XGBoost with CV nrounds tuning
│   │       ├── xgboost_deep_tune.R          # full grid search: depth, eta, subsample
│   │       ├── elastic_net_tuned.R          # alpha grid search for elastic net
│   │       ├── lightgbm_model.R             # LightGBM with CV early stopping
│   │       ├── stack_models.R               # XGBoost + RF stacked ensemble
│   │       └── run_tuned_models.R           # orchestrator for tuned models
│   │
│   ├── train/
│   │   ├── train_logistic.R
│   │   ├── train_lda.R
│   │   ├── train_qda.R
│   │   ├── train_rf.R
│   │   ├── train_svm.R
│   │   └── run_all_train.R
│   │
│   └── evaluate/
│       ├── metrics.R                        # accuracy, precision, recall, F1, AUC
│       ├── confusion_matrix.R               # table + print helpers
│       ├── eval_logistic.R
│       ├── eval_ridge.R
│       ├── eval_lasso.R
│       ├── eval_elastic_net.R
│       ├── eval_knn.R
│       ├── eval_naive_bayes.R
│       ├── eval_rf.R
│       ├── eval_combinations.R              # probability averaging + majority vote
│       ├── eval_tuned.R                     # tuned RF, XGBoost, elastic net eval
│       ├── compare_models.R                 # unified leaderboard sorted by AUC
│       ├── run_all_evaluate.R               # orchestrator for baseline models
│       └── run_tuned_evaluate.R             # orchestrator for tuned models
│
├── tests/
│   ├── run_all_tests.R                      # runs all 39+ test files
│   ├── preprocessing/
│   │   ├── data_cleaning/
│   │   ├── data_transformation/
│   │   ├── feature_engineering/
│   │   └── dimensionality_reduction/
│   ├── cross_validate/
│   ├── train/
│   ├── models/
│   │   └── tuned/
│   ├── feature_analysis/
│   └── evaluate/
│
├── project_summary/
├── .gitignore
└── README.md
```

---

## Pipeline Architecture

Data flows through the pipeline in a strict single direction. Each stage depends only on the output of the previous stage.

```
load_data.R
    |
    ├── train_clean (12,000 rows, 80% of training data)
    ├── test_clean  (3,000 rows, 20% held-out validation)
    └── kaggle_test (10,000 rows, no labels, for submission)
    |
    v
feature_analysis/run_all_analysis.R
    |
    ├── correlation.csv        (Pearson r per feature)
    ├── anova_results.csv      (F-statistic per feature)
    ├── mutual_info.csv        (mutual information per feature)
    ├── feature_importance.csv (RF MeanDecreaseGini)
    └── predictor_weights.csv  (normalized unified score)
    |
    v
cross_validate/run_all_cv.R
    |
    └── cv_results, best_degree
    |
    v
models/run_all_models.R  OR  models/tuned/run_tuned_models.R
    |
    └── model_results / tuned_results
    |
    v
evaluate/run_all_evaluate.R  OR  evaluate/run_tuned_evaluate.R
    |
    ├── model_comparison.csv   (baseline leaderboard)
    ├── tuned_comparison.csv   (tuned leaderboard)
    └── roc_*.png              (ROC curve per model)
```

---

## Installation

**Requirements:** R >= 4.1, macOS / Linux

**Step 1 — Clone the repository:**

```bash
git clone https://github.com/AidanColvin/biobeat-smoker-status-prediction.git
cd biobeat-smoker-status-prediction
```

**Step 2 — Place data files:**

Download the competition CSVs from Kaggle and place them in `data/raw/`:

```
data/raw/train_biobeat_smoker_status_prediction.csv
data/raw/test_biobeat_smoker_status_prediction.csv
data/raw/sample_submission_biobeat_smoker_status_prediction.csv
```

**Step 3 — Install dependencies:**

```r
source("src/requirements.R")
```

This installs all required packages if not already present:

```
readr, dplyr, tidyr, recipes, mice,
class, e1071, MASS, randomForest,
glmnet, pls, boot, splines, infotheo,
stringr, lubridate, pROC, xgboost, lightgbm
```

---

## Usage

**Run the full baseline pipeline:**

```r
source("src/requirements.R")
source("src/load_data.R")
source("src/feature_analysis/run_all_analysis.R")
source("src/models/run_all_models.R")
source("src/evaluate/run_all_evaluate.R")
```

**Run the tuned/ensemble pipeline:**

```r
source("src/load_data.R")
source("src/models/tuned/run_tuned_models.R")
source("src/evaluate/run_tuned_evaluate.R")
```

**Run the stacked ensemble only:**

```r
source("src/load_data.R")
source("src/models/tuned/remove_id.R")
source("src/models/tuned/stack_models.R")
source("src/evaluate/metrics.R")
source("src/evaluate/confusion_matrix.R")

train_tuned <- remove_id(train_clean)
test_tuned  <- remove_id(test_clean)

stack  <- run_stacking(train_tuned, "smoking", k = 10, ntree = 300, xgb_rounds = 150)
probs  <- predict_stack(stack, test_tuned, "smoking")
```

**Run all tests:**

```bash
Rscript tests/run_all_tests.R
```

**Run the full pipeline from terminal with logging:**

```bash
Rscript -e '
  source("src/requirements.R")
  source("src/load_data.R")
  source("src/feature_analysis/run_all_analysis.R")
  source("src/models/run_all_models.R")
  source("src/evaluate/run_all_evaluate.R")
' 2>&1 | tee pipeline.log
```

---

## Models

### Baseline Models

| Model | File | Notes |
|---|---|---|
| Logistic Regression | `models/logistic_regression.R` | Primary interpretable baseline |
| Linear Regression | `models/linear_regression.R` | Coefficient interpretation only |
| Naive Bayes | `models/naive_bayes.R` | Fast; independence assumption violated |
| KNN | `models/knn.R` | Requires pre-standardized data |
| Ridge | `models/ridge_lasso.R` | Handles correlated features |
| LASSO | `models/ridge_lasso.R` | Automatic feature selection |
| PCR | `models/pcr.R` | Reduces multicollinearity; loses interpretability |
| Bootstrap | `models/bootstrap.R` | Coefficient stability estimation |
| Random Forest | `train/train_rf.R` | Nonlinear clinical interactions |
| LDA | `train/train_lda.R` | Linear decision boundary |
| QDA | `train/train_qda.R` | Quadratic decision boundary |
| SVM | `train/train_svm.R` | Radial kernel |

### Tuned Models

| Model | File | Tuning Strategy |
|---|---|---|
| XGBoost | `models/tuned/xgboost_model.R` | 10-fold CV over nrounds with early stopping |
| XGBoost (deep) | `models/tuned/xgboost_deep_tune.R` | Grid search: depth, eta, subsample, colsample |
| Random Forest (tuned) | `models/tuned/tune_rf.R` | 10-fold CV over mtry values |
| Elastic Net (tuned) | `models/tuned/elastic_net_tuned.R` | Grid search over alpha in [0, 0.25, 0.5, 0.75, 1] |
| LightGBM | `models/tuned/lightgbm_model.R` | CV early stopping |
| Stacked Ensemble | `models/tuned/stack_models.R` | OOF XGBoost + RF with logistic meta learner |

### Ensemble Methods

The `evaluate/eval_combinations.R` module supports two ensemble strategies:

**Probability averaging** — takes the mean predicted probability across multiple models. Best when models are calibrated and make independent errors.

**Majority vote** — takes the modal predicted class across models. Best for hard classification tasks.

Pre-built ensembles in `run_all_evaluate.R`:
- `logistic_ridge_avg` — logistic + ridge average
- `logistic_lasso_avg` — logistic + lasso average
- `logistic_elastic_avg` — logistic + elastic net average
- `top3_avg` — logistic + ridge + elastic net average

---

## Feature Analysis

Before modeling, all features are analyzed individually and collectively for their relationship to the `smoking` outcome. Results are saved to `data/results/`.

**Correlation** (`feature_analysis/correlation.R`)
Pearson correlation between each numeric feature and `smoking`. Measures linear relationship strength. Saved to `correlation.csv` and `correlation.png`.

**ANOVA** (`feature_analysis/anova_test.R`)
One-way ANOVA F-statistic for each numeric predictor grouped by smoking status. High F-statistic indicates the feature separates smokers from non-smokers. Saved to `anova_results.csv`.

**Chi-Square** (`feature_analysis/chi_square_test.R`)
Tests independence between factor predictors and the smoking outcome. Applied only when factor columns are present.

**Mutual Information** (`feature_analysis/mutual_info.R`)
Captures nonlinear relationships that Pearson correlation misses. Uses the `infotheo` package with equal-frequency discretization. Saved to `mutual_info.csv`.

**Random Forest Importance** (`feature_analysis/feature_importance.R`)
MeanDecreaseGini from a 500-tree random forest. Reflects the overall contribution of each feature to classification quality. Saved to `feature_importance.csv` and `feature_importance.png`.

**Unified Predictor Weights** (`feature_analysis/weight_predictors.R`)
Each of the three importance scores (correlation, ANOVA F-statistic, RF importance) is normalized to [0, 1] and averaged into a single `combined` weight per feature. Saved to `predictor_weights.csv`.

---

## Results

All results are generated on a held-out validation set (3,000 records, 20% of training data). The Kaggle test set has no labels and is used only for submission.

**Baseline leaderboard:**

| Model | AUC | Accuracy | F1 |
|---|---|---|---|
| XGBoost | 0.8919 | 0.811 | 0.754 |
| Random Forest | 0.8855 | 0.800 | 0.741 |
| Logistic Regression | 0.8700 | 0.782 | 0.716 |
| LASSO | 0.8699 | 0.783 | 0.718 |
| Elastic Net | 0.8698 | 0.783 | 0.703 |
| Ridge | 0.8662 | 0.775 | 0.710 |
| Naive Bayes | — | 0.742 | — |
| KNN (k=5) | — | 0.690 | — |

**Key findings from feature analysis:**

Hemoglobin is the single strongest predictor of smoking status across all three analysis methods (correlation, ANOVA, RF importance). This aligns with known physiology: smoking elevates carboxyhemoglobin and alters red blood cell production.

Gamma-glutamyl transferase (Gtp) and the liver enzyme panel (AST, ALT) are consistently high-ranking features. Chronic smoking is associated with elevated hepatic stress markers.

Triglyceride and HDL individually rank highly, and their ratio (triglyceride/HDL) is a well-established cardiovascular smoking marker.

The id column contributes no signal and is removed in all tuned model pipelines via `remove_id()`.

LASSO selected 22 of 23 available features at the optimal lambda, confirming that nearly all clinical markers carry predictive signal for smoking status.

---

## Testing

The project uses `testthat` for all unit tests. Tests are isolated, use synthetic data, and do not depend on the competition dataset.

**Run all tests:**

```bash
Rscript tests/run_all_tests.R
```

**Test coverage:**

| Module | Test Files |
|---|---|
| `preprocessing/data_cleaning` | 8 files |
| `preprocessing/data_transformation` | 4 files |
| `preprocessing/feature_engineering` | 2 files |
| `preprocessing/dimensionality_reduction` | 3 files |
| `cross_validate` | 6 files |
| `train` | 5 files |
| `feature_analysis` | 3 files |
| `models` | 5 files |
| `models/tuned` | 2 files |
| `evaluate` | 4 files |

**Total: 42 tests, all passing (WE — warning/error free)**

Each test follows the pattern:

```r
test_that("function does exactly one thing", {
  df  <- data.frame(...)     # minimal synthetic input
  out <- function_under_test(df, ...)
  expect_*(out, ...)         # one specific assertion
})
```

---

## Design Principles

**One file, one job.** Every `.R` file contains exactly one function or a tightly related pair of functions. Orchestration files (`run_all_*.R`) contain no logic — only `source()` calls and variable assignments.

**One function, one responsibility.** Functions are named with a verb that describes exactly what they do: `correlate_features`, `cap_outliers`, `make_xgb_matrix`. Functions that fit models are separate from functions that predict.

**Docstring on every function.** Each function is preceded by three comment lines: what it takes as input, what it returns, and any important behavioral notes.

```r
#' given a dataframe and response name
#' return fitted logistic regression model
#' response must be binary (0/1 or factor)
run_logistic <- function(df, response) { ... }
```

**Global state flows through named variables.** The pipeline passes data through a small set of well-named global variables: `train_clean`, `test_clean`, `model_results`, `cv_results`, `predictor_weights`. Each orchestrator file documents what it expects and what it produces.

**Reproducibility.** The train/validation split uses `set.seed(42)`. The stacking ensemble uses `set.seed(42)` for fold assignment. All outputs are written to `data/results/` as CSV or PNG files.

**No magic numbers.** Constants (`RESPONSE <- "smoking"`, `K_FOLDS <- 10`, `B <- 1000`) are declared at the top of orchestrator files.

---

## Contributing

This is a course competition project. The repository is public for educational reference.

If you want to extend the pipeline:

1. Add a new model file under `src/models/` following the existing naming and docstring conventions.
2. Add a corresponding test file under `tests/models/` using a small synthetic dataframe.
3. Add the test path to `tests/run_all_tests.R`.
4. Source the new model in the appropriate `run_all_*.R` orchestrator.

---

## License

MIT