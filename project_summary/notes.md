# Writing Notes and Data Reference
## Biobeat Smoker Status Prediction — Report Reference Sheet

---

## Hard Numbers — SOURCED DIRECTLY FROM TERMINAL OUTPUT

### Dataset (confirmed from pipeline log)
- Training set: 12,000 rows × 24 cols (post-split)
- Validation set (held-out 20%): 3,000 rows × 24 cols
- Kaggle test set: 10,000 rows × 23 cols (no smoking label)
- Original labeled data: 15,000 rows
- Train/val split: 80/20, seed = 42
- Response variable: `smoking` — binary integer (0 = non-smoker, 1 = smoker)
- Missing values: none in either split (confirmed — no imputation needed)
- Total non-response columns: 23 (id + 22 clinical predictors)
- Column name issue: raw CSV uses `height(cm)`, `weight(kg)`, `waist(cm)` — parentheses break R formula parser — fixed by `clean_colnames()` via regex

### Packages (from terminal output)
- randomForest 4.7-1.2
- glmnet 4.1-10
- pROC (version confirmed loaded)

---

## Full Model Leaderboard — EXACT NUMBERS FROM TERMINAL

### Baseline models (from `model_comparison.csv` output)

| Model | AUC | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|---|
| random_forest | 0.8863 | 0.8063 | 0.7228 | 0.7791 | 0.7499 |
| logistic | 0.8700 | 0.7823 | 0.7159 | 0.6896 | 0.7025 |
| logistic_elastic_avg | 0.8700 | 0.7827 | 0.7161 | 0.6905 | 0.7031 |
| lasso | 0.8699 | 0.7830 | 0.7160 | 0.6923 | 0.7040 |
| elastic_net | 0.8699 | 0.7823 | 0.7155 | 0.6905 | 0.7028 |
| logistic_lasso_avg | 0.8699 | 0.7827 | 0.7161 | 0.6905 | 0.7031 |
| top3_avg | 0.8694 | 0.7790 | 0.7128 | 0.6816 | 0.6968 |
| logistic_ridge_avg | 0.8689 | 0.7767 | 0.7113 | 0.6744 | 0.6924 |
| ridge | 0.8662 | 0.7750 | 0.7100 | 0.6699 | 0.6894 |
| naive_bayes | NA | 0.7417 | 0.6314 | 0.7370 | 0.6801 |
| knn_k5 | NA | 0.6897 | 0.6049 | 0.4821 | 0.5366 |

### Tuned models (from `tuned_comparison.csv` output)

| Model | AUC | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|---|
| xgboost | **0.8919** | 0.8110 | 0.7317 | 0.7782 | 0.7542 |
| rf_tuned | 0.8855 | 0.8000 | 0.7162 | 0.7674 | 0.7409 |
| elastic_tuned | 0.8700 | 0.7827 | 0.7165 | 0.6896 | 0.7028 |

**KEY OBSERVATION:** No averaging ensemble beat standalone logistic regression (0.8700). All four ensembles (logistic+ridge=0.8689, logistic+lasso=0.8699, logistic+elastic=0.8700, top3=0.8694) match or trail logistic. Linear model ensembles share correlated errors — averaging does not help.

---

## All Confusion Matrices — EXACT FROM TERMINAL
### Format: rows = predicted, cols = actual → [predicted 0, actual 0]=TN, [predicted 0, actual 1]=FN, [predicted 1, actual 0]=FP, [predicted 1, actual 1]=TP

**logistic:**
```
predicted 0: TN=1576, FN=347
predicted 1: FP=306,  TP=771
```
Sensitivity=68.96% | Specificity=83.74%

**ridge:**
```
predicted 0: TN=1576, FN=369
predicted 1: FP=306,  TP=749
```
Sensitivity=67.00% | Specificity=83.74%

**lasso:**
```
predicted 0: TN=1575, FN=344
predicted 1: FP=307,  TP=774
```
Sensitivity=69.23% | Specificity=83.69%

**elastic_net:**
```
predicted 0: TN=1575, FN=346
predicted 1: FP=307,  TP=772
```
Sensitivity=69.05% | Specificity=83.69%

**naive_bayes:**
```
predicted 0: TN=1401, FN=294
predicted 1: FP=481,  TP=824
```
Sensitivity=73.70% | Specificity=74.44%

**random_forest (baseline):**
```
predicted 0: TN=1548, FN=247
predicted 1: FP=334,  TP=871
```
Sensitivity=77.91% | Specificity=82.26%

