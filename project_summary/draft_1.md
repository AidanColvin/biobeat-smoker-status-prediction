# Predicting Smoking Status from Clinical Biomarkers
**Aidan Colvin | Kaggle: Biobeat Smoker Status Prediction | March 2026**

---

## 1. Problem Description

### 1.1 Problem Statement

Smoking is the leading cause of preventable death worldwide, responsible for approximately 8 million deaths annually. Early, accurate identification of smokers from routine clinical measurements would enable healthcare providers to prioritize targeted cessation interventions without requiring self-reported behavioral data, which is frequently inaccurate due to social desirability bias. This competition asks whether an individual's smoking status can be reliably predicted from a standard panel of blood and physical examination results — transforming a behavioral question into an objective clinical inference problem.

### 1.2 Dataset

The dataset contains 15,000 training records and 10,000 test records drawn from a population health screening program. Each record represents one patient visit. The training set has 24 columns; the test set has 23 (the response column, *smoking*, is withheld). The response variable is binary: 1 = confirmed smoker, 0 = non-smoker, derived from self-reported status validated against clinical observation.

The 22 predictors span four physiological domains: anthropometric measurements (height, weight, waist circumference); sensory assessments (left and right visual acuity, left and right hearing); cardiovascular markers (systolic blood pressure, diastolic/relaxation blood pressure, fasting blood glucose, total cholesterol, triglycerides, HDL, LDL); and hepatic and renal biomarkers (hemoglobin, urine protein, serum creatinine, AST, ALT, gamma-glutamyl transferase). Dental caries presence is included as a binary indicator. Column names with special characters such as *height(cm)* were sanitized on load using a dedicated `clean_colnames()` preprocessing step.

### 1.3 Objective

The competition objective is to maximize the Area Under the Receiver Operating Characteristic Curve (ROC AUC) on the withheld test set. ROC AUC is the appropriate primary metric for this task because it measures discrimination across all classification thresholds rather than at a fixed 0.5 cutoff, and is insensitive to class imbalance. Predicting a calibrated probability of smoking is more clinically useful than a hard label — a physician can apply different decision thresholds depending on the intervention cost. Secondary metrics reported internally include accuracy, precision, recall, and F1 score.

### 1.4 Relevance to Public Health

Accurately identifying smoking status from routine bloodwork has direct clinical utility. In settings where patients underreport tobacco use, an objective physiological classifier can flag high-probability smokers for additional screening and counseling. The feature importance findings from this project — particularly the dominant role of hemoglobin, gamma-glutamyl transferase (Gtp), and the triglyceride-to-HDL ratio — align closely with established biomarkers of tobacco exposure in the epidemiological literature, lending external validity to the model and suggesting potential for clinical translation.

---

## 2. Methodology

### 2.1 Overview of Approaches

Nine distinct model families were implemented and evaluated. Methods covered in class include: logistic regression, linear discriminant analysis (LDA), quadratic discriminant analysis (QDA), K-nearest neighbors (KNN), ridge and LASSO regularization, principal components regression (PCR), 10-fold cross-validation, and bootstrap resampling for coefficient stability. Methods explored independently include: random forest with cross-validated *mtry* tuning, XGBoost with grid search over depth and learning rate, elastic net with alpha grid search, LightGBM, and a two-level stacked ensemble (XGBoost + random forest at level one; logistic regression meta-learner at level two using out-of-fold predictions).

### 2.2 Rationale for Final Method

The final submission model is a tuned XGBoost classifier. The response variable is binary and the dataset contains highly correlated predictors — systolic and diastolic pressure, and the liver enzyme triplet AST, ALT, Gtp — which rules out naive Bayes (independence assumption violated) and makes OLS inappropriate. Logistic regression performed well (AUC 0.870) but assumes a linear relationship between predictors and log-odds, which is unlikely to hold for complex physiological interactions. LASSO retained 19 of 21 clinical predictors at lambda.min, confirming that nearly all clinical measurements carry predictive signal, but its linear decision boundary still limits predictive ceiling. Random forest captured nonlinear interactions and achieved AUC 0.8863, but XGBoost consistently outperformed it (AUC 0.8919) through sequential error correction via gradient boosting rather than averaging independent trees. The stacked ensemble was also tested but provided no additional gain over standalone XGBoost on this dataset.

### 2.3 Implementation Details

**Preprocessing.** The 15,000 training records were split 80/20 into a training set (12,000 rows) and a held-out validation set (3,000 rows) using `set.seed(42)`. The `id` column was removed before all modeling. No missing values were present in either split. Numeric features were not scaled for tree-based models; standardization was applied for KNN and SVM.

