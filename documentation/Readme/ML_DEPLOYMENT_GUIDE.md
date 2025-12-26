# ML Detection Deployment Guide - PCVK Clothing Classification

## ✅ Training Completed

**Model Performance:**
- **Algorithm:** HOG (Histogram of Oriented Gradients) + SVM (Support Vector Machine)
- **Categories:** 4 classes (Hat, Shirt, Shoes, T-Shirt)
- **Training Accuracy:** 100%
- **Validation Accuracy:** 88.22%
- **Total Samples:** 3,982 (with augmentation)
  - Train: 2,786 samples
  - Validation: 399 samples
  - Test: 797 samples
- **Feature Dimension:** 8,100 HOG features
- **Model Files:**
  - `ml_training/models/clothing_svm_best.pkl`
  - `ml_training/models/clothing_scaler_best.pkl`
  - `ml_training/models/label_mapping.json`

## 🎯 How It Works

### 1. **Warga (User) Flow - Camera Detection**

**Entry Point:** Beranda Screen → "Deteksi Pakaian AI" Card

```dart
// Navigate from beranda to detection screen
Navigator.pushNamed(
  context, 
  '/clothing_detection',
  arguments: {'userId': currentUserId}
);
```

**User Actions:**
1. Tap "Deteksi Pakaian AI" on home screen
2. Choose image source:
   - 📷 **Camera** - Take photo directly
   - 🖼️ **Gallery** - Pick existing image
3. Review selected image
4. Tap "Deteksi" button
5. View results:
   - **Predicted Class** (e.g., T-Shirt)
   - **Confidence** (e.g., 99.25%)
   - **Top 3 Predictions** with probabilities
6. Access detection history

**Code Location:**
- Screen: `lib/features/warga/screens/clothing_detection_screen.dart`
- Service: `lib/core/services/clothing_detection_service.dart`

### 2. **Backend Processing Flow**

**API Endpoint:** `backend/ml_detection.php`

```
1. Flutter uploads image → PHP receives multipart/form-data
2. PHP saves image → uploads/ml_detections/ml_<timestamp>.jpg
3. PHP calls Python prediction script:
   .conda/python.exe predict.py --image <path> --model <model> --scaler <scaler>
4. Python returns JSON prediction
5. PHP saves result to database (ml_detections table)
6. PHP returns JSON to Flutter
```

**Python Prediction Script:** `ml_training/scripts/predict.py`

**Process:**
```python
1. Load image → Grayscale → Resize 128x128
2. Extract HOG features (8100 dimensions)
3. Normalize with StandardScaler
4. Predict with SVM model
5. Get probability scores for all 4 classes
6. Return top prediction + top 3 alternatives
```

### 3. **Admin Dashboard - ML Statistics**

**Entry Point:** Admin Dashboard → "Machine Learning" Section → "Statistik Deteksi Pakaian"

**API Endpoint:** `backend/ml_detection_history.php?action=get_global_stats`

**Displays:**
- 📊 **Total Detections** - All ML predictions across platform
- 👥 **Total Users** - Users who used ML feature
- 📈 **Average Confidence** - Mean prediction confidence
- 🏆 **Most Detected Category** - Top category
- 📉 **Bar Chart** - Detections by category
- 🕒 **Recent Detections** - Latest 10 predictions with user info

**Code Location:**
- Screen: `lib/features/admin/screens/ml_statistics_screen.dart`
- Backend: `backend/ml_detection_history.php`

## 🚀 Deployment Steps

### Step 1: Setup Database

Run the migration to create `ml_detections` table:

```sql
-- Execute this in phpMyAdmin or MySQL Workbench
SOURCE backend/migrations/05_ml_detections.sql;
```

**Table Structure:**
```sql
CREATE TABLE ml_detections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    image_path VARCHAR(500) NOT NULL,
    predicted_class VARCHAR(100) NOT NULL,
    confidence DECIMAL(5, 4) NOT NULL,
    top3_predictions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Step 2: Verify Model Files Exist

Check these files are present:
```
✅ ml_training/models/clothing_svm_best.pkl
✅ ml_training/models/clothing_scaler_best.pkl
✅ ml_training/models/label_mapping.json
```

### Step 3: Test Python Prediction (Local)

```cmd
cd ml_training\scripts
D:\CloneGithub\New_PBL_Jawara\.conda\python.exe predict.py ^
  --image "..\dataset\Filtered_Image\TShirt_00003aeb-ace5-43bf-9a0c-dc31a03e9cd2.jpg" ^
  --model "..\models\clothing_svm_best.pkl" ^
  --scaler "..\models\clothing_scaler_best.pkl"
