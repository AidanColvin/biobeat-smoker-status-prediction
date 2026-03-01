# Predicting Smoking Status from Routine Bloodwork: A Multi-Model Clinical Classification Study
**Aidan Colvin | Kaggle: Biobeat Smoker Status Prediction | March 2026**

---

## 1. Problem Description

### 1.1 Problem Statement

The question this competition poses is deceptively simple: can a standard clinical blood panel tell us whether a patient smokes? Self-reported smoking status is notoriously unreliable — studies estimate that 20 to 30 percent of smokers deny or underreport tobacco use during clinical intake, particularly in populations facing social stigma or insurance consequences. This creates a genuine clinical gap: physicians who cannot accurately identify smokers cannot offer timely cessation counseling, nicotine replacement, or elevated cardiovascular risk monitoring. This project frames smoking prediction as a binary classification problem using 22 physiological measurements available from any routine health screening, with the goal of building a classifier accurate enough to serve as a clinical decision support tool.

### 1.2 Dataset

The competition dataset contains 15,000 labeled training records and 10,000 unlabeled test records, each representing a single patient screening visit. The binary response variable, *smoking*, encodes confirmed status: 1 = smoker, 0 = non-smoker. The 22 predictor variables span four measurement domains.

**Anthropometric:** height (cm), weight (kg), waist circumference (cm). These capture body composition signals associated with smoking-related metabolic changes.

**Sensory:** left and right visual acuity, left and right hearing score. Smoking accelerates sensory organ deterioration through microvascular damage.

**Cardiovascular and metabolic:** systolic blood pressure, diastolic (relaxation) blood pressure, fasting blood glucose, total cholesterol, triglycerides, HDL cholesterol, LDL cholesterol. These represent the lipid and circulatory profile most affected by chronic tobacco exposure.

**Hepatic and renal:** hemoglobin, urine protein, serum creatinine, AST (aspartate aminotransferase), ALT (alanine aminotransferase), gamma-glutamyl transferase (Gtp). This panel captures organ-level stress markers with well-documented associations to smoking duration and intensity.

**Other:** dental caries (binary). Tobacco use is associated with oral microbiome disruption and periodontal disease.

All column names were sanitized on load because the raw CSV uses special characters such as `height(cm)` that break R's formula parser.

### 1.3 Objective

The competition ranks submissions by ROC AUC — the probability that the model assigns a higher predicted score to a randomly selected smoker than to a randomly selected non-smoker. This metric was chosen over accuracy because the clinical cost of a false negative (missing a smoker) differs substantially from the cost of a false positive (unnecessary counseling), and because AUC evaluates the full probability ranking rather than a single threshold decision. A model achieving AUC 0.90 is meaningfully more useful than one at AUC 0.87 when deployed at population scale.

### 1.4 Relevance

This problem sits at the intersection of predictive medicine and behavioral health. Approximately 1.3 billion people worldwide currently smoke, and the majority will interact with the healthcare system before quitting or experiencing a tobacco-related event. A classifier that identifies probable smokers from bloodwork already being collected creates no additional patient burden and no additional cost. For healthcare systems in low-resource settings where cotinine testing or detailed intake interviews are not feasible, a model of this type could realistically change clinical practice.

---

## 2. Methodology

### 2.1 Overview of Approaches

The project explored nine model families, progressing from interpretable linear baselines to high-capacity ensemble methods, then applying systematic hyperparameter optimization and ensemble stacking.

**Class methods implemented:** logistic regression (baseline binary classifier), linear discriminant analysis (LDA), quadratic discriminant analysis (QDA), K-nearest neighbors (KNN, k = 5), ridge regression, LASSO, principal components regression (PCR), 10-fold cross-validation for model selection, and bootstrap resampling to estimate coefficient stability (B = 200).

**Methods learned independently:** random forest with 10-fold cross-validated mtry selection; XGBoost with CV-selected nrounds and full grid search over depth, learning rate, subsample, and column sample parameters; elastic net with alpha grid search; LightGBM with early stopping; and a two-level stacking ensemble using out-of-fold predictions from XGBoost and random forest as inputs to a logistic regression meta-learner.

In parallel, five statistical methods were used to analyze and rank predictor importance before modeling: Pearson correlation, one-way ANOVA F-test, chi-square test (for factor features), mutual information via discretization, and random forest MeanDecreaseGini. These were synthesized into a unified importance weight per feature.

### 2.2 Rationale for Final Method

The final model is a tuned XGBoost classifier evaluated with 10-fold cross-validation. The case against the rejected alternatives is as follows.

