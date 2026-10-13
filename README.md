# SPSS Statistics CHAID Tree Demo

A compact, presentation-ready demonstration of how to build, evaluate, export, and apply a **CHAID decision tree in IBM SPSS Statistics**.

The example predicts student dropout using information available by the end of the first semester. It illustrates the full workflow from an analytical data file to a reusable rule-based model that can score new cases.

## Repository contents

- `CHAID_live_demo_syntax.sps` — complete SPSS syntax for model development, validation, PMML/XML export, and scoring.
- `Student_Dropout_CHAID_Demo.sav` — prepared development dataset.
- `New_Students_For_Scoring.sav` — small demonstration dataset representing different terminal-node profiles.
- `SPSS Decision Trees.pdf` — presentation accompanying the demo.

## Before running the syntax

Open `CHAID_live_demo_syntax.sps` and change the working directory:

```spss
CD 'your path here!'.
```

The syntax currently expects the following relative folders:

```text
Working Data\
Outputs\
```

Either create these folders and place the relevant `.sav` files in `Working Data`, or edit every file path in the syntax so that it matches your local folder structure.

Also check the scoring input filename. The syntax refers to:

```text
Working Data\New_Students_For_Scoring_unscored.sav
```

Rename the supplied scoring file accordingly, or change that path in the syntax.

## Stage 1: develop and evaluate the CHAID tree

Run the first section of the syntax with `Student_Dropout_CHAID_Demo.sav` active.

The procedure:

1. Uses `Dropout01` as the binary target: `0 = Graduate`, `1 = Dropout`.
2. Builds a CHAID tree from admission and first-semester predictors.
3. Creates a reproducible 80/20 training–test split.
4. Limits the tree to a maximum depth of 3, with minimum parent and child node sizes of 200 and 100.
5. Produces the tree, classification, risk, and gains-for-nodes output.
6. Saves node membership, predicted outcome, predicted probabilities, and sample assignment to the working data.
7. Exports the trained model as:

```text
Outputs\Student_Dropout_CHAID_Base2.xml
```

SPSS may refuse to overwrite an existing XML model file. Before rerunning this section, delete or rename the previous XML file, or change the export filename in the syntax.

## Stage 2: score new cases

After the XML model has been created, run the scoring section.

It opens the new-student dataset, loads the exported model with `MODEL HANDLE`, and applies the CHAID rules to every case. The resulting variables include:

- `PredictedValue` — predicted outcome.
- `PredictedProbability` — probability of the predicted outcome.
- `SelectedProbability` — probability of dropout specifically (`Dropout01 = 1`).
- `Confidence` — model confidence.
- `NodeNumber` — terminal node assigned by the model.

This final step demonstrates how a static decision-tree analysis can become a reusable scoring system for new observations.

## Data source

The demonstration data are based on the UCI Machine Learning Repository dataset **Predict Students' Dropout and Academic Success**:

https://archive.ics.uci.edu/dataset/697/predict+students+dropout+and+academic+success

The repository is intended for teaching and demonstration purposes.