```

**Expected Output:**
```json
{
  "success": true,
  "predicted_class": "T-Shirt",
  "confidence": 0.9925,
  "top3_predictions": [
    {"class": "T-Shirt", "confidence": 0.9925},
    {"class": "Shirt", "confidence": 0.0034},
    {"class": "Shoes", "confidence": 0.0023}
  ],
  "method": "HOG + SVM"
}
```

### Step 4: Setup Backend Upload Directory

Create uploads directory with proper permissions:

```cmd
cd backend
mkdir uploads\ml_detections
```

For production, ensure write permissions:
```bash
chmod 755 uploads/ml_detections  # Linux/Mac
```

### Step 5: Start XAMPP Services

1. Open XAMPP Control Panel
2. Start **Apache** (for PHP backend)
3. Start **MySQL** (for database)
4. Verify:
   - Apache running on port 80
   - MySQL running on port 3306

### Step 6: Configure Flutter API Endpoint

Update if your XAMPP uses different port:

**File:** `lib/core/services/clothing_detection_service.dart`
```dart
static const String _baseUrl = 'http://localhost/pbl_jawara/backend';
```

**For Android emulator testing:**
```dart
static const String _baseUrl = 'http://10.0.2.2/pbl_jawara/backend';
```

**For physical device testing (use your PC's IP):**
```dart
static const String _baseUrl = 'http://192.168.1.XXX/pbl_jawara/backend';
```

### Step 7: Test Backend API

Using cURL:

```cmd
curl -X POST http://localhost/pbl_jawara/backend/ml_detection_history.php ^
  -d "action=get_global_stats"
```

Or using browser (install Postman):
```
POST http://localhost/pbl_jawara/backend/ml_detection_history.php
Body: action=get_global_stats
```

### Step 8: Run Flutter App

```cmd
cd pbl_new
flutter run
```

### Step 9: Test Full Flow

**As Warga User:**
1. Login as warga (not admin)
2. Tap "Deteksi Pakaian AI" card on Beranda
3. Take photo or pick image
4. Tap "Deteksi"
5. Verify results show correctly
6. Check history shows the detection

**As Admin:**
1. Login as admin
2. Go to Admin Dashboard
3. Tap "Statistik Deteksi Pakaian"
4. Verify statistics display:
   - Total detections increased
   - Category breakdown updated
   - Recent detections shows latest entry

## 📊 Database Schema

```sql
-- View all detections with user info
SELECT 
    md.id,
    md.predicted_class,
    md.confidence,
    md.created_at,
    u.nama as user_name,
    u.rt
FROM ml_detections md
JOIN auth_users u ON md.user_id = u.id
ORDER BY md.created_at DESC;

-- Get statistics by category
SELECT 
    predicted_class,
    COUNT(*) as total,
    AVG(confidence) as avg_confidence,
    MIN(confidence) as min_confidence,
    MAX(confidence) as max_confidence
FROM ml_detections
GROUP BY predicted_class
ORDER BY total DESC;

-- Get user detection summary
SELECT 
    u.id,
    u.nama,
    u.rt,
    COUNT(md.id) as total_detections,
    AVG(md.confidence) as avg_confidence
FROM auth_users u
LEFT JOIN ml_detections md ON u.id = md.user_id
GROUP BY u.id
ORDER BY total_detections DESC;
```

## 🔧 Troubleshooting

### Issue: "Failed to run ML model"

**Cause:** Python executable not found or model files missing

**Solution:**
1. Verify Python path in `ml_detection.php`:
   ```php
   $pythonExe = __DIR__ . '/../.conda/python.exe';
   ```
2. Check model files exist:
   ```cmd
   dir ml_training\models\clothing_svm_best.pkl
   dir ml_training\models\clothing_scaler_best.pkl
   ```

### Issue: "No image uploaded or upload error"

**Cause:** File upload size limit or permissions

**Solution:**
1. Check `php.ini` settings:
   ```ini
   upload_max_filesize = 10M
   post_max_size = 10M
   ```
2. Restart Apache after changes

### Issue: "Failed to save uploaded file"

**Cause:** Upload directory doesn't exist or no write permissions

**Solution:**
```cmd
mkdir backend\uploads\ml_detections
icacls backend\uploads\ml_detections /grant Everyone:F
```

### Issue: Predictions always low confidence

**Cause:** Image preprocessing mismatch or wrong model

**Solution:**
1. Verify model is the latest trained version
2. Check image is properly preprocessed (128x128, grayscale)
3. Retrain model if using different image format

### Issue: "Connection refused" from Flutter

**Cause:** Backend URL incorrect or XAMPP not running

**Solution:**
1. Verify Apache is running in XAMPP
2. Test URL in browser: `http://localhost/pbl_jawara/backend/ml_detection_history.php`
3. For Android emulator, use `10.0.2.2` instead of `localhost`

## 📈 Performance Optimization

### For Better Accuracy:

1. **Collect More Training Data**
   - Current: 1,991 images (980 valid after filtering)
   - Target: 5,000+ images per category
   - Use data augmentation during training

2. **Hyperparameter Tuning**
   - Run GridSearchCV to find optimal C, gamma
   - Try different kernels (linear, poly, rbf)
   - Adjust HOG parameters

