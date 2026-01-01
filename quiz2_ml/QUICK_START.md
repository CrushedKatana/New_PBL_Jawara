# Ethnic Classification Model - Quick Start Guide

## 🚀 Installation

### Step 1: Install Dependencies
```bash
cd quiz2_ml
pip install -r requirements.txt
```

### Step 2: Run the Training Script
```bash
python train_ethnic_classifier.py
```

## ⏱️ Execution Time
- **Full dataset**: ~30-45 minutes depending on your hardware
- **With limited samples**: ~5-10 minutes

## 📁 Output Files

After execution, you'll find in the `output/` directory:

### Reports & Visualizations
1. **ETHNIC_CLASSIFICATION_REPORT.md** - Comprehensive markdown report
2. **01_accuracy_comparison.png** - Test accuracy across splits
3. **02_metrics_comparison.png** - Detailed metrics visualization
4. **03_confusion_matrix.png** - Best model confusion matrix
5. **04_cross_validation_scores.png** - Cross-validation results
6. **05_pca_variance.png** - PCA explained variance

### Saved Models
- `model_70:30_SVM.joblib`
- `model_70:30_Random_Forest.joblib`
- `model_70:30_KNN_(k=5).joblib`
- `model_80:20_SVM.joblib`
- `model_80:20_Random_Forest.joblib`
- `model_80:20_KNN_(k=5).joblib`
- `model_90:10_SVM.joblib`
- `model_90:10_Random_Forest.joblib`
- `model_90:10_KNN_(k=5).joblib`

## 🎯 What Does the Script Do?

### 1. Data Loading & Preprocessing
- Loads FairFace dataset from HuggingFace
- Extracts Histogram of Oriented Gradients (HOG) features
- Normalizes features using StandardScaler

### 2. Dimensionality Reduction
- Applies PCA to reduce dimensions
- Maintains ~95% of explained variance

### 3. Model Training
- Trains 3 different models (SVM, Random Forest, KNN)
- Uses 3 different train-test splits (70:30, 80:20, 90:10)
- Implements 5-fold cross-validation for each

### 4. Evaluation
- Calculates Accuracy, Precision, Recall, F1-Score
- Generates confusion matrices
- Creates performance visualizations

### 5. Reporting
- Generates comprehensive markdown report
- Includes all findings, visualizations, and recommendations

## 💡 Key Features

✓ **Automatic Dataset Download** - Fetches FairFace from HuggingFace automatically
✓ **Multi-Model Comparison** - SVM, Random Forest, KNN
✓ **Multiple Split Strategies** - 70:30, 80:20, 90:10
✓ **Cross-Validation** - 5-fold stratified cross-validation
✓ **Comprehensive Metrics** - Accuracy, Precision, Recall, F1-Score
✓ **Beautiful Visualizations** - 5 high-quality PNG charts
✓ **Model Persistence** - All models saved as joblib files
✓ **Detailed Report** - Full markdown report with findings

## 🔧 Customization

To modify the script for your needs:

```python
# Load smaller dataset
model.load_and_preprocess_data(version="0.25", split="train", max_samples=5000)

# Change output directory
model.generate_visualizations('./custom_output')

# Adjust PCA components
model.pca = PCA(n_components=150)
```

## ⚠️ Requirements

- **Internet Connection**: Required for downloading FairFace dataset
- **Storage**: ~3GB for full dataset
- **RAM**: 8GB+ recommended
- **Python**: 3.8+

## 🆘 Troubleshooting

### Dataset Download Fails
```bash
# Try with a different dataset version
# In train_ethnic_classifier.py, change:
ds = load_dataset("HuggingFaceM4/FairFace", "1.25")
```

### Out of Memory
```python
# Reduce max_samples in main():
model.load_and_preprocess_data(version="0.25", split="train", max_samples=10000)
```

### Slow Processing
```python
# Reduce PCA components:
self.pca = PCA(n_components=50)
```

## 📚 Dataset Information

- **Source**: HuggingFace - FairFace
- **Total Images**: 108,501
- **Classes**: 7 ethnic categories
  - White
  - Black
  - Indian
  - East Asian
  - Southeast Asian
  - Middle Eastern
  - Latino

---

**Questions or Issues?** Check the ETHNIC_CLASSIFICATION_REPORT.md for detailed findings!
