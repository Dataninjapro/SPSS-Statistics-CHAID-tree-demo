* Encoding: UTF-8.

CD 'your path here!'.

GET
  FILE='Working Data\Student_Dropout_CHAID_Demo.sav'.

DATASET NAME dropout_base WINDOW=FRONT.

SAVE OUTFILE='Working Data\Student_Dropout_CHAID_Demo.sav'
  /COMPRESSED.

SET SEED=20261005.
TREE Dropout01 [n] BY
    App_Order        [o]
    Course           [n]
    Daytime          [n]
    Admission_Grade  [s]
    Debtor           [n]
    Tuition_OK       [n]
    Gender           [n]
    Scholarship      [n]
    Age_Enroll       [s]
    Sem1_Enrolled    [s]
    Sem1_Evaluated   [s]
    Sem1_Approved    [s]
    Sem1_Grade       [s]
    Sem1_NoEval      [s]
  /TREE
    DISPLAY=TOPDOWN
    NODES=BOTH
    BRANCHSTATISTICS=YES
    NODEDEFS=YES
    SCALE=AUTO
  /DEPCATEGORIES
    USEVALUES=[VALID]
    TARGET=[1]
  /PRINT
    MODELSUMMARY
    CLASSIFICATION
    RISK
    TREETABLE
  /GAIN
    CATEGORYTABLE=YES
    TYPE=[NODE]
    SORT=DESCENDING
    CUMULATIVE=NO
  /SAVE
    NODEID(CHAID_Node)
    PREDVAL(CHAID_Pred)
    PREDPROB(CHAID_Prob)
    ASSIGNMENT(CHAID_Set)
  /METHOD
    TYPE=CHAID
  /GROWTHLIMIT
    MAXDEPTH=3
    MINPARENTSIZE=200
    MINCHILDSIZE=100
  /VALIDATION
    TYPE=SPLITSAMPLE(80)
    OUTPUT=BOTHSAMPLES
  /CHAID
    ALPHASPLIT=0.05
    ALPHAMERGE=0.05
    SPLITMERGED=NO
    CHISQUARE=PEARSON
    CONVERGE=0.001
    MAXITERATIONS=100
    ADJUST=BONFERRONI
    INTERVALS=10
  /COSTS EQUAL
  /OUTFILE
    TRAININGMODEL=
    'Outputs\Student_Dropout_CHAID_Base2.xml'
  /MISSING
    NOMINALMISSING=MISSING.


* Labels for saved model variables.
* CHAID_Set: 1=Training, 0=Test.

VARIABLE LABELS
    CHAID_Node 'Terminal node assigned by the CHAID model'
    CHAID_Pred 'Predicted final outcome from the CHAID model'
    CHAID_Set  'Split-sample assignment'.

VALUE LABELS
    CHAID_Pred
        0 'Graduate'
        1 'Dropout'
    /CHAID_Set
        0 'Test'
        1 'Training'.

VARIABLE LEVEL
    CHAID_Node CHAID_Pred CHAID_Set (NOMINAL).


* PREDPROB creates one probability variable per outcome category.
* With Dropout01 ordered as 0=Graduate and 1=Dropout:
* CHAID_Prob_1 = probability of Graduate.
* CHAID_Prob_2 = probability of Dropout.

COMPUTE CHAID_Score = CHAID_Prob_2.

VARIABLE LABELS
    CHAID_Prob_1 'Predicted probability of graduation'
    CHAID_Prob_2 'Predicted probability of dropout'
    CHAID_Score  'CHAID dropout risk score'.

FORMATS CHAID_Prob_1 CHAID_Prob_2 CHAID_Score (F6.3).
VARIABLE LEVEL CHAID_Prob_1 CHAID_Prob_2 CHAID_Score (SCALE).

EXECUTE.

SAVE OUTFILE=
    'Working Data\Student_Dropout_CHAID_Base2_Scored.sav'
    /COMPRESSED.

* The Traditional Druid Incantation: ∞α∞ Separation of the Fourteen ∞Ω∞.
* One representative Test case from each terminal node.

GET
  FILE='Working Data\New_Students_For_Scoring.sav'.

DATASET name Students_For_Scoring WINDOW=FRONT.


MODEL HANDLE NAME=Student_Dropout_CHAID_Base2 FILE='Outputs\Student_Dropout_CHAID_Base2.xml'
  /OPTIONS MISSING=SUBSTITUTE.
COMPUTE PredictedProbability=APPLYMODEL(Student_Dropout_CHAID_Base2, 'PROBABILITY').
COMPUTE SelectedProbability=APPLYMODEL(Student_Dropout_CHAID_Base2, 'PROBABILITY', 1).
COMPUTE Confidence=APPLYMODEL(Student_Dropout_CHAID_Base2, 'CONFIDENCE').
COMPUTE PredictedValue=APPLYMODEL(Student_Dropout_CHAID_Base2, 'PREDICT').
COMPUTE NodeNumber=APPLYMODEL(Student_Dropout_CHAID_Base2, 'NODEID').
EXECUTE.
MODEL CLOSE NAME=Student_Dropout_CHAID_Base2.