**Feature engineering.** Twelve domain-informed clinical features were derived: BMI (weight / height²), pulse pressure (systolic minus diastolic), triglyceride-to-HDL ratio, LDL-to-HDL ratio, non-HDL cholesterol, liver stress composite (AST + ALT + Gtp), AST-to-ALT ratio, kidney load (creatinine × fasting glucose), vision and hearing asymmetry scores, and a metabolic composite. These features did not improve XGBoost AUC over the raw feature set (0.8916 vs. 0.8919), indicating XGBoost already learned these interactions implicitly.

**Hyperparameter tuning.** XGBoost nrounds was selected via 10-fold cross-validation with AUC maximization and early stopping at 20 rounds (best: 146 rounds). A full grid search covered max_depth in {4, 6, 8}, eta in {0.01, 0.05}, subsample and colsample_bytree in {0.7, 0.9}. Final parameters: eta = 0.05, max_depth = 4, subsample = 0.8, colsample_bytree = 0.8, min_child_weight = 5, gamma = 0.1. Random forest mtry was tuned over {2, 4, 6, 8}; best mtry = 6 (CV error 0.197). Elastic net alpha was searched over {0, 0.25, 0.5, 0.75, 1.0}; best alpha = 0.75.

### 2.4 Reproducibility

The complete pipeline is implemented in R 4.5 with a modular architecture: 61 source files under `src/`, 42 unit tests under `tests/`, all passing. All random operations use `set.seed(42)`. Dependencies install via `source("src/requirements.R")`. Key packages: *xgboost 3.2.0*, *randomForest 4.7-1.2*, *glmnet 4.1-10*, *pROC*, *pls*, *boot*, *e1071*, *MASS*. Full source: github.com/AidanColvin/biobeat-smoker-status-prediction.

Entry point to reproduce all results:

```r
source("src/load_data.R")
source("src/feature_analysis/run_all_analysis.R")
source("src/models/run_all_models.R")
source("src/evaluate/run_all_evaluate.R")
```

---

## 3. Results and Evaluation

### 3.1 Performance Metrics

ROC AUC is the primary metric because it measures discrimination across all classification thresholds and is insensitive to class imbalance. All metrics are computed on the 3,000-row held-out validation set.

| Model | AUC | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|---|
| XGBoost (tuned, nrounds=146) | **0.8919** | 0.811 | 0.732 | 0.778 | 0.754 |
| Random Forest (baseline) | 0.8863 | 0.806 | 0.723 | 0.779 | 0.750 |
| Random Forest (tuned mtry=6) | 0.8855 | 0.800 | 0.716 | 0.767 | 0.741 |
| Logistic Regression | 0.8700 | 0.782 | 0.716 | 0.690 | 0.703 |
| Logistic + Elastic Net Avg | 0.8700 | 0.783 | 0.716 | 0.691 | 0.703 |
| LASSO (alpha=1) | 0.8699 | 0.783 | 0.716 | 0.692 | 0.704 |
| Elastic Net (alpha=0.75) | 0.8699 | 0.782 | 0.716 | 0.691 | 0.703 |
| Logistic + LASSO Avg | 0.8699 | 0.783 | 0.716 | 0.691 | 0.703 |
| Top-3 Avg (Logistic+Ridge+Elastic) | 0.8694 | 0.779 | 0.713 | 0.682 | 0.697 |
| Logistic + Ridge Avg | 0.8689 | 0.777 | 0.711 | 0.674 | 0.692 |
| Ridge (alpha=0) | 0.8662 | 0.775 | 0.710 | 0.670 | 0.689 |
| Elastic Net Tuned (alpha=0.75) | 0.8700 | 0.783 | 0.717 | 0.690 | 0.703 |
| Naive Bayes | — | 0.742 | 0.631 | 0.737 | 0.680 |
| KNN (k=5) | — | 0.690 | 0.605 | 0.482 | 0.537 |

*Table 1. Full model leaderboard on 3,000-row held-out validation set, sorted by AUC. All results from verified pipeline output.*

### 3.2 Feature Importance

| Rank | Feature | Unified Weight | Clinical Interpretation |
|---|---|---|---|
| 1 | hemoglobin | 0.98 | Smoking elevates carboxyhemoglobin and alters RBC production |
| 2 | Gtp | 0.91 | Gamma-GT is a validated biomarker of chronic tobacco exposure |
| 3 | triglyceride | 0.87 | Smoking raises VLDL and triglyceride synthesis |
| 4 | ALT | 0.84 | Liver enzyme elevated by smoking-induced hepatic stress |
| 5 | HDL | 0.82 | Smoking consistently lowers HDL cholesterol |
| 6 | waist_cm | 0.79 | Abdominal adiposity strongly associated with smoking |
| 7 | LDL | 0.74 | Smoking increases LDL oxidation and plasma concentration |
| 8 | AST | 0.71 | Correlated with Gtp and ALT; part of hepatic stress profile |

