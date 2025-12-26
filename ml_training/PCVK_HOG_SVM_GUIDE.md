# PCVK HOG + SVM Implementation Guide

**Version:** 1.0  
**Date:** December 2025  
**Method:** Histogram of Oriented Gradients (HOG) + Support Vector Machine (SVM)  
**Status:** ✅ Production Ready

---

## 📋 Overview

### What is HOG + SVM?

**HOG (Histogram of Oriented Gradients):**
- Image feature extraction method
- Captures edge/gradient patterns in images
- Transforms 128×128 image → 8,100 feature values
- Computationally efficient
- Works great for clothing classification

**SVM (Support Vector Machine):**
- Machine learning classifier
- Finds optimal decision boundary between classes
- Parameters: Kernel (RBF), C=10.0, Gamma=scale
- Multiclass: One-vs-Rest strategy
- Probability calibration enabled

### Model Performance

```
┌──────────────────┬──────────┐
│ Metric           │ Value    │
├──────────────────┼──────────┤
│ Accuracy         │ 88.22%   │
│ Training Time    │ 2-3 min  │
│ Model Size       │ 1 MB     │
│ Inference Time   │ ~50ms    │
│ Training Data    │ 3,982    │
│ Categories       │ 4        │
│ Hardware         │ CPU only │
└──────────────────┴──────────┘
```

### Four Categories

1. **Hat** (Topi) - 👒
2. **Shirt** (Kemeja) - 👔
3. **T-Shirt** (Kaos) - 👕
4. **Shoes** (Sepatu) - 👟

---

## 🚀 Getting Started

### 1. Start Backend
```bash
# Open XAMPP Control Panel
# Start: Apache (port 80) + MySQL (port 3306)
```

### 2. Load Database
```sql
-- Execute: pbl_new/backend/migrations/05_ml_detections.sql
mysql> source 05_ml_detections.sql
-- Creates ml_detections table
```

### 3. Run Flutter App
```bash
cd pbl_new
flutter run -d windows
```

### 4. Test PCVK Feature
```
1. App Menu → "Jual Pakaian" (Sell Clothing)
2. Click "Tambah Produk" (Add Product)
3. Click "PCVK" button
4. Take photo of clothing item
5. Observe: Category auto-fills + Confidence displayed
```

---

## 📁 File Structure

### Trained Models
```
ml_training/models/
├── clothing_svm_best.pkl        ← Main model (1.2 MB)
├── clothing_scaler_best.pkl      ← Feature scaler
└── label_mapping.json            ← Category names
```

### Training Scripts
```
ml_training/scripts/
├── train_model.py                ← Train HOG+SVM model
├── preprocess.py                 ← Extract HOG features
├── predict.py                    ← Inference/prediction
├── evaluate.py                   ← Model evaluation
└── show_status.py                ← Show model status
```

### Backend Integration
```
pbl_new/backend/
├── ml_detection.php              ← API endpoint
├── predict.py                    ← Python inference
└── migrations/05_ml_detections.sql
```

### Flutter Integration
```
pbl_new/lib/
├── features/warga/screens/
│   ├── add_product_screen.dart           ← "PCVK" button
│   └── camera_detection_screen.dart      ← Camera interface
└── core/services/
    └── clothing_detection_service.dart   ← API client
```

---

## 🔧 Training HOG + SVM

### Run Training
```bash
cd ml_training/scripts

# Using .conda environment
D:\CloneGithub\New_PBL_Jawara\.conda\python.exe train_model.py
```

### Training Output
```
[1/3] Extracting HOG features...
[2/3] Training SVM classifier...
[3/3] Saving model information...

✅ Models saved:
  - ../models/clothing_svm_best.pkl
  - ../models/clothing_scaler_best.pkl
  - ../output/model_info_*.json
```

### Hyperparameter Tuning (Optional)
Edit `train_model.py` line 220:
```python
train_results = svm_trainer.train(
    dataset['X_train'], dataset['y_train'],
    dataset['X_val'], dataset['y_val'],
    use_grid_search=True  # ← Change to True for tuning
)
```

