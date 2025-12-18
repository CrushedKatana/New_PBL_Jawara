"""
Use Gradio Client library (recommended way)
"""
try:
    from gradio_client import Client
except ImportError:
    print("Installing gradio_client...")
    import subprocess
    subprocess.check_call(['pip', 'install', 'gradio_client'])
    from gradio_client import Client

print("🧪 Testing with Gradio Client...")

client = Client("https://crushedkatana-clothing-detection-api.hf.space/")

# Get API info
print("\n📋 API Info:")
print(client.view_api())

print("\n" + "="*70)
print("Testing prediction...")
print("="*70)

# Test with image
image_path = "ml_training/dataset/Filtered_Image/Hat_00d94e21-5891-492e-be0e-792e7338c077.jpg"

try:
    result = client.predict(
        image_path,
        api_name="/predict_clothing"
    )
    
    print(f"\n✅ Result: {result}")
    
    # Parse result
    if isinstance(result, tuple) and len(result) >= 2:
        markdown_text = result[0]
        json_result = result[1]
        
        import json
        ml_result = json.loads(json_result)
        print(f"\n🎯 Prediction:")
        print(f"   Class: {ml_result['predicted_class']}")
        print(f"   Confidence: {ml_result['confidence']*100:.2f}%")
        print(f"   Top 3: {ml_result['top3_predictions']}")
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