**knn_k5:**
```
predicted 0: TN=1530, FN=579
predicted 1: FP=352,  TP=539
```
Sensitivity=48.21% | Specificity=81.30%

**logistic_ridge_avg (ensemble):**
```
predicted 0: TN=1576, FN=364
predicted 1: FP=306,  TP=754
```
AUC=0.8689

**logistic_lasso_avg (ensemble):**
```
predicted 0: TN=1576, FN=346
predicted 1: FP=306,  TP=772
```
AUC=0.8699

**logistic_elastic_avg (ensemble):**
```
predicted 0: TN=1576, FN=346
predicted 1: FP=306,  TP=772
```
AUC=0.8700

**top3_avg (logistic+ridge+elastic ensemble):**
```
predicted 0: TN=1575, FN=356
predicted 1: FP=307,  TP=762
```
AUC=0.8694

**rf_tuned (mtry=6):**
```
predicted 0: TN=1542, FN=260
predicted 1: FP=340,  TP=858
```
Sensitivity=76.74% | Specificity=81.94% | AUC=0.8855

**xgboost (nrounds=146):**
```
predicted 0: TN=1563, FN=248
predicted 1: FP=319,  TP=870
```
Sensitivity=77.82% | Specificity=83.04% | AUC=0.8919

**elastic_tuned (alpha=0.75):**
```
predicted 0: TN=1577, FN=347
predicted 1: FP=305,  TP=771
```
Sensitivity=68.96% | Specificity=83.79% | AUC=0.8700

### XGBoost vs Logistic — key comparison for report
- XGBoost: 870 TP, 248 FN, 319 FP → catches 99 MORE true smokers, 13 more FP
- Logistic: 771 TP, 347 FN, 306 FP
- XGBoost catches 99 more smokers at a cost of 13 more false referrals — favorable tradeoff for screening

---

## Tuning Parameters — EXACT FROM TERMINAL

- XGBoost best nrounds: 146 (10-fold CV with AUC maximization)
- RF best mtry: 6 (searched: 2, 4, 6, 8, 7 — CV error at mtry=6: 0.1973)
- Elastic net best alpha: 0.75 (searched: 0, 0.25, 0.5, 0.75, 1 — CV AUC: 0.87)
- XGBoost final params (from prior tuning session): eta=0.05, max_depth=4, subsample=0.8, colsample_bytree=0.8, min_child_weight=5, gamma=0.1

---

## LASSO Feature Selection — CORRECTION FROM TERMINAL

**What the terminal actually shows:**
"lasso selected features: (Intercept), id, age, height_cm, weight_kg, eyesight_left, eyesight_right, hearing_left, hearing_right, systolic, relaxation, Cholesterol, triglyceride, HDL, LDL, hemoglobin, Urine_protein, serum_creatinine, AST, ALT, Gtp, dental_caries"

**Correct interpretation:**
- LASSO kept 21 of 23 predictors (including `id`, which is noise)
- LASSO appears to have shrunk `waist_cm` and `fasting_blood_sugar` to zero (they are absent from the selected list)
- `id` was NOT removed before baseline models ran — only the tuned pipeline removes id first
- This is a mild inconsistency in the baseline pipeline: LASSO retained a meaningless row identifier while dropping two real clinical predictors

**What this means for the report:**
- Do NOT say "LASSO kept 22/23 features, dropping only id" — that was wrong
- Correct claim: "LASSO retained 21 of 23 features at lambda.min; notably, it retained the id column (a meaningless row identifier) while shrinking waist circumference and fasting blood sugar to zero, suggesting these two features contributed minimal marginal signal once the other 19 clinical predictors were included"
- The claim that "nearly all clinical features are predictive" still holds — 19 of 21 real predictors were kept
- The tuned pipeline correctly removes id before XGBoost and RF, so those models are not affected

---

## Feature Importance (unified weight — normalized avg of Pearson r, ANOVA F, RF Gini)
*(from feature_analysis output — not directly printed in terminal log above)*
- Rank 1: hemoglobin — 0.98
- Rank 2: Gtp — 0.91
- Rank 3: triglyceride — 0.87
- Rank 4: ALT — 0.84
- Rank 5: HDL — 0.82
- Rank 6: waist_cm — 0.79
- Rank 7: LDL — 0.74
- Rank 8: AST — 0.71
- Rank 9: age — 0.68
- Rank 10: weight_kg — 0.61

Note: waist_cm ranks #6 in importance but was dropped by LASSO — possible multicollinearity suppression (weight and BMI capture similar signal).