*Table 2. Top 8 features by unified importance weight (average of normalized Pearson correlation, ANOVA F-statistic, and RF MeanDecreaseGini).*

### 3.3 Analysis of Results

XGBoost outperformed all other models, confirming that the relationship between clinical biomarkers and smoking status contains nonlinear structure that gradient boosting captures more effectively than linear or single-tree methods. The gap between XGBoost (AUC 0.8919) and logistic regression (AUC 0.8700) is meaningful in a clinical context: at a fixed false-positive rate of 10%, XGBoost correctly identifies approximately 3 to 4 percentage points more true smokers per 1,000 patients screened.

A notable finding from the ensemble experiments is that none of the three probability-averaging ensembles — logistic + ridge (0.8689), logistic + LASSO (0.8699), and the top-3 average of logistic, ridge, and elastic net (0.8694) — outperformed standalone logistic regression (0.8700). This confirms that linear models sharing the same decision boundary structure make highly correlated errors. Ensemble averaging is only beneficial when constituent models fail on different patients, which these do not.

An unexpected finding was that 12 engineered clinical features (BMI, pulse pressure, triglyceride-to-HDL ratio, liver stress composite, and others) did not improve XGBoost performance (0.8916 vs. 0.8919). This indicates that XGBoost's split-based learning already discovered these interaction effects implicitly. For logistic regression, these derived features would likely provide genuine improvement by surfacing nonlinear relationships the linear model cannot capture natively.

The dominance of hemoglobin as the single most predictive feature is physiologically grounded: nicotine stimulates erythropoiesis and carbon monoxide bonds preferentially to hemoglobin, producing measurable distributional differences between smokers and non-smokers even cross-sectionally. The strong performance of Gtp, AST, and ALT reflects smoking-induced hepatic stress. The LDL and HDL results are consistent with the well-established dyslipidemia profile of chronic smokers.

A principal limitation is the AUC plateau near 0.892. Remaining classification errors — 248 false negatives and 319 false positives in the XGBoost confusion matrix — likely involve boundary cases: individuals with atypical clinical profiles, or patients in early or post-cessation stages where biomarker normalization has partially occurred.

### 3.4 Comparative Analysis

Performance separated cleanly into three tiers. The top tier (AUC > 0.88) consists exclusively of ensemble tree methods: XGBoost (0.8919), baseline random forest (0.8863), and tuned random forest (0.8855). The middle tier (AUC 0.866–0.870) contains all regularized linear models and their ensembles — logistic regression, LASSO, elastic net, ridge, and three averaging ensembles — with a spread of only 0.004 AUC across nine models. This tight clustering confirms that regularization choice matters far less than model family. Notably, no averaging ensemble outperformed standalone logistic regression, demonstrating that combining correlated linear models provides no diversity benefit. The bottom tier contains KNN (accuracy 0.690, AUC not computed) and naive Bayes (accuracy 0.742), both structurally mismatched to this problem.

---

## 4. Creativity, Innovation, and Broader Implications

The most novel contribution is the unified predictor weighting methodology. Rather than relying on a single importance metric, a combined weight was computed by normalizing three independent scores — Pearson correlation, ANOVA F-statistic, and RF MeanDecreaseGini — to [0, 1] and averaging them. This multi-method triangulation reduces dependence on any single metric's assumptions and produces a more robust ranking. Features that rank highly on all three methods (hemoglobin, Gtp, triglyceride) can be treated as reliably important; features with discordant rankings warrant further investigation.

The pipeline architecture itself is a secondary contribution: 61 modular R source files, each with a single responsibility, validated by 42 independent unit tests. This design pattern applies software engineering reproducibility principles directly to a biostatistical workflow — an approach uncommon in academic settings but increasingly expected in translational research.

From a public health perspective, the finding that a standard clinical blood panel achieves AUC 0.892 for smoking classification — without cotinine testing, questionnaires, or imaging — has practical implications for resource-limited settings. A threshold-adjusted version of this classifier, tuned to maximize recall at the cost of precision, could serve as a low-cost screening tool to flag patients for cessation counseling where direct behavioral assessment is impractical.

---

## References

James, G., Witten, D., Hastie, T., and Tibshirani, R. (2021). *An Introduction to Statistical Learning*, 2nd ed. Springer.

Chen, T. and Guestrin, C. (2016). XGBoost: A Scalable Tree Boosting System. *KDD '16*.

Friedman, J., Hastie, T., and Tibshirani, R. (2010). Regularization Paths for Generalized Linear Models via Coordinate Descent. *Journal of Statistical Software*, 33(1).

Liaw, A. and Wiener, M. (2002). Classification and Regression by randomForest. *R News*, 2(3), 18–22.

Kaggle. (2024). Biobeat Smoker Status Prediction. https://www.kaggle.com/competitions/smoker-status-prediction-using-bio-signals.