Then run training. This will test 160 hyperparameter combinations:
- C: [0.1, 1, 10, 100]
- Gamma: ['scale', 'auto', 0.001, 0.01, 0.1]
- Kernel: ['rbf', 'linear']

Takes longer but finds best parameters.

---

## 📊 How It Works

### Prediction Pipeline

```
Flutter App
    ↓ [Image File]
Backend (ml_detection.php)
    ↓ [Image Path]
Python (predict.py)
    ├─ Load: clothing_svm_best.pkl (model)
    ├─ Load: clothing_scaler_best.pkl (scaler)
    ├─ Extract: HOG features
    │  ├─ Resize to 128×128
    │  ├─ Compute gradients
    │  ├─ 9 orientations, 8×8 cells
    │  └─ 8,100 feature dimensions
    ├─ Normalize: StandardScaler
    ├─ Predict: SVM classifier
    │  └─ One-vs-Rest for 4 classes
    └─ Return: JSON response
    ↓ {class, confidence, top3}
Flutter App
    ↓ [Display]
UI: Category + Confidence
```

### Example Response
```json
{
  "success": true,
  "predicted_class": "T-Shirt",
  "confidence": 0.9325,
  "top_predictions": [
    {"class": "T-Shirt", "confidence": 0.9325},
    {"class": "Shirt", "confidence": 0.0512},
    {"class": "Hat", "confidence": 0.0163}
  ]
}
```

---

## 🧪 Testing

### Test Backend API
```bash
# Using curl
curl -X POST -F "image=@test.jpg" \
  http://localhost/pbl_jawara/backend/ml_detection.php

# Or test with Python
cd ml_training/scripts
D:\CloneGithub\New_PBL_Jawara\.conda\python.exe predict.py \
  --image ../dataset/test.jpg \
  --model ../models/clothing_svm_best.pkl \
  --scaler ../models/clothing_scaler_best.pkl
```

### Test Model Evaluation
```bash
# Evaluate on test set
D:\CloneGithub\New_PBL_Jawara\.conda\python.exe evaluate.py \
  --model ../models/clothing_svm_best.pkl \
  --scaler ../models/clothing_scaler_best.pkl
```

### Test Flutter App
```bash
# Build and run
flutter run -d windows

# Then test:
# Menu → Jual Pakaian → PCVK → Take photo
```

---

## ⚙️ Configuration

### Backend Configuration
**File:** `backend/ml_detection.php`

```php
// Python executable path
$pythonExe = __DIR__ . '/../.conda/python.exe';

// Model paths
$modelPath = __DIR__ . '/../ml_training/models/clothing_svm_best.pkl';
$scalerPath = __DIR__ . '/../ml_training/models/clothing_scaler_best.pkl';

// Script to execute
$pythonScript = __DIR__ . '/../ml_training/scripts/predict.py';
```

### Flask Configuration
**File:** `lib/config/api_config.dart`

```dart
const String ML_DETECTION_API = 
  'http://localhost:80/pbl_jawara/backend/ml_detection.php';
```

---

## 📈 Admin Dashboard

**Location:** Admin Panel → Klasifikasi PCVK (ML)

**Metrics Displayed:**
- Total predictions made
- Success rate / Error rate
- Category breakdown (pie chart)
- Confidence distribution
- Recent detections (latest 10)
- Accuracy trending (over time)

---

## 🔍 Model Details

### HOG Feature Extraction
```python
# Parameters used in preprocess.py
hog_orientations = 9          # 9 gradient directions
pixels_per_cell = (8, 8)      # 8×8 pixel cells
cells_per_block = (2, 2)      # 2×2 block normalization
transform_sqrt = True         # Square root transformation
→ Result: 8,100 features per 128×128 image
```

### SVM Configuration
```python
# Parameters used in train_model.py
kernel = 'rbf'                # Radial Basis Function
C = 10.0                      # Regularization parameter
gamma = 'scale'               # Kernel coefficient
decision_function_shape = 'ovr'  # One-vs-Rest
probability = True            # Enable confidence scores
random_state = 42             # Reproducible results
```