---

## Engineering Features Built (12 total — did NOT improve XGBoost: 0.8916 vs 0.8919)
- BMI = weight_kg / (height_cm/100)^2
- pulse_pressure = systolic - relaxation
- cholesterol_ratio = HDL / Cholesterol
- liver_stress = AST + ALT + Gtp
- ast_alt_ratio = AST / ALT
- kidney_load = serum_creatinine * fasting_blood_sugar
- vision_asymmetry = abs(eyesight_left - eyesight_right)
- hearing_asymmetry = abs(hearing_left - hearing_right)
- triglyceride_hdl = triglyceride / HDL
- non_hdl_chol = Cholesterol - HDL
- ldl_hdl_ratio = LDL / HDL
- metabolic_score = bmi + triglyceride_hdl + (systolic / 120)

---

## Pipeline Stats
- Total source files: 61 under src/
- Total test files: 42 under tests/
- All tests: passing (WE — warning/error free)
- R version: 4.5
- randomForest 4.7-1.2 (confirmed from terminal)
- glmnet 4.1-10 (confirmed from terminal)
- GitHub: github.com/AidanColvin/biobeat-smoker-status-prediction

---

## Claims That Are Defensible

- XGBoost AUC 0.8919 — exact from terminal ✓
- Baseline RF AUC 0.8863, tuned RF 0.8855 — exact from terminal ✓
- XGBoost outperforms logistic by 0.0219 AUC (0.8919 vs 0.8700) ✓
- XGBoost catches 99 more true smokers than logistic (870 vs 771 TP) at cost of 13 more FP (319 vs 306) ✓
- No averaging ensemble beat standalone logistic regression — all four at or below 0.8700 ✓
- Linear model ensembles make correlated errors — this is empirically demonstrated, not just asserted ✓
- 9 models spanning only 0.004 AUC (0.8662 to 0.8700) in the linear tier ✓
- XGBoost nrounds=146 selected by 10-fold CV ✓
- RF best mtry=6, CV error 0.1973 ✓
- Elastic net best alpha=0.75 ✓
- Engineered features did not improve XGBoost (Δ AUC = −0.0003) ✓
- AUC ceiling near 0.892 (stacked ensemble also 0.8919, no gain over standalone XGBoost) ✓

## Claims to Avoid or Hedge

- Do NOT say "LASSO kept 22/23 features dropping only id" — WRONG. LASSO kept id and dropped waist_cm and fasting_blood_sugar. Correct: "LASSO retained 19 of 21 clinical predictors" or discuss waist_cm anomaly
- Do NOT claim engineered features help logistic regression — untested hypothesis only
- Do NOT state Kaggle leaderboard score — you only have internal validation AUC
- Do NOT claim LightGBM results — not run successfully in this pipeline
- Do NOT say the stacking ensemble "failed" — it matched XGBoost (0.8919), which is correct behavior

---

## Rubric-Specific Writing Notes

### Problem Description (20 pts)
- Name all 22 features grouped by physiological domain — earns dataset description points
- State ROC AUC as metric and explain WHY: threshold-agnostic, handles class imbalance, clinically useful probability output
- 8 million deaths/year or 1.3 billion smokers worldwide — one of these opens the relevance section
- Tie the hemoglobin finding to cotinine testing comparison for clinical relevance sub-criterion

### Methodology (30 pts — highest value section)
- List EVERY method by name — rubric says "including both those covered in class and those learned independently"
- Argue AGAINST naive Bayes, KNN, PCR, and linear models BEFORE arguing for XGBoost — elimination reasoning scores higher
- For reproducibility: rubric calls out "code snippets" and "software versions" explicitly — use the 4-line source() block and the package version numbers from terminal
- Say "10-fold cross-validation" by name — it's a class method

### Results (25 pts)
- Two tables minimum: model leaderboard + feature importance
- The engineered feature non-result is a genuine "unexpected outcome" — rubric calls this out specifically
- Hemoglobin dominance deserves its own paragraph — most defensible scientific finding
- Include confusion matrix for XGBoost (TP=870, FN=248, FP=319, TN=1563) — concrete numbers add credibility
- The ensemble failure is also a result worth analyzing — rubric rewards "strengths and weaknesses"
- The LASSO anomaly (kept id, dropped waist_cm) is a weakness to mention briefly

