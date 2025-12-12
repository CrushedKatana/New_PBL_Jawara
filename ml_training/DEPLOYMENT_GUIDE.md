# Deployment Guide ke Hugging Face Spaces

## 📋 Prerequisites

1. **Hugging Face Account**: Daftar di [huggingface.co](https://huggingface.co/join)
2. **Model Files**: 
   - `clothing_svm_best.pkl` (146 MB)
   - `clothing_scaler_best.pkl`
   - `label_mapping.json`

## 🚀 Deployment Steps

### Option 1: Via Hugging Face Web Interface (Recommended)

1. **Create New Space**
   - Go to https://huggingface.co/new-space
   - Space name: `clothing-detection-hog-svm`
   - License: `MIT`
   - SDK: `Gradio`
   - Hardware: `CPU Basic` (free tier)

2. **Upload Files**
   Upload these files dari folder `ml_training/`:
   ```
   huggingface_app.py (as app.py)
   requirements.txt
   README_HUGGINGFACE.md (as README.md)
   models/
     ├── clothing_svm_best.pkl
     ├── clothing_scaler_best.pkl
     └── label_mapping.json (optional)
   examples/ (optional)
     ├── topi.jpg
     ├── kemeja.jpg
     ├── sepatu.jpg
     └── tshirt.jpg
   ```

3. **Wait for Build**
   - Hugging Face akan otomatis build app
   - Build time: ~5-10 menit (karena install dependencies + load model 146MB)

4. **Test App**
   - Buka URL: `https://huggingface.co/spaces/YOUR_USERNAME/clothing-detection-hog-svm`
   - Upload image untuk test

### Option 2: Via Git (Advanced)

```bash
# 1. Install git-lfs untuk large files
git lfs install

# 2. Clone space repository
git clone https://huggingface.co/spaces/YOUR_USERNAME/clothing-detection-hog-svm
cd clothing-detection-hog-svm

# 3. Track large model file
git lfs track "*.pkl"

# 4. Copy files
cp ../ml_training/huggingface_app.py app.py
cp ../ml_training/requirements.txt .
cp ../ml_training/README_HUGGINGFACE.md README.md
mkdir models
cp ../ml_training/models/clothing_svm_best.pkl models/
cp ../ml_training/models/clothing_scaler_best.pkl models/

# 5. Commit and push
git add .
git commit -m "Initial deployment - Clothing Detection HOG+SVM"
git push

# 6. Wait for build on Hugging Face
```

## 🔧 Configuration

### File Structure
```
clothing-detection-hog-svm/
├── app.py                    # Main Gradio app (dari huggingface_app.py)
├── requirements.txt          # Python dependencies
├── README.md                 # Space documentation
├── models/
│   ├── clothing_svm_best.pkl       # SVM model (146 MB)
│   └── clothing_scaler_best.pkl    # Feature scaler
└── examples/                 # Example images (optional)
    ├── topi.jpg
    ├── kemeja.jpg
    ├── sepatu.jpg
    └── tshirt.jpg
```

### Hardware Requirements

**Free Tier (CPU Basic):**
- ✅ RAM: 16 GB (cukup untuk model 146MB)
- ✅ Storage: 50 GB
- ✅ Suitable untuk testing

**Upgrade (jika perlu):**
- CPU Upgrade: Lebih cepat inference
- GPU: Tidak perlu (HOG+SVM CPU-optimized)

## 📱 Integration dengan Flutter

### Update API Endpoint di Flutter

1. **Update `api_config.dart`:**

```dart
class ApiConfig {
  // Replace dengan Hugging Face Space URL
  static const String huggingFaceUrl = 
    'https://YOUR_USERNAME-clothing-detection-hog-svm.hf.space';
  
  // API endpoint
  static String get mlDetectionEndpoint => 
    '$huggingFaceUrl/api/predict';
}
```

2. **Update `clothing_detection_service.dart`:**

```dart
static Future<Map<String, dynamic>> detectClothing(
  String imagePath, 
  int userId
) async {
  try {
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse(ApiConfig.mlDetectionEndpoint)
    );
    
    // Attach image file (parameter name harus 'data' untuk Gradio)
    request.files.add(
      await http.MultipartFile.fromPath('data', imagePath)
    );
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      // Gradio response format: {"data": [result_text, json_string]}
      final jsonResult = json.decode(result['data'][1]);
      return jsonResult;
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}'
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error: $e'
    };
  }
}
```

## 🧪 Testing

### Test via Browser
1. Buka Space URL
2. Upload image
3. Verify prediction results

### Test via API (Python)
```python
import requests

url = "https://YOUR_USERNAME-clothing-detection-hog-svm.hf.space/api/predict"
files = {"data": open("test_image.jpg", "rb")}
response = requests.post(url, files=files)
print(response.json())
```

### Test via API (curl)
```bash
curl -X POST \
  -F "data=@test_image.jpg" \
  https://YOUR_USERNAME-clothing-detection-hog-svm.hf.space/api/predict
```

## 🐛 Troubleshooting

### Build Errors

**Error: Model file too large**
- Solution: Gunakan Git LFS
  ```bash
  git lfs track "*.pkl"
  git add .gitattributes
  ```

**Error: Out of memory**
- Solution: Upgrade ke CPU Upgrade tier di Space settings

**Error: Requirements install failed**
- Solution: Check requirements.txt versions
- Use pinned versions (e.g., `gradio==4.44.1`)

### Runtime Errors

**Error: Model not found**
- Check file paths di `app.py`
- Ensure models uploaded to `models/` directory

**Slow inference**
- First prediction slow (model loading)
- Subsequent predictions faster
- Consider CPU Upgrade for production

## 🚀 Production Tips

1. **Enable Persistent Storage**
   - Go to Space Settings
   - Enable "Persistent Storage"
   - Model stays loaded between requests

2. **Set Public/Private**
   - Settings → Visibility
   - Set to Public untuk production

3. **Add Domain (Optional)**
   - Go to Space Settings
   - Configure custom domain

4. **Monitor Usage**
   - Check Analytics tab
   - Track API calls
   - Monitor errors

## 📊 Expected Performance

- **First Prediction:** ~5-10 seconds (cold start, model loading)
- **Subsequent Predictions:** ~1-2 seconds
- **Model Loading:** 146 MB (one-time)
- **Memory Usage:** ~500-700 MB
- **Concurrent Users:** ~10-20 (CPU Basic)

## ✅ Checklist

- [ ] Hugging Face account created
- [ ] Space created
- [ ] Model files uploaded (146 MB)
- [ ] Dependencies installed
- [ ] App running successfully
- [ ] Test predictions working
- [ ] Flutter app updated with new endpoint
- [ ] End-to-end testing complete

## 🔗 Resources

- [Hugging Face Spaces Docs](https://huggingface.co/docs/hub/spaces)
- [Gradio Docs](https://www.gradio.app/docs)
- [Git LFS Setup](https://git-lfs.github.com/)

## 📝 Notes

- **Free tier cukup** untuk development & testing
- Model sudah optimized (HOG+SVM lebih efficient dari CNN)
- No GPU needed (CPU inference fast enough)
- **Deployment time:** ~10-15 menit total