### Data Splits
```
Original Dataset: 1,991 images
With Augmentation: 3,982 samples

├─ Training:   60% (2,389 samples)
├─ Validation: 20% (796 samples)
└─ Test:       20% (796 samples)
```

---

## 🐛 Troubleshooting

### Problem: Backend returns error 500
**Solutions:**
1. Verify XAMPP Apache running
2. Check Python executable path in ml_detection.php
3. Verify model files exist and readable
4. Check image file is valid (jpg/png)
5. Review PHP error logs

### Problem: Slow predictions
**Solutions:**
1. First request is slow (model loading) - normal
2. Subsequent requests fast (~50-100ms)
3. Check CPU usage (may be bottleneck)
4. Reduce concurrent requests

### Problem: Wrong category predicted
**Solutions:**
1. Image quality insufficient
2. Clothing not clearly visible
3. Poor lighting
4. Category not in training data (only Hat/Shirt/T-Shirt/Shoes)

### Problem: Flutter connection error
**Solutions:**
1. Start XAMPP services
2. Verify API_CONFIG URL correct
3. Firewall allowing port 80?
4. Backend API accessible? Test: http://localhost/pbl_jawara/backend/

---

## 📚 HOG + SVM Advantages

✅ **Fast Training** - 2-3 minutes  
✅ **CPU Only** - No GPU required  
✅ **Small Model** - 1 MB total  
✅ **Fast Inference** - ~50ms per image  
✅ **Explainable** - HOG features interpretable  
✅ **Production Ready** - Stable, reliable  
✅ **Low Memory** - Works on all devices  
✅ **Good Accuracy** - 88%+ for clothing classification  

---

## 🎯 Typical Workflow

```
1. User opens app
   ↓
2. User goes to "Jual Pakaian"
   ↓
3. User clicks "Tambah Produk"
   ↓
4. Click "PCVK" button
   ↓
5. Camera opens, user takes photo
   ↓
6. Backend receives image
   ↓
7. Python executes predict.py
   ├─ Load model & scaler
   ├─ Extract HOG features
   ├─ Run SVM prediction
   └─ Return JSON response
   ↓
8. Flutter displays result
   ├─ Show: "Kaos" (T-Shirt)
   ├─ Show: "Confidence: 93.25%"
   └─ Auto-fill product category
   ↓
9. User completes product details
   ↓
10. Click submit
   ↓
11. Product & prediction saved to database
```

---

## 📞 Support

**Files & Documentation:**
- This file: PCVK_HOG_SVM_GUIDE.md
- Implementation: PCVK_IMPLEMENTATION.md
- Deployment: ML_DEPLOYMENT_GUIDE.md

**Scripts:**
- Train: `train_model.py`
- Predict: `predict.py`
- Evaluate: `evaluate.py`

**Dataset:**
- Source: Kaggle Clothing Dataset
- Categories: Hat, Shirt, Shoes, T-Shirt
- Samples: 3,982 (after augmentation)
- Format: JPG images 128×128

---

## ✅ Checklist for Production

- [ ] XAMPP started (Apache + MySQL)
- [ ] Database table created (05_ml_detections.sql)
- [ ] Backend API tested (ml_detection.php works)
- [ ] Flutter app running (flutter run -d windows)
- [ ] PCVK button visible ("Jual Pakaian" screen)
- [ ] Camera works (can take photos)
- [ ] ML prediction working (category auto-fills)
- [ ] Admin dashboard showing statistics
- [ ] Images saved to database
- [ ] Predictions logged correctly

---

## 🔍 Quick Verification

```bash
# 1. Check models exist
cd ml_training/models
dir /b

# 2. Test Python environment
D:\CloneGithub\New_PBL_Jawara\.conda\python.exe -c "import joblib; print('✅ joblib OK')"

# 3. Test prediction script
cd ml_training/scripts
D:\CloneGithub\New_PBL_Jawara\.conda\python.exe predict.py --image ../dataset/test.jpg

# 4. Check backend
php -S localhost:8000 -t ../backend

# 5. Test Flutter
flutter run -d windows
```

---

**Status:** ✅ Production Ready  
**Method:** HOG + SVM  
**Accuracy:** 88.22%  
**Last Updated:** December 2025
