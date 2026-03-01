source("src/feature_analysis/correlation.R")
source("src/feature_analysis/anova_test.R")
source("src/feature_analysis/chi_square_test.R")
source("src/feature_analysis/mutual_info.R")
source("src/feature_analysis/feature_importance.R")
source("src/feature_analysis/weight_predictors.R")

RESPONSE <- "smoking"
OUT_DIR  <- "data/results"
dir.create(OUT_DIR, showWarnings = FALSE)

cor_scores        <- correlate_features(train_clean,     RESPONSE, OUT_DIR)
anova_results     <- run_anova(train_clean,              RESPONSE, OUT_DIR)
chi_results       <- run_chi_square(train_clean,         RESPONSE, OUT_DIR)
mi_scores         <- run_mutual_info(train_clean,        RESPONSE, OUT_DIR)
imp_results       <- run_feature_importance(train_clean, RESPONSE, out_dir = OUT_DIR)
predictor_weights <- weight_predictors(cor_scores, anova_results, imp_results, OUT_DIR)
message("feature analysis complete")