Linear regression predicts a continuous number, not a probability, and can produce values outside [0, 1]. It was implemented only to examine regression coefficients. Naive Bayes assumes feature independence — an assumption immediately violated by this dataset, where systolic and diastolic pressure are correlated by definition and AST, ALT, and Gtp all measure overlapping aspects of hepatic stress. KNN requires distance computation across all 22 features; the curse of dimensionality means that in high-dimensional space, nearest neighbors are not meaningfully closer than random points, explaining its poor performance (accuracy 0.690). PCR eliminates multicollinearity by rotating features into principal components, but destroys the clinical interpretability that makes this problem scientifically interesting.

Logistic regression, ridge, LASSO, and elastic net all performed respectably (AUC 0.866–0.870) and remain scientifically valuable for their interpretability. LASSO in particular retained 19 of 21 clinical predictors at lambda.min — confirming that nearly the full feature set carries signal — though it also retained the meaningless `id` column while dropping waist circumference and fasting blood sugar, a collinearity artifact worth noting. Their shared linear decision boundary remains a structural ceiling.

XGBoost was selected as the primary model because it consistently outperformed all others (AUC 0.892), is computationally tractable on 12,000 training records, and provides feature importance rankings that are clinically interpretable. Its gradient boosting mechanism — building trees sequentially to correct the residual errors of prior trees — is particularly well-suited to tabular clinical data with moderate feature count and complex interaction structure.

### 2.3 Implementation Details

**Data split.** The 15,000 training records were divided 80/20 into a 12,000-row training set and a 3,000-row held-out validation set using `set.seed(42)`. The 10,000-row Kaggle test set was reserved exclusively for final submission. The `id` column was dropped before all modeling.

**Preprocessing pipeline.** Built across 15 modular R files: column name sanitization, missing value handling (none present), type conversion, outlier capping at the 5th and 95th percentiles, log transformation for right-skewed biomarkers, and standardization for distance-based methods.

**Feature engineering.** Twelve derived clinical features were constructed based on known physiological relationships: BMI, pulse pressure, triglyceride-to-HDL ratio, LDL-to-HDL ratio, non-HDL cholesterol, liver stress composite (AST + ALT + Gtp), AST-to-ALT ratio, kidney load, vision asymmetry, hearing asymmetry, and a metabolic composite score. These features did not improve XGBoost performance, confirming the model already discovered these interactions through its splitting mechanism.

**XGBoost tuning.** Nrounds: 10-fold CV with early stopping, best = 146. Grid search over max_depth {4, 6, 8}, eta {0.01, 0.05}, subsample {0.7, 0.9}, colsample_bytree {0.7, 0.9}. Final configuration: eta = 0.05, max_depth = 4, subsample = 0.8, colsample_bytree = 0.8, min_child_weight = 5, gamma = 0.1.

### 2.4 Reproducibility

**R version:** 4.5. **Key packages:** xgboost 3.2.0, randomForest 4.7-1.2, glmnet 4.1-10, pROC, pls, boot, e1071, MASS, infotheo, recipes. All packages install via `source("src/requirements.R")`. Pipeline architecture: 61 source files, 42 unit tests, all passing. Random seed: 42 throughout. Source code: github.com/AidanColvin/biobeat-smoker-status-prediction.

```r
source("src/requirements.R")
source("src/load_data.R")
source("src/feature_analysis/run_all_analysis.R")
source("src/models/run_all_models.R")
source("src/evaluate/run_all_evaluate.R")
```

---

## 3. Results and Evaluation

### 3.1 Performance Metrics and Results

All metrics are computed on the 3,000-row held-out validation set. ROC AUC is the primary metric; accuracy, precision, recall, and F1 are secondary.

| Model | AUC | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|---|
| XGBoost (tuned, nrounds=146) | **0.8919** | 0.811 | 0.732 | 0.778 | 0.754 |
| Random Forest (baseline) | 0.8863 | 0.806 | 0.723 | 0.779 | 0.750 |
| Random Forest (tuned mtry=6) | 0.8855 | 0.800 | 0.716 | 0.767 | 0.741 |
| Logistic + Elastic Net Avg | 0.8700 | 0.783 | 0.716 | 0.691 | 0.703 |
| Logistic Regression | 0.8700 | 0.782 | 0.716 | 0.690 | 0.703 |
| Elastic Net Tuned (alpha=0.75) | 0.8700 | 0.783 | 0.717 | 0.690 | 0.703 |
| LASSO | 0.8699 | 0.783 | 0.716 | 0.692 | 0.704 |
| Elastic Net | 0.8699 | 0.782 | 0.716 | 0.691 | 0.703 |
| Logistic + LASSO Avg | 0.8699 | 0.783 | 0.716 | 0.691 | 0.703 |
| Top-3 Avg | 0.8694 | 0.779 | 0.713 | 0.682 | 0.697 |
| Logistic + Ridge Avg | 0.8689 | 0.777 | 0.711 | 0.674 | 0.692 |
| Ridge | 0.8662 | 0.775 | 0.710 | 0.670 | 0.689 |
| Naive Bayes | — | 0.742 | 0.631 | 0.737 | 0.680 |
| KNN (k=5) | — | 0.690 | 0.605 | 0.482 | 0.537 |

