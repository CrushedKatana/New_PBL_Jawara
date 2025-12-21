# Machine Learning Project Report

Title: Clothing Category Classification Using HOG + SVM for RT/RW Marketplace

Program/Team: PBL Jawara — PCVK Clothing Detection

Date: 19 December 2025

---

## Executive Overview
This project automates clothing product categorization in an RT/RW marketplace using machine learning. The problem is slow and inconsistent manual categorization. The solution is a classification model based on Histogram of Oriented Gradients (HOG) features and Support Vector Machine (SVM), integrated into the mobile app and a cloud API. Results show 98.71% training accuracy and 77.69% validation accuracy across four classes (Hat, Shirt, Shoes, T-Shirt), making it operationally viable with planned generalization improvements.

---

## Dataset
Source: Kaggle — Clothing Dataset (Full)
https://www.kaggle.com/datasets/agrigorev/clothing-dataset-full

Profile:
- 1,991 original images, four classes: Hat, Shirt, Shoes, T-Shirt.
- After simple augmentation, total training/validation examples become 3,982.
- Sample visuals (placeholder): `images/ml_report/fig-01-dataset-samples.jpg`.

---

## Data Preprocessing
- Color conversion and contrast normalization (histogram equalization) for stable gradients.
- Resize to 128×128 pixels.
- Feature standardization with `StandardScaler` after HOG extraction.
- Simple augmentation to increase diversity (per training script; typical: light flips/rotations/contrast adjustments).

---

## Feature Extraction
Main method: Histogram of Oriented Gradients (HOG)
- Orientations: 9
- Pixels per cell: 8×8
- Cells per block: 2×2
- Block normalization: L2-Hys
- Feature dimension: ~8,100 per 128×128 image

---

## Training Data Construction
Splitting strategy used: train/val/test = 70% / 10% / 20%.

Actual data split table:

| Ratio | Train Samples | Validation Samples | Test Samples |
|-------|---------------|--------------------|--------------|
| 70/10/20 (used) | 2,786 | 399 | 797 |

Alternatives (planned/adjustable):

| Ratio / Method | Train Samples | Test Samples |
|----------------|---------------|--------------|
| 70:30 | — | — |
| 80:20 | — | — |
| 90:10 | — | — |
| kFold = 5 | — | — |

Note: Alternative rows were not executed in this experiment and can be adapted as needed.

---

## Model Development
Model used: Linear SVM (`LinearSVC`) with probability calibration (`CalibratedClassifierCV`).

Configuration/hyperparameters:
- Kernel: Linear
- Regularization (C): 1.0
- Max iterations: 2,000
- Probability calibration: 3-fold
- Optimization: Multi-core CPU parallelization

Pipeline diagram (placeholder): `images/ml_report/fig-02-pipeline.png`.

---

## Evaluation
Key performance results:

| Model | Accuracy (Train) | Accuracy (Val) | Precision (Macro) | Recall (Macro) | F1-Score (Macro) |
|-------|-------------------|----------------|-------------------|----------------|------------------|
| HOG + Linear SVM | 98.71% | 77.69% | 96.94% | 95.12% | 95.98% |

Test split summary (20% holdout):
- Confusion matrix (class order: Hat, Shirt, Shoes, T-Shirt)
  [[30, 0, 2, 2],
   [1, 73, 0, 2],
   [0, 0, 84, 2],
   [0, 2, 1, 200]]
- Macro P/R/F1 = 0.969 / 0.951 / 0.960; Micro P/R/F1 (equals accuracy) = 0.970.
- Artifacts saved: `ml_training/output/confusion_matrix.npy`, `ml_training/output/y_true.npy`, `ml_training/output/y_pred.npy`.

Sample prediction and probability distribution (placeholder): `images/ml_report/fig-03-sample-prediction.png`.

---

## Conclusion
The HOG + SVM pipeline effectively classifies four clothing classes for the RT/RW marketplace scenario, with 77.69% validation accuracy. The model is lightweight, fast, and easy to deploy. Improvements are recommended via broader and more diverse data, stronger augmentation, and regularization tuning. Additional metrics (precision/recall/F1) are suggested to assess per-class performance.

---

## Team Contributions

| Team Member | Contribution |
|-------------|--------------|
| … | … |
| … | … |
| … | … |

Fill in names and contributions according to team roles.

---

## References
1) A. Grigorev, Clothing Dataset (Full), Kaggle: https://www.kaggle.com/datasets/agrigorev/clothing-dataset-full
2) N. Dalal, B. Triggs, "Histograms of Oriented Gradients for Human Detection," CVPR 2005.
3) C. Cortes, V. Vapnik, "Support-Vector Networks," Machine Learning, 1995.
4) F. Pedregosa et al., "Scikit-learn: Machine Learning in Python," JMLR, 2011.

---

## Appendices
- Repro steps: see `ml_training/train_model.py` and `ml_training/output/TRAINING_RESULTS_LATEST.txt`.
- API Docker (HF Spaces): `huggingface_deployment/clothing-detection/`.
- Flutter integration: `pbl_new/lib/core/services/clothing_detection_service.dart`.
- Endpoint config: `pbl_new/lib/config/api_config.dart`.

List of figures and tables:
- Figure 1 — Dataset sample examples — `images/ml_report/fig-01-dataset-samples.jpg`
- Figure 2 — Pipeline diagram — `images/ml_report/fig-02-pipeline.png`
- Figure 3 — Sample prediction and probability distribution — `images/ml_report/fig-03-sample-prediction.png`
*** End Patch