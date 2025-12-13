# Deploy ML API ke Railway.app (Free Tier)

## Step 1: Persiapan

1. Buat akun di https://railway.app (login with GitHub)
2. Install Railway CLI (optional):
   ```
   npm install -g @railway/cli
   ```

## Step 2: Siapkan Files

File yang sudah ada:
- ✅ `ml_api_wrapper.py` (Flask API)
- ✅ `requirements_wrapper.txt` (dependencies)
- ✅ `clothing_svm_best.pkl` (model)
- ✅ `clothing_scaler_best.pkl` (scaler)

Tambah file baru:

### `Procfile`
```
web: gunicorn ml_api_wrapper:app
```

### Update `requirements_wrapper.txt`
```
flask==3.0.0
flask-cors==4.0.0
gradio-client==0.8.1
Werkzeug==3.0.1
gunicorn==21.2.0
```

## Step 3: Deploy

### Via Web UI:
1. Buka https://railway.app/dashboard
2. Klik **New Project** → **Deploy from GitHub repo**
3. Pilih repo: `New_PBL_Jawara`
4. Root directory: `/backend`
5. Railway auto-detect Python + Procfile
6. Click **Deploy**
7. Generate domain: Settings → **Generate Domain**
8. URL: `https://your-app-name.up.railway.app`

### Via CLI:
```bash
cd backend
railway login
railway init
railway up
railway open
```

## Step 4: Update Flutter

```dart
static String get mlDetectionEndpoint => 
  'https://your-app-name.up.railway.app/detect';
```

## Free Tier Limits

- $5 free credit/month
- ~500-1000 requests (tergantung usage)
- Auto-sleep jika idle (cold start 5-10 detik)

## Alternative: Render.com

Same process, tapi dengan `render.yaml`:

```yaml
services:
  - type: web
    name: ml-api
    env: python
    buildCommand: pip install -r requirements_wrapper.txt
    startCommand: gunicorn ml_api_wrapper:app
    envVars:
      - key: PYTHON_VERSION
        value: 3.10
```

Deploy: Connect GitHub → Auto deploy on push

## Monitoring

Railway Dashboard menampilkan:
- CPU/Memory usage
- Request logs
- Error tracking
- Deployment history
