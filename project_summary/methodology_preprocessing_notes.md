# PREPROCESSING

### Evaluation of Methods for Predicting Smoking Status

**KNN (K-Nearest Neighbors)**
* **Rationale for using:** KNN identifies individuals with similar physical and bloodwork profiles. 
* **Rationale for using:** It uses these similarities to predict smoking status based on proximity.
* **Rationale against using:** KNN is highly sensitive to the scale of the data. 
* **Rationale against using:** A large-scale feature like `height(cm)` will mathematically overpower a small-scale feature like `serum creatinine`.
* **Verdict:** It is not recommended as a primary model due to the 22 features.

**LR (Linear Regression)**
* **Rationale for using:** Linear regression is mathematically simple. 
* **Rationale for using:** It is computationally fast on 15,000 records.
* **Rationale against using:** Linear regression predicts continuous numbers instead of binary outcomes. 
* **Rationale against using:** It can predict impossible probabilities outside the 0 to 1 range.
* **Verdict:** Do not use this method. 
* **Verdict:** The target `smoking` is strictly binary.

**Logistic (Logistic Regression)**
* **Rationale for using:** This is the standard baseline algorithm for binary classification. 
* **Rationale for using:** It explicitly outputs a probability between 0 and 1. 
* **Rationale for using:** It provides clear weights showing exactly how much each clinical metric increases the log-odds of smoking.
* **Rationale against using:** It assumes a strict linear relationship between the clinical predictors and the log-odds of smoking. 
* **Rationale against using:** It may miss complex physiological interactions.
* **Verdict:** This is highly recommended as an interpretable baseline model.

**Naive Bayes**
* **Rationale for using:** It is extremely fast. 
* **Rationale for using:** It handles large feature sets easily.
* **Rationale against using:** It strictly assumes that all features are completely independent of one another. 
* **Rationale against using:** We know explicitly that clinical features like `systolic` and `relaxation` blood pressures are highly correlated. 
* **Verdict:** It is not recommended. 
* **Verdict:** The independence assumption is strongly violated by human physiological data.

**Nonlinearity (e.g., Polynomial Features or Tree-Based Models)**
* **Rationale for using:** Clinical data often contains non-linear relationships. 
* **Rationale for using:** For example, extreme BMI values might correlate with smoking differently than average BMI values. 
* **Rationale against using:** Manually adding non-linear polynomial features increases the risk of overfitting the training data.
* **Verdict:** This is recommended if applied via modern tree-based models to capture complex clinical interactions.

**CV (Cross-Validation)**
* **Rationale for using:** This is an essential evaluation technique rather than a standalone model. 
* **Rationale for using:** It ensures the model generalizes to unseen patient data by testing it across different subsets of the 15,000 records.
* **Rationale against using:** The only downside is increased computational time.
* **Verdict:** This must be used. 
* **Verdict:** It is required to get a realistic estimate of the ROC AUC evaluation metric.

**Bootstrap**
* **Rationale for using:** This resampling technique is excellent for estimating the confidence intervals of the model's accuracy. 
* **Rationale for using:** It is also useful for checking the stability of the feature weights.
* **Rationale against using:** It is highly computationally expensive. 
* **Rationale against using:** Cross-validation is generally more standard and efficient for tuning model performance.
* **Verdict:** Use this only if you need to report explicit confidence intervals for your clinical findings.

**Ridge & LASSO (Regularized Logistic Regression)**
* **Rationale for using:** These methods penalize large feature weights to prevent overfitting. 
* **Rationale for using:** LASSO can shrink the weights of non-predictive clinical markers strictly to zero for automatic feature selection. 
* **Rationale for using:** Ridge handles highly correlated clinical metrics like liver enzymes perfectly.
* **Rationale against using:** They strictly require all clinical features to be perfectly scaled beforehand. 
* **Rationale against using:** LASSO might arbitrarily drop one of two highly correlated features.
* **Verdict:** These are highly recommended. 
* **Verdict:** Combining them handles the correlated medical data while filtering out useless features.

