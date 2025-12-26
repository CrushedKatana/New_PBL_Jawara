# 🚀 Panduan Deploy ke Hugging Face

## Prerequisites

1. **Akun Hugging Face**
   - Buat akun di https://huggingface.co/
   - Verifikasi email

2. **Git LFS (Large File Storage)**
   - Download dari: https://git-lfs.github.com/
   - Install: `git lfs install`

3. **Hugging Face CLI**
   ```bash
   pip install huggingface_hub
   huggingface-cli login
   ```

## 📦 Persiapan Files

### 1. Copy Model Files

Copy 3 file model ke folder `huggingface_deployment`:

```bash
# Dari ml_training/models/ copy ke huggingface_deployment/
copy d:\CloneGithub\New_PBL_Jawara\ml_training\models\clothing_svm_best.pkl huggingface_deployment\
copy d:\CloneGithub\New_PBL_Jawara\ml_training\models\clothing_scaler_best.pkl huggingface_deployment\
copy d:\CloneGithub\New_PBL_Jawara\ml_training\models\label_mapping.json huggingface_deployment\
```

### 2. Verifikasi Structure

```
huggingface_deployment/
├── app.py                      # Gradio app
├── requirements.txt            # Dependencies
├── README.md                   # Space README
├── clothing_svm_best.pkl      # Model (145MB) - COPY THIS!
├── clothing_scaler_best.pkl   # Scaler - COPY THIS!
└── label_mapping.json         # Labels - COPY THIS!
```

## 🌐 Deploy ke Hugging Face

### Option 1: Via Web UI (RECOMMENDED)

1. **Create New Space**
   - Go to: https://huggingface.co/new-space
   - Space name: `clothing-detection-api` (atau nama lain)
   - License: MIT
   - SDK: Gradio
   - Hardware: CPU Basic (free) atau GPU untuk lebih cepat

2. **Upload Files**
   - Click "Files and versions" tab
   - Click "Add file" → "Upload files"
   - Upload semua files:
     - `app.py`
     - `requirements.txt`
     - `README.md`
     - `clothing_svm_best.pkl` (145MB - akan take time)
     - `clothing_scaler_best.pkl`
     - `label_mapping.json`

3. **Wait for Build**
   - Space akan auto-build
   - Tunggu ~5-10 menit (loading model besar)
   - Status "Running" = SUCCESS ✅

### Option 2: Via Git CLI

```bash
cd huggingface_deployment

# Clone space repository
git clone https://huggingface.co/spaces/YOUR-USERNAME/clothing-detection-api
cd clothing-detection-api

# Enable Git LFS untuk large files
git lfs install
git lfs track "*.pkl"

# Copy files
copy ..\app.py .
copy ..\requirements.txt .
copy ..\README.md .
copy ..\clothing_svm_best.pkl .
copy ..\clothing_scaler_best.pkl .
copy ..\label_mapping.json .

# Commit and push
git add .
git commit -m "Initial deployment: HOG+SVM clothing detection"
git push
```

## 🧪 Test API

### 1. Test via Web Interface

```
https://huggingface.co/spaces/YOUR-USERNAME/clothing-detection-api
```

Upload gambar dan lihat hasil!

### 2. Test via Python API

```python
import requests
import json

# Your Space API URL
API_URL = "https://YOUR-USERNAME-clothing-detection-api.hf.space/api/predict"

# Test with image
with open("test_image.jpg", "rb") as f:
    files = {"data": f}
    response = requests.post(API_URL, files=files)
    
result = response.json()
print(json.dumps(result, indent=2))
```

### 3. Test via cURL

```bash
curl -X POST \
  https://YOUR-USERNAME-clothing-detection-api.hf.space/api/predict \
  -F "data=@test_image.jpg"
```

## 🔗 Integrasi dengan Flutter App

Update `api_config.dart`:

```dart
class ApiConfig {
  // Hugging Face API endpoint
  static const String mlDetectionEndpoint = 
    'https://YOUR-USERNAME-clothing-detection-api.hf.space/api/predict';
}
```

Update `clothing_detection_service.dart`:

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
    
    // Attach image
    request.files.add(
      await http.MultipartFile.fromPath('data', imagePath)
    );
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      
      // Hugging Face returns in 'data' field
      if (result.containsKey('data')) {
        return json.decode(result['data'][0]);
      }
      return result;
    }
    
    return {
      'success': false,
      'message': 'Server error: ${response.statusCode}'
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Error: $e'
    };
  }
}
```

## ⚡ Performance Tips

### 1. Hardware Upgrade (Paid)

Untuk inference lebih cepat:
- Space Settings → Hardware
- Upgrade ke GPU T4 (~$0.60/hour)
- Response time: 3-5x lebih cepat

### 2. Model Optimization (Future)

Convert ke format lebih efisien:
- ONNX Runtime (2-3x faster)
- Quantization (reduce size 4x)
- TensorRT (for GPU)

### 3. Caching

Tambahkan caching di backend PHP untuk response yang sama:
```php
$cache_key = md5_file($imagePath);
$cache_file = "cache/{$cache_key}.json";

if (file_exists($cache_file) && (time() - filemtime($cache_file) < 3600)) {
    return json_decode(file_get_contents($cache_file), true);
}
```

## 📊 Monitoring

Check Space logs:
```
https://huggingface.co/spaces/YOUR-USERNAME/clothing-detection-api/logs
```

Monitor:
- Request count
- Response time
- Error rate
- Memory usage

## 🔒 Security (Optional)

### Add API Key Authentication

Edit `app.py`:

```python
import os

API_KEY = os.getenv("API_KEY", "your-secret-key")

def predict_clothing(image, api_key):
    if api_key != API_KEY:
        return "❌ Invalid API Key", json.dumps({
            'success': False,
            'message': 'Invalid API Key'
        })
    # ... rest of code
```

Set in Space Settings → Variables:
- Key: `API_KEY`
- Value: `your-secret-key-here`

## 🎉 Success Checklist

- [ ] Model files uploaded (145MB)
- [ ] Space builds successfully
- [ ] Status shows "Running"
- [ ] Web interface works
- [ ] API endpoint responds
- [ ] Flutter app integrated
- [ ] Detection working 85%+ confidence

## 🆘 Troubleshooting

**Build fails:**
- Check requirements.txt versions
- Ensure all files uploaded
- Check logs for errors

**Model not loading:**
- Verify .pkl files not corrupted
- Check file size (should be 145MB)
- Ensure Git LFS enabled

**Slow response:**
- Normal for CPU (5-10 seconds)
- Upgrade to GPU for faster
- Add caching layer

**API endpoint not working:**
- Check Space is "Running"
- Verify URL format
- Test with cURL first

## 📞 Support

- Hugging Face Docs: https://huggingface.co/docs/hub/spaces
- Community: https://discuss.huggingface.co/
- Discord: https://hf.co/join/discord