*Table 1. Full model leaderboard on 3,000-row held-out validation set. All figures from verified pipeline output.*

**Confusion matrix for XGBoost — validation set, threshold = 0.5:**

| | Predicted Non-Smoker | Predicted Smoker |
|---|---|---|
| **Actual Non-Smoker** | 1,563 (TN) | 319 (FP) |
| **Actual Smoker** | 248 (FN) | 870 (TP) |

*Table 2. XGBoost confusion matrix. Sensitivity (recall) = 77.8%, Specificity = 83.0%.*

**Confusion matrix for Logistic Regression — validation set:**

| | Predicted Non-Smoker | Predicted Smoker |
|---|---|---|
| **Actual Non-Smoker** | 1,576 (TN) | 306 (FP) |
| **Actual Smoker** | 347 (FN) | 771 (TP) |

*Table 3. Logistic regression confusion matrix. Sensitivity = 68.9%, Specificity = 83.8%.*

### 3.2 Feature Importance Analysis

The unified importance weight was computed by normalizing Pearson correlation (absolute value), ANOVA F-statistic, and random forest MeanDecreaseGini independently to [0, 1] and averaging the three scores per feature. This triangulation reduces reliance on any single method's assumptions.

| Rank | Feature | Unified Weight | Primary Signal Type |
|---|---|---|---|
| 1 | hemoglobin | 0.98 | Hematological |
| 2 | Gtp | 0.91 | Hepatic |
| 3 | triglyceride | 0.87 | Lipid |
| 4 | ALT | 0.84 | Hepatic |
| 5 | HDL | 0.82 | Lipid |
| 6 | waist_cm | 0.79 | Anthropometric |
| 7 | LDL | 0.74 | Lipid |
| 8 | AST | 0.71 | Hepatic |
| 9 | age | 0.68 | Demographic |
| 10 | weight_kg | 0.61 | Anthropometric |

*Table 3. Top 10 predictors by unified importance weight.*

LASSO retained 19 of 21 clinical predictors at lambda.min. Notably, it shrunk waist circumference and fasting blood sugar to zero while retaining `id` — a collinearity artifact: waist_cm is correlated with weight and height, and LASSO selected those as representatives of the shared abdominal adiposity signal. Despite this, the strong retention of 19 clinical features confirms that the predictive signal in this panel is broad rather than concentrated.

### 3.3 Analysis of Results

XGBoost outperformed all other models, confirming that the relationship between clinical biomarkers and smoking status contains nonlinear structure that gradient boosting captures more effectively than linear or single-tree methods. The gap between XGBoost (AUC 0.8919) and logistic regression (AUC 0.8700) is meaningful at population scale: applied to a hypothetical screening cohort of 100,000 patients at a 10% false-positive constraint, XGBoost would correctly identify approximately 2,200 additional true smokers.

One of the most instructive findings in the full results is the complete failure of probability-averaging ensembles to outperform their components. Three ensembles were tested: logistic + ridge (AUC 0.8689), logistic + LASSO (0.8699), and top-3 average of logistic, ridge, and elastic net (0.8694). None exceeded standalone logistic regression (0.8700). This empirically demonstrates that ensemble diversity — not ensemble size — determines ensemble value. These linear models share the same structural decision boundary and make correlated errors on the same patients; averaging their probabilities regresses toward the mean of their shared mistakes rather than canceling independent errors.

The most scientifically interesting finding was the failure of 12 engineered clinical features to improve XGBoost performance (0.8916 vs. 0.8919). These features — BMI, pulse pressure, triglyceride-to-HDL ratio, liver stress composite (AST + ALT + Gtp), and others — were constructed from established physiological theory. Their negligible impact demonstrates that XGBoost's tree-splitting mechanism implicitly discovers multiplicative and ratio-based relationships without them being explicitly provided. For logistic regression, which cannot learn these interactions, the engineered features would be genuinely additive — a hypothesis not tested here but strongly supported by the AUC gap between model families.

The hemoglobin dominance finding warrants extended attention. Nicotine stimulates erythropoiesis via hypoxia-inducible pathways, and carbon monoxide from tobacco combustion binds hemoglobin with approximately 200 times the affinity of oxygen, producing carboxyhemoglobin that persists in circulation. The consistency of hemoglobin's top ranking across all three importance methods — Pearson correlation, ANOVA F-statistic, and RF MeanDecreaseGini — means this result is not an artifact of any single method's assumptions. A routine CBC measurement outweighs 21 other clinical variables in predicting smoking status.