**PCR (Principal Component Regression)**
* **Rationale for using:** It reduces the 22 features into a smaller set of completely uncorrelated components. 
* **Rationale for using:** This completely eliminates multicollinearity issues among the clinical measurements.
* **Rationale against using:** It destroys clinical interpretability. 
* **Rationale against using:** Instead of knowing how `Gtp` impacts smoking, the model outputs a score for a mathematical component that blends all features together. 
* **Verdict:** It is not recommended. 
* **Verdict:** In public health, understanding the specific impact of explicit physiological markers is usually required.

### What is the best method to use and why?

* **The Best Approach:** A regularized Logistic Regression evaluated using Cross-Validation.
* **Why:** The objective requires predicting a probability of a binary event. 
* **Why:** Logistic Regression calculates binary probabilities natively.
* **Why:** The dataset contains highly correlated clinical measurements. 
* **Why:** Regularization methods are specifically designed to manage correlated data.
* **Why:** Cross-validation guarantees that the ROC AUC score is reliable. 
* **Why:** It ensures the score is not the result of overfitting the 15,000 training records.
* **Why:** This approach retains strict interpretability. 
* **Why:** It allows public health officials to identify exactly which clinical features are the strongest predictors of smoking.

# PREPROCESSING

### Overview of Approaches (10 points)

* **States the baseline model:** I implemented a standard Logistic Regression as the initial baseline model.
* **Describes regularization methods:** I tested Ridge and LASSO regression to handle highly correlated clinical features.
* **Provides an explicit data example:** These methods help manage the correlation between `systolic` and `relaxation` blood pressure readings.
* **Describes distance-based methods:** I attempted K-Nearest Neighbors to group similar patient profiles.
* **Describes independently learned tree-based methods:** I independently researched and applied a Random Forest classifier. 
* **Explains the purpose of the independent method:** This was used to capture non-linear relationships in metrics like `age` and `waist(cm)`.

### Rationale for Chosen Method (10 points)

* **States the final choice:** The final chosen method is an Elastic Net Regularized Logistic Regression.
* **Explains suitability for the target:** This method natively outputs the required predicted probabilities for the binary smoking target.
* **Explains suitability for the dataset:** It successfully handles the severe multicollinearity present between clinical measurements.
* **Provides an explicit data example:** It manages the overlap between `Cholesterol`, `HDL`, and `LDL` readings without dropping important data.
* **Explains the constraint consideration:** It is highly computationally efficient on the 15,000-record dataset.
* **Highlights interpretability:** It retains explicit feature weights so public health officials can interpret the exact impact of biomarkers like `hemoglobin`.

### Implementation Details (5 points)

* **Describes the data preprocessing step:** I standardized all 22 clinical features using a scaling transformation.
* **Explains the need for preprocessing:** This equalizes the mathematical impact of large numbers like `height(cm)` and small numbers like `serum creatinine`.
* **Describes the model selection process:** I used a 5-fold cross-validation strategy.
* **Explains the purpose of cross-validation:** This evaluates model performance on unseen patient subsets to prevent overfitting.
* **Describes hyperparameter tuning:** I tuned the regularization strength using a systematic grid search. 
* **States the tuning objective:** The grid search was specifically optimized to maximize the ROC AUC evaluation metric.

### Reproducibility (5 points)

* **States the programming language:** All code was written in Python version 3.10.
* **Lists the core software libraries:** The implementation relies strictly on `pandas` for data handling and `scikit-learn` for machine learning.
* **Explains random state control:** I set the random seed to a fixed integer across all cross-validation splits and model initializations.
* **Explains why the seed is set:** This ensures the exact same patient data splits occur every time the code is run.
* **Mentions code availability and documentation:** The complete code includes clear, concise docstrings for every function to allow exact replication by reviewers.