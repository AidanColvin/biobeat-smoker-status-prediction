library(dplyr)

#' given a dataframe with biobeat clinical columns
#' return dataframe with engineered clinical interaction features appended
#' based on known physiological relationships in smoking research
engineer_clinical_features <- function(df) {
  df %>% mutate(
    bmi              = weight_kg / (height_cm / 100)^2,
    pulse_pressure   = systolic - relaxation,
    cholesterol_ratio = HDL / ifelse(Cholesterol == 0, 1, Cholesterol),
    liver_stress     = AST + ALT + Gtp,
    ast_alt_ratio    = AST / ifelse(ALT == 0, 1, ALT),
    kidney_load      = serum_creatinine * fasting_blood_sugar,
    vision_asymmetry = abs(eyesight_left - eyesight_right),
    hearing_asymmetry = abs(hearing_left - hearing_right),
    triglyceride_hdl  = triglyceride / ifelse(HDL == 0, 1, HDL),
    non_hdl_chol     = Cholesterol - HDL,
    ldl_hdl_ratio    = LDL / ifelse(HDL == 0, 1, HDL),
    metabolic_score  = bmi + triglyceride_hdl + (systolic / 120)
  )
}
