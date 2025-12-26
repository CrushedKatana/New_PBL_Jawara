"""
Test Hugging Face API endpoint untuk verify working
"""
import requests
import json

url = "https://crushedkatana-clothing-detection-api.hf.space/api/predict"
image_path = "ml_training/dataset/Filtered_Image/Hat_00d94e21-5891-492e-be0e-792e7338c077.jpg"

print("🧪 Testing Hugging Face API...")
print(f"📍 URL: {url}")
print(f"📷 Image: {image_path}")
print()

try:
    with open(image_path, 'rb') as f:
        files = {'data': f}
        response = requests.post(url, files=files, timeout=30)
    
    print(f"📥 Status: {response.status_code}")
    print(f"📥 Headers: {dict(response.headers)}")
    print()
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Success!")
        print(f"📦 Response: {json.dumps(result, indent=2, ensure_ascii=False)}")
        
        # Check format
        if 'data' in result:
            print("\n🔄 Gradio wrapped format detected")
            if isinstance(result['data'], list) and len(result['data']) > 0:
                inner = json.loads(result['data'][0])
                print(f"✅ Predicted: {inner['predicted_class']} ({inner['confidence']*100:.2f}%)")
    else:
        print(f"❌ Error: {response.status_code}")
        print(f"📝 Body: {response.text[:500]}")
        
except Exception as e:
    print(f"❌ Exception: {e}")
