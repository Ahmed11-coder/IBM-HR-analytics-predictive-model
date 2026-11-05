* Employee Attrition (IBM HR) - final model, ROC and cutoff evaluation.
* Data: IBM_HR_Analysis Data.sav, which already contains the recoded variables
* (JobRole_Final, JobLevel_Final, JobSat_Final, StockOptionLevel_Final,
*  EnvironmentSatisfaction_Final) and the split variable (1 = train 70%, 0 = test 30%).
* NOTE: this file was cleaned up from the pasted syntax and has not been re-run;
* run it once in SPSS and compare with the report before publishing.

* 1) Final logistic regression, fitted on TRAINING rows only (split = 1).
*    /SAVE=PRED stores predicted probabilities (PRE_1) for ALL rows, train and test.
LOGISTIC REGRESSION VARIABLES Attrition
  /SELECT=split EQ 1
  /METHOD=ENTER OverTime JobRole_Final JobLevel_Final JobInvolvement StockOptionLevel_Final
    JobSat_Final YearsWithCurrManager YearsSinceLastPromotion BusinessTravel
    EnvironmentSatisfaction_Final
  /CONTRAST (StockOptionLevel_Final)=Indicator(1)
  /CONTRAST (JobRole_Final)=Indicator(1)
  /CONTRAST (JobInvolvement)=Indicator(1)
  /CONTRAST (JobLevel_Final)=Indicator(1)
  /CONTRAST (BusinessTravel)=Indicator(1)
  /CONTRAST (EnvironmentSatisfaction_Final)=Indicator(1)
  /SAVE=PRED
  /PRINT=GOODFIT CI(95)
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

* 2) ROC curve on the TRAINING set.
USE ALL.
COMPUTE filter_$=(split = 1).
FILTER BY filter_$.
EXECUTE.
ROC PRE_1 BY Attrition (1)
  /PLOT=CURVE(REFERENCE)
  /PRINT=SE
  /CRITERIA=CUTOFF(INCLUDE) TESTPOS(LARGE) DISTRIBUTION(FREE) CI(95)
  /MISSING=EXCLUDE.

* 3) ROC curve on the TEST set.
USE ALL.
COMPUTE filter_$=(split = 0).
FILTER BY filter_$.
EXECUTE.
ROC PRE_1 BY Attrition (1)
  /PLOT=CURVE(REFERENCE)
  /PRINT=SE
  /CRITERIA=CUTOFF(INCLUDE) TESTPOS(LARGE) DISTRIBUTION(FREE) CI(95)
  /MISSING=EXCLUDE.

* 4) Classification at the cutoff 0.268 (chosen on the training set with Youden's J).
COMPUTE pred=(PRE_1 >= 0.268).
EXECUTE.

* 4a) Test set (filter is still split = 0).
CROSSTABS
  /TABLES=Attrition BY pred
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW COLUMN
  /COUNT ROUND CELL.

* 4b) Training set.
USE ALL.
COMPUTE filter_$=(split = 1).
FILTER BY filter_$.
EXECUTE.
CROSSTABS
  /TABLES=Attrition BY pred
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW COLUMN
  /COUNT ROUND CELL.

FILTER OFF.
USE ALL.
EXECUTE.