3. **Model Ensemble**
   - Combine multiple models (SVM + RandomForest)
   - Use voting or stacking

### For Better Speed:

1. **Image Optimization**
   - Compress images before upload
   - Reduce max_width/max_height in ImagePicker

2. **Model Optimization**
   - Use LinearSVC for faster inference
   - Reduce HOG feature dimensions

3. **Backend Caching**
   - Cache model in memory (PHP OpCache)
   - Use Redis for prediction caching

## 📝 API Documentation

### Detect Clothing

**Endpoint:** `POST /backend/ml_detection.php`

**Request:**
```
Content-Type: multipart/form-data

image: <binary file>
user_id: <integer>
```

**Response:**
```json
{
  "success": true,
  "predicted_class": "T-Shirt",
  "confidence": 0.9925,
  "top3_predictions": [
    {"class": "T-Shirt", "confidence": 0.9925},
    {"class": "Shirt", "confidence": 0.0034},
    {"class": "Shoes", "confidence": 0.0023}
  ],
  "message": "Detection successful"
}
```

### Get Detection History

**Endpoint:** `POST /backend/ml_detection_history.php`

**Request:**
```
action: get_history
user_id: <integer>
limit: 20
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "predicted_class": "T-Shirt",
      "confidence": 0.9925,
      "top3_predictions": [...],
      "created_at": "2025-12-03 14:30:00"
    }
  ]
}
```

### Get Global Statistics (Admin)

**Endpoint:** `POST /backend/ml_detection_history.php`

**Request:**
```
action: get_global_stats
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_detections": 1247,
    "total_users": 89,
    "avg_confidence": 0.8822,
    "most_detected_category": "T-Shirt",
    "by_category": [
      {"category": "T-Shirt", "count": 450},
      {"category": "Shirt", "count": 342},
      {"category": "Hat", "count": 255},
      {"category": "Shoes", "count": 200}
    ],
    "recent_detections": [...]
  }
}
```

## 🎓 Model Details

**Algorithm:** Support Vector Machine (SVM) with RBF Kernel

**Feature Extraction:** Histogram of Oriented Gradients (HOG)
- Orientations: 9
- Pixels per cell: 8x8
- Cells per block: 2x2
- Transform sqrt: True
- Feature dimension: 8,100

**Preprocessing:**
1. Convert to grayscale
2. Resize to 128x128 pixels
3. Histogram equalization
4. HOG feature extraction
5. StandardScaler normalization

**Training Parameters:**
- Kernel: RBF (Radial Basis Function)
- C: 10.0
- Gamma: scale
- Class weight: balanced

**Data Augmentation:**
- Horizontal flip (50% probability)
- Random rotation (-15° to +15°)
- Brightness adjustment (0.8x to 1.2x)

## 🔐 Security Considerations

1. **File Upload Validation**
   - ✅ Check file type (JPEG, PNG only)
   - ✅ Limit file size (< 10MB)
   - ✅ Generate unique filename
   - ❌ TODO: Add virus scanning

2. **User Authentication**
   - ✅ Verify user_id exists
   - ❌ TODO: Add JWT token validation
   - ❌ TODO: Rate limiting on API

3. **Admin Authorization**
   - ❌ TODO: Verify admin role before showing stats
   - ❌ TODO: Add admin session check in backend

## 📦 Production Deployment

### For VPS/Cloud Server:

1. **Install Dependencies:**
   ```bash
   # Python
   sudo apt-get install python3.11 python3-pip
   pip3 install -r ml_training/requirements.txt
   
   # PHP & MySQL
   sudo apt-get install apache2 php mysql-server
   ```

2. **Update Python Path:**
   ```php
   // ml_detection.php
   $pythonExe = '/usr/bin/python3.11'; // System Python
   ```

3. **Set Permissions:**
   ```bash
   sudo chown -R www-data:www-data backend/uploads
   sudo chmod 755 backend/uploads
   ```

4. **Update Flutter URL:**
   ```dart
   static const String _baseUrl = 'https://your-domain.com/api';
   ```

5. **Enable HTTPS:**
   ```bash
   sudo certbot --apache -d your-domain.com
   ```

## ✅ Checklist

- [x] Model trained with 4 categories (88.22% accuracy)
- [x] Prediction script working (99.25% confidence test)
- [x] Backend API configured with correct Python path
- [x] Database migration ready (05_ml_detections.sql)
- [x] Flutter screens implemented (detection + history + admin stats)
- [x] API integration complete (real data, no dummy)
- [ ] Run database migration
- [ ] Test full flow (warga detection)
- [ ] Test admin statistics
- [ ] Deploy to production server
- [ ] Add authentication checks
- [ ] Implement rate limiting
- [ ] Add monitoring/logging

---

**Last Updated:** December 3, 2025  
**Model Version:** clothing_svm_best.pkl (trained with T-Shirt fix)  
**Training Timestamp:** 2025-12-03 11:43:53
