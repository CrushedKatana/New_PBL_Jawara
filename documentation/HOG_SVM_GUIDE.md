# HOG + SVM Implementation Guide

## Metode PCVK: HOG + SVM

### 1. HOG (Histogram of Oriented Gradients)

**Konsep:**
- Feature descriptor untuk object detection
- Menghitung distribusi gradien orientasi dalam gambar
- Robust terhadap perubahan illumination dan small deformations

**Parameters:**
```python
orientations = 9          # Jumlah bins untuk histogram gradien
pixels_per_cell = (8, 8)  # Ukuran cell
cells_per_block = (2, 2)  # Normalisasi per block
transform_sqrt = True     # Power law compression untuk normalisasi
```

**Process:**
1. Konversi gambar ke grayscale
2. Hitung gradien (magnitude & direction) untuk setiap pixel
3. Bagi gambar menjadi cells (8x8 pixels)
4. Buat histogram orientasi untuk tiap cell (9 bins)
5. Normalisasi histogram per block (2x2 cells)
6. Concatenate semua histogram menjadi feature vector

**Output:**
- Feature vector dengan dimensi: `(image_height/8 - 1) * (image_width/8 - 1) * 4 * 9`
- Untuk gambar 128x128: `15 * 15 * 4 * 9 = 8100 features`

### 2. SVM (Support Vector Machine)

**Konsep:**
- Supervised learning untuk classification
- Cari hyperplane terbaik yang memisahkan classes
- Kernel trick untuk non-linear decision boundary

**Kernel: RBF (Radial Basis Function)**
```
K(x, y) = exp(-gamma * ||x - y||^2)
```

**Hyperparameters:**
- `C`: Regularization parameter (default: 10.0)
  - C kecil: margin lebar, toleran terhadap misclassification
  - C besar: margin sempit, strict classification
- `gamma`: Kernel coefficient (default: 'scale')
  - gamma kecil: decision boundary smooth
  - gamma besar: decision boundary complex

**Multi-class Strategy:**
- One-vs-Rest (OvR): Train N binary classifiers untuk N classes
- Pilih class dengan confidence tertinggi

### 3. Training Pipeline

```
Dataset (CSV)
    ↓
[1] Load & Preprocess Images
    - Grayscale conversion
    - Resize to 128x128
    - Histogram equalization
    ↓
[2] HOG Feature Extraction
    - Extract HOG descriptor
    - Feature vector per image
    ↓
[3] Data Augmentation (optional)
    - Rotation (-15° to +15°)
    - Horizontal flip
    - Brightness adjustment
    ↓
[4] Feature Normalization
    - StandardScaler (mean=0, std=1)
    - Penting untuk SVM performance
    ↓
[5] SVM Training
    - Fit SVM classifier
    - Optional: GridSearchCV untuk hyperparameter tuning
    ↓
[6] Model Saving
    - Save model: .pkl (joblib)
    - Save scaler: .pkl (joblib)
    - Save label mapping: .json
```

### 4. Prediction Pipeline

```
Input Image
    ↓
[1] Preprocess
    - Grayscale
    - Resize 128x128
    - Histogram equalization
    ↓
[2] Extract HOG Features
    - Same parameters as training
    ↓
[3] Normalize Features
    - Apply same scaler from training
    ↓
[4] SVM Prediction
    - predict_proba() untuk confidence
    ↓
Output:
    - Predicted class
    - Confidence score
    - Top-3 predictions
```

### 5. Keunggulan HOG + SVM

**Vs Deep Learning (CNN):**
- ✅ **Training Speed**: 10-100x lebih cepat
- ✅ **Dataset Size**: Bisa dengan dataset kecil (ratusan-ribuan)
- ✅ **Interpretability**: Features lebih interpretable
- ✅ **No GPU Required**: Bisa training di CPU
- ✅ **Model Size**: File model jauh lebih kecil (MB vs GB)
- ✅ **Inference Speed**: Prediksi sangat cepat

**Limitations:**
- ❌ Akurasi mungkin lebih rendah untuk dataset complex
- ❌ Manual feature engineering (HOG fixed)
- ❌ Kurang flexible untuk transfer learning

### 6. Performance Tips

**Improve Accuracy:**
1. **Data Quality**: Clean dataset, consistent lighting
2. **Augmentation**: Increase training diversity
3. **Hyperparameter Tuning**: Use GridSearchCV
4. **Feature Engineering**: Try different HOG parameters
5. **Image Preprocessing**: Histogram equalization, contrast enhancement

**Optimize Speed:**
1. Reduce image size (64x64 instead of 128x128)
2. Reduce HOG orientations (6 instead of 9)
3. Use linear kernel for faster training
4. Use only validation set (skip test set during development)

### 7. Example Usage

**Training:**
```bash
cd ml_training/scripts
python train_model.py
```

**Evaluation:**
```bash
python evaluate.py --model ../models/clothing_svm_best.pkl
```

**Single Prediction:**
```bash
python predict.py \
  --image path/to/image.jpg \
  --model ../models/clothing_svm_best.pkl \
  --scaler ../models/clothing_scaler_best.pkl
```

### 8. Expected Results

**Typical Performance:**
- Training time: 1-10 minutes (depending on dataset size)
- Accuracy: 75-90% (tergantung dataset quality)
- Inference time: <100ms per image
- Model size: <50MB

**Confusion Matrix:**
- Most confusion antara classes yang mirip (e.g., Kemeja vs Blouse)
- High confidence untuk distinct classes (e.g., Celana vs Dress)

### 9. Troubleshooting

**Low Accuracy:**
- Check dataset balance (jumlah sample per class)
- Try hyperparameter tuning
- Increase data augmentation
- Verify image quality

**Slow Training:**
- Reduce dataset size sementara
- Use linear kernel instead of RBF
- Reduce image resolution

**Memory Error:**
- Reduce image size
- Process dataset in batches
- Reduce augmentation multiplier

---

**References:**
- Dalal, N., & Triggs, B. (2005). Histograms of oriented gradients for human detection.
- Cortes, C., & Vapnik, V. (1995). Support-vector networks.
