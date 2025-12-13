# Docker Deployment untuk ML API

## Keuntungan Docker vs Gradio:

✅ **Lebih Cepat**: Inference langsung tanpa queue  
✅ **Simple**: REST API murni, no WebSocket  
✅ **Production-Ready**: Gunicorn + health checks  
✅ **Portable**: Run di mana aja (local/cloud)  
✅ **No Dependencies on Gradio**: Full control API  

---

## Quick Start - Local

### 1. Build Docker Image

```bash
cd backend
docker build -t pcvk-ml-api .
```

Build time: ~5-10 menit (first time)

### 2. Run Container

**Simple:**
```bash
docker run -d -p 5000:5000 --name pcvk-ml pcvk-ml-api
```

**With Docker Compose:**
```bash
docker-compose up -d
```

### 3. Test API

```bash
# Health check
curl http://localhost:5000/health

# Test detection (replace with your image)
curl -X POST -F "data=@test_image.jpg" http://localhost:5000/detect
```

### 4. Update Flutter

```dart
static String get mlDetectionEndpoint => 'http://192.168.1.7:5000/detect';
```

### 5. Logs & Monitoring

```bash
# View logs
docker logs -f pcvk-ml

# Check status
docker ps

# Stats
docker stats pcvk-ml
```

---

## Deploy ke Cloud

### **Railway.app** (Recommended - Free Tier)

1. **Push ke GitHub**:
   ```bash
   git add backend/Dockerfile backend/ml_api_docker.py backend/requirements_docker.txt
   git commit -m "Add Docker ML API"
   git push
   ```

2. **Deploy di Railway**:
   - Buka https://railway.app
   - New Project → Deploy from GitHub
   - Select repo: `New_PBL_Jawara`
   - Root directory: `/backend`
   - Railway auto-detect Dockerfile
   - Generate Domain → `https://pcvk-ml.up.railway.app`

3. **Update Flutter**:
   ```dart
   static String get mlDetectionEndpoint => 
     'https://pcvk-ml.up.railway.app/detect';
   ```

### **Render.com** (Alternative)

1. Create `render.yaml`:
   ```yaml
   services:
     - type: web
       name: ml-api
       runtime: docker
       dockerfilePath: ./backend/Dockerfile
       dockerContext: ./backend
       envVars:
         - key: PORT
           value: 5000
   ```

2. Connect repo → Auto deploy

### **DigitalOcean App Platform**

1. Upload Docker image ke registry
2. Create app from container
3. Deploy

---

## Development

### Rebuild after changes:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Run without Docker (testing):
```bash
cd backend
python ml_api_docker.py
```

---

## Performance

- **Cold start**: ~2 seconds (vs 30-60s Gradio)
- **Inference time**: 1-3 seconds per image
- **Memory**: ~500MB (model loaded in RAM)
- **Concurrent requests**: 2 workers (adjustable in Dockerfile)

---

## Monitoring

Container exposes:
- `GET /`: API info
- `GET /health`: Health check with model status
- `POST /detect`: Main inference endpoint

Response format sama dengan Gradio (backward compatible):
```json
{
  "data": [
    "{\"success\": true, \"predicted_class\": \"Topi\", \"confidence\": 0.998, ...}"
  ]
}
```

---

## Troubleshooting

**Build failed - out of memory:**
```bash
# Increase Docker memory limit (Docker Desktop → Settings → Resources)
# Or build on cloud (Railway auto-build)
```

**Permission denied:**
```bash
# Windows: Run PowerShell as Admin
# Linux/Mac: Add user to docker group
sudo usermod -aG docker $USER
```

**Port 5000 already in use:**
```bash
# Change port in docker-compose.yml
ports:
  - "5001:5000"  # Host:Container
```

---

## Next Steps

1. ✅ Build image: `docker build -t pcvk-ml-api .`
2. ✅ Run container: `docker-compose up -d`
3. ✅ Test health: `curl http://localhost:5000/health`
4. ✅ Update Flutter config
5. ✅ Test detection dari app
6. 🚀 Deploy ke Railway (production)
