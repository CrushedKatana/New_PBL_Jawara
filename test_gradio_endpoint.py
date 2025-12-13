"""
Test correct Gradio endpoint
"""
import requests
import json

# Correct Gradio endpoint format
url = "https://crushedkatana-clothing-detection-api.hf.space/run/predict_clothing"

# Test with URL image first (easier)
payload = {
    "data": ["https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png"]
}

print("🧪 Testing CORRECT Gradio endpoint...")
print(f"📍 URL: {url}")
print(f"📦 Payload: {payload}")
print()

try:
    response = requests.post(url, json=payload, timeout=30)
    
    print(f"📥 Status: {response.status_code}")
    print(f"📥 Response: {response.text[:1000]}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"\n✅ Success!")
        print(json.dumps(result, indent=2, ensure_ascii=False))
        
except Exception as e:
    print(f"❌ Exception: {e}")

print("\n" + "="*70)
print("Now testing with file upload...")
print("="*70)

# Test with file upload
url_upload = "https://crushedkatana-clothing-detection-api.hf.space/run/predict_clothing"
image_path = "ml_training/dataset/Filtered_Image/Hat_00d94e21-5891-492e-be0e-792e7338c077.jpg"

try:
    import base64
    with open(image_path, 'rb') as f:
        img_data = base64.b64encode(f.read()).decode()
    
    payload = {
        "data": [f"data:image/jpeg;base64,{img_data}"]
    }
    
    response = requests.post(url_upload, json=payload, timeout=30)
    print(f"📥 Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Result: {json.dumps(result, indent=2, ensure_ascii=False)}")
        
except Exception as e:
    print(f"❌ Exception: {e}")