### Creativity (10 pts — most often lost)
- Lead with the unified predictor weighting system — three-method triangulation is the novel contribution
- The waist_cm LASSO anomaly is actually a subtle insight: multicollinearity can cause LASSO to drop high-importance features when correlated features cover the same variance
- The ensemble diversity insight (correlated errors = no benefit) is a genuine analytical finding, not just a reported number
- Modular architecture argument is secondary — mention but don't overweight

### Page Limit (3 pages = ~1800–2200 words + tables)
- Tables are worth more per inch than prose — use them
- Cut first if over limit: full confusion matrices for all 11 models, LightGBM mention, LASSO feature list
- Never cut: XGBoost confusion matrix, feature importance table, hemoglobin paragraph, reproducibility code block

---

## Good Sentences to Carry Forward

"Transforming a behavioral question into an objective clinical inference problem."

"No probability-averaging ensemble exceeded standalone logistic regression — a direct empirical demonstration that ensemble diversity, not ensemble size, determines ensemble value."

"The four regularized linear models and their three averaging combinations span only 0.004 AUC — confirming that regularization form matters far less than model family."

"XGBoost's split-based learning already discovered these interaction effects implicitly."

"Features that rank highly on all three importance methods can be treated as reliably important regardless of model family; features with discordant rankings are model-dependent and warrant caution."

"The physiological footprint of smoking is distributed across the entire metabolic system rather than concentrated in a few organ-specific markers."

"A classifier that identifies probable smokers from bloodwork already being collected creates no additional patient burden and no additional cost."

"XGBoost identifies 99 more true smokers than logistic regression at a cost of only 13 additional false referrals — a favorable tradeoff in any screening context where missing a smoker is more costly than an unnecessary counseling visit."

---

## Clinical / Scientific Context

### Hemoglobin and smoking
- Carbon monoxide from tobacco smoke binds hemoglobin with ~200× affinity of oxygen → carboxyhemoglobin persists in circulation
- Nicotine stimulates erythropoiesis via hypoxia-inducible factor pathway → elevated hemoglobin in chronic smokers
- Both effects create measurable population-level distributional shift even in cross-sectional data
- Ranks #1 by all three importance methods — not a statistical artifact

### Gtp and smoking
- Gamma-glutamyl transferase: validated biomarker of oxidative stress and chronic toxic exposure
- Elevated Gtp in smokers = hepatic microsomal enzyme induction by tobacco compounds
- Same mechanism as alcohol-induced Gtp elevation — well established in clinical literature

### Lipid profile and smoking
- Smoking lowers HDL (impairs reverse cholesterol transport)
- Smoking raises triglycerides via VLDL overproduction
- Triglyceride-to-HDL ratio = strongest single cardiovascular risk composite in smokers
- LDL particles in smokers are small, dense, and oxidized — measured level may understate atherogenic risk

### Why self-reported status is unreliable
- Social desirability bias: 20–30% underreporting rate in population health surveys
- Cotinine assay (urine/blood nicotine metabolite) is gold standard but costly and not routinely ordered
- This is the clinical motivation: replace an unreliable questionnaire with an objective bloodwork classifier

### waist_cm LASSO anomaly — scientific interpretation
- waist_cm ranks #6 in unified importance but was dropped to zero by LASSO
- Most likely explanation: multicollinearity suppression — weight_kg and height_cm together explain the abdominal adiposity variance that waist_cm captures
- LASSO selects ONE representative from each correlated cluster; waist_cm lost to weight_kg
- This is NOT evidence that waist_cm is unimportant — it is evidence of regularization behavior under collinearity
- Worth one sentence in the methodology or analysis as a honest limitation

### Dataset context
- Appears to be Korean national health screening data (KNHANES-style)
- East Asian population health screening includes comprehensive bloodwork for all adults
- Historically high male smoking rates (~40%) in this population — class balance likely ~35–40% smokers

---

## Output Files Generated
- `data/results/model_comparison.csv` — baseline leaderboard
- `data/results/tuned_comparison.csv` — tuned leaderboard
- `data/results/predictor_weights.csv` — unified feature importance
- `data/results/feature_importance.csv` — RF MeanDecreaseGini
- `data/results/anova_results.csv` — F-statistic per feature
- `data/results/mutual_info.csv` — mutual information scores
- `data/results/correlation.csv` / `correlation.png`
- `data/results/feature_importance.png`
- `data/results/roc_logistic.png`, `roc_ridge.png`, `roc_lasso.png`, `roc_elastic_net.png`
- `data/results/roc_elastic_tuned.png`, `roc_rf_tuned.png`, `roc_xgboost.png`
- `data/results/pcr_variance.png`