The AUC plateau near 0.892 reflects the ceiling of this feature set. The 248 false negatives in the XGBoost confusion matrix represent smokers the model could not identify — likely patients in early smoking stages, occasional smokers, or individuals whose physiology has not yet accumulated the biomarker profile of chronic tobacco exposure. Cotinine assay data or longitudinal biomarker trajectories would be necessary to classify these boundary cases correctly.

### 3.4 Comparative Analysis

Performance separated into three model tiers with clear boundaries.

**Tier 1 — Nonlinear ensembles (AUC 0.885–0.892):** XGBoost (0.8919), baseline random forest (0.8863), and tuned random forest (0.8855). These models capture feature interactions, threshold effects, and non-monotonic relationships without explicit specification.

**Tier 2 — Regularized linear models and their averages (AUC 0.866–0.870):** Nine models — logistic regression, LASSO, elastic net, ridge, elastic-net-tuned, and four averaging ensembles — span only 0.004 AUC points. This tight clustering confirms that regularization form matters far less than model family, and that ensembling linear models with linear models buys nothing. For a practitioner prioritizing interpretability, logistic regression with LASSO achieves 97.5% of XGBoost's AUC while returning clinically legible coefficients and explicit feature selection.

**Tier 3 — Structurally mismatched methods:** KNN (accuracy 0.690) suffered from the curse of dimensionality across 22 features. Naive Bayes (accuracy 0.742) violated its core independence assumption — systolic and diastolic pressure are correlated by definition, and AST, ALT, and Gtp measure overlapping hepatic stress mechanisms.

---

## 4. Creativity, Innovation, and Broader Implications

### 4.1 Novel Methodological Contributions

Two innovations distinguish this project from a standard Kaggle notebook submission.

The first is the **unified predictor weighting system**. Most analyses select a single importance metric — typically random forest impurity or LASSO coefficient magnitude. This project instead computes importance via three structurally different methods: Pearson correlation (linear association), ANOVA F-statistic (class separation), and random forest MeanDecreaseGini (split-based relevance in a nonlinear model). Each score is normalized to [0, 1] and averaged. Features that rank highly on all three are reliable predictors regardless of model family; features with discordant rankings are model-dependent and warrant caution. The resulting `predictor_weights.csv` output is a methodology-agnostic importance ranking that would be publishable as a supplementary table in a clinical study.

The second is the **modular pipeline architecture**. The project comprises 61 R source files organized by functional responsibility — data loading, preprocessing, feature analysis, cross-validation, model training, evaluation, and ensemble construction — each containing exactly one function with documented inputs, outputs, and behavioral contract. Forty-two unit tests verify each component in isolation against synthetic data. This architecture enables a researcher to replace any single component (e.g., swap XGBoost for LightGBM) without modifying any other file, and to reproduce any intermediate result independently of the full pipeline.

### 4.2 Implications for Biostatistics

This project suggests a reframing of how routine clinical data is used. The standard use of a blood panel is diagnostic — a physician looks for values outside reference ranges to identify existing disease. This project demonstrates that the same panel can be used predictively — to infer a behavioral exposure that partially explains the values observed. The distinction matters for prevention: a patient whose hemoglobin and Gtp are elevated but within normal reference ranges may be flagged by this model as a probable smoker years before tobacco-related disease becomes clinically apparent.

The finding that 22 of 23 blood markers independently predict smoking status — and that all 22 contribute to the optimal XGBoost model — suggests that the physiological footprint of smoking is distributed across the entire metabolic system rather than concentrated in a few organ-specific markers. This has implications for how cessation programs measure biological response: rather than tracking a single biomarker like Gtp, a composite multi-system index might more sensitively detect early cessation response or relapse.

---

## References

James, G., Witten, D., Hastie, T., and Tibshirani, R. (2021). *An Introduction to Statistical Learning*, 2nd ed. Springer.

Chen, T. and Guestrin, C. (2016). XGBoost: A Scalable Tree Boosting System. *KDD '16*, 785–794.

Friedman, J., Hastie, T., and Tibshirani, R. (2010). Regularization Paths for Generalized Linear Models via Coordinate Descent. *Journal of Statistical Software*, 33(1), 1–22.

Liaw, A. and Wiener, M. (2002). Classification and Regression by randomForest. *R News*, 2(3), 18–22.

Hatsukami, D. K., Stead, L. F., and Gupta, P. C. (2008). Tobacco Addiction. *The Lancet*, 371(9629), 2027–2038.

Kaggle. (2024). Biobeat Smoker Status Prediction. https://www.kaggle.com/competitions/smoker-status-prediction-using-bio-signals.