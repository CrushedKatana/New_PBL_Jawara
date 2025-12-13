"""
Simple Flask wrapper for Hugging Face Gradio Space
This provides a simple REST API that Flutter can call
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
from gradio_client import Client
import os
import tempfile
import json

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter

# Hugging Face Space URL
HF_SPACE_URL = "https://crushedkatana-clothing-detection-api.hf.space"

# Initialize Gradio Client
print(f"🔗 Connecting to Hugging Face Space: {HF_SPACE_URL}")
client = Client(HF_SPACE_URL)
print("✅ Connected successfully!")

@app.route('/detect', methods=['POST'])
def detect_clothing():
    """
    Endpoint untuk deteksi pakaian
    Accepts: multipart/form-data with 'data' field (image file)
    Returns: JSON in Gradio format {"data": ["json_string"]}
    """
    try:
        # Check if image file exists in request
        if 'data' not in request.files:
            return jsonify({
                'success': False,
                'message': 'No image file provided'
            }), 400
        
        file = request.files['data']
        
        if file.filename == '':
            return jsonify({
                'success': False,
                'message': 'Empty filename'
            }), 400
        
        # Save to temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as tmp_file:
            file.save(tmp_file.name)
            temp_path = tmp_file.name
        
        print(f"📁 Processing image: {file.filename}")
        print(f"📂 Temp path: {temp_path}")
        
        try:
            # Call Gradio API using official client
            print("🚀 Calling Hugging Face API...")
            result = client.predict(
                data=temp_path,
                api_name="/predict_clothing"
            )
            
            print(f"✅ API Result: {result}")
            
            # Result should be in format: ["json_string"]
            # Wrap in Gradio format for consistency with mock
            if isinstance(result, list) and len(result) > 0:
                # Already in correct format
                return jsonify({"data": result})
            else:
                # Unexpected format
                return jsonify({
                    "data": [json.dumps({
                        'success': False,
                        'message': 'Unexpected API response format',
                        'raw_result': str(result)
                    })]
                })
        
        finally:
            # Cleanup temp file
            if os.path.exists(temp_path):
                os.remove(temp_path)
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        
        return jsonify({
            "data": [json.dumps({
                'success': False,
                'message': f'Server error: {str(e)}'
            })]
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'huggingface_space': HF_SPACE_URL,
        'client_connected': client is not None
    })

if __name__ == '__main__':
    print("🚀 Starting ML API Wrapper...")
    print(f"📍 API will be available at: http://localhost:5000/detect")
    print(f"🔗 Proxying to: {HF_SPACE_URL}")
    print("")
    app.run(host='0.0.0.0', port=5000, debug=True)
