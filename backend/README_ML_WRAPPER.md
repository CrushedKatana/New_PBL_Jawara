# ML API Wrapper untuk Hugging Face

Backend Python sederhana yang menyediakan REST API untuk Flutter, dan connect ke Hugging Face Space menggunakan `gradio_client`.

## Instalasi

```bash
cd backend
pip install -r requirements_wrapper.txt
```

## Menjalankan

```bash
python ml_api_wrapper.py
```

Server akan berjalan di: `http://localhost:5000`

## Endpoints

### POST /detect
Deteksi kategori pakaian dari gambar

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: field 'data' berisi image file

**Response:**
```json
{
  "data": [
    "{\"success\": true, \"predicted_class\": \"Topi\", \"confidence\": 0.998, ...}"
  ]
}
```

### GET /health
Health check untuk cek status server

## Update Flutter Config

Setelah server berjalan, update `lib/config/api_config.dart`:

```dart
static String get mlDetectionEndpoint => 'http://192.168.1.7:5000/detect';
```

(Ganti 192.168.1.7 dengan IP komputer Anda)

## Troubleshooting

**Import Error gradio_client:**
```bash
pip install --upgrade gradio-client
```

**Connection Error:**
- Pastikan Hugging Face Space masih aktif
- Cek internet connection
- Space mungkin cold start (tunggu 1-2 menit)

**Port 5000 already in use:**
Ganti port di `ml_api_wrapper.py` line terakhir:
```python
app.run(host='0.0.0.0', port=5001, debug=True)
```
