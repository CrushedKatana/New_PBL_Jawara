"""
Test Gradio queue-based API (correct way)
"""
import requests
import json
import time
import base64

# Correct Gradio queue API
call_url = "https://crushedkatana-clothing-detection-api.hf.space/call/predict_clothing"

# Read and encode image
image_path = "ml_training/dataset/Filtered_Image/Hat_00d94e21-5891-492e-be0e-792e7338c077.jpg"
with open(image_path, 'rb') as f:
    img_data = base64.b64encode(f.read()).decode()

payload = {
    "data": [f"data:image/jpeg;base64,{img_data}"]
}

print("🧪 Testing Gradio Queue API...")
print(f"📍 Call URL: {call_url}")
print()

try:
    # Step 1: Join queue
    print("📤 Step 1: Joining queue...")
    call_response = requests.post(call_url, json=payload, timeout=10)
    print(f"📥 Status: {call_response.status_code}")
    print(f"📥 Response: {call_response.text}")
    
    if call_response.status_code == 200:
        call_result = call_response.json()
        event_id = call_result.get('event_id')
        
        if event_id:
            print(f"\n✅ Joined queue! Event ID: {event_id}")
            
            # Step 2: Poll for results
            poll_url = f"{call_url}/{event_id}"
            print(f"\n📊 Step 2: Polling results...")
            print(f"📍 Poll URL: {poll_url}")
            
            for i in range(15):  # Max 30 seconds
                time.sleep(2)
                poll_response = requests.get(poll_url)
                
                print(f"\n🔄 Poll {i+1}: Status {poll_response.status_code}")
                
                if poll_response.status_code == 200:
                    # Parse SSE format
                    lines = poll_response.text.split('\n')
                    for line in lines:
                        if line.startswith('data: '):
                            data = line[6:]  # Remove 'data: '
                            if data.strip():
                                try:
                                    event_data = json.loads(data)
                                    print(f"📦 Event: {event_data.get('msg')}")
                                    
                                    if event_data.get('msg') == 'process_completed':
                                        output = event_data.get('output', {})
                                        print(f"\n✅ SUCCESS!")
                                        print(json.dumps(output, indent=2, ensure_ascii=False))
                                        
                                        # Extract ML result
                                        if 'data' in output and len(output['data']) >= 2:
                                            ml_result = json.loads(output['data'][1])
                                            print(f"\n🎯 ML Result:")
                                            print(f"   Predicted: {ml_result['predicted_class']}")
                                            print(f"   Confidence: {ml_result['confidence']*100:.2f}%")
                                        
                                        exit(0)
                                except json.JSONDecodeError:
                                    pass
            
            print("\n⏱️ Timeout - no result after 30 seconds")
        else:
            print("❌ No event_id received")
    else:
        print(f"❌ Failed to join queue: {call_response.status_code}")
        
except Exception as e:
    print(f"❌ Exception: {e}")
    import traceback
    traceback.print_exc()
