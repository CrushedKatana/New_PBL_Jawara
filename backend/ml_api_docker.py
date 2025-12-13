"""
ML API Docker Version - Direct inference tanpa Gradio
Lebih cepat, simple, dan production-ready
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import joblib
from skimage.feature import hog
import tempfile
import os
import json
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Load model and scaler saat startup
print("🔄 Loading ML model...")
model = joblib.load('clothing_svm_best.pkl')
scaler = joblib.load('clothing_scaler_best.pkl')
print("✅ Model loaded successfully!")

# Label mapping (Indonesian)
LABELS = {
    0: "Topi",
    1: "Kemeja", 
    2: "Sepatu",
    3: "T-Shirt"
}

def extract_hog_features(image):
    """
    Extract HOG features dengan preprocessing yang sama seperti training
    CRITICAL: Harus sama persis dengan training pipeline!
    """
    # Convert to grayscale (RGB -> Gray direct, bukan RGB->BGR->Gray)
    if len(image.shape) == 3:
        img = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    else:
        img = image
    
    # Resize to 128x128
    img_resized = cv2.resize(img, (128, 128))
    
    # CRITICAL: Histogram equalization (contrast normalization)
    img_equalized = cv2.equalizeHist(img_resized)
    
    # Extract HOG features
    # CRITICAL: transform_sqrt=True (square root normalization)
    features = hog(
        img_equalized,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        block_norm='L2-Hys',
        transform_sqrt=True,  # CRITICAL parameter
        visualize=False,
        feature_vector=True
    )
    
    return features

def predict_clothing(image_path):
    """
    Predict clothing category from image
    Returns: dict with prediction results
    """
    try:
        # Read image
        image = cv2.imread(image_path)
        if image is None:
            return {
                'success': False,
                'message': f'Failed to read image: {image_path}'
            }
        
        # Convert BGR to RGB (OpenCV loads as BGR)
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        # Extract features
        features = extract_hog_features(image_rgb)
        
        # Scale features
        features_scaled = scaler.transform([features])
        
        # Predict
        prediction = model.predict(features_scaled)[0]
        probabilities = model.predict_proba(features_scaled)[0]
        
        # Get top 3 predictions
        top3_indices = np.argsort(probabilities)[-3:][::-1]
        top3_predictions = [
            {
                'class': LABELS[idx],
                'confidence': float(probabilities[idx])
            }
            for idx in top3_indices
        ]
        
        return {
            'success': True,
            'predicted_class': LABELS[prediction],
            'confidence': float(probabilities[prediction]),
            'top3_predictions': top3_predictions,
            'method': 'HOG + SVM (Docker)',
            'timestamp': datetime.now().isoformat()
        }
        
    except Exception as e:
        return {
            'success': False,
            'message': f'Prediction error: {str(e)}'
        }

@app.route('/detect', methods=['POST'])
def detect():
    """
    Main detection endpoint
    Accepts: multipart/form-data with 'data' field (image)
    Returns: Gradio-compatible JSON format
    """
    try:
        # Validate request
        if 'data' not in request.files:
            return jsonify({
                'success': False,
                'message': 'No image file provided (field: data)'
            }), 400
        
        file = request.files['data']
        
        if file.filename == '':
            return jsonify({
                'success': False,
                'message': 'Empty filename'
            }), 400
        
        # Save to temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as tmp:
            file.save(tmp.name)
            temp_path = tmp.name
        
        print(f"📁 Processing: {file.filename}")
        
        try:
            # Predict
            result = predict_clothing(temp_path)
            
            # Wrap in Gradio format for compatibility
            response = {
                "data": [json.dumps(result)]
            }
            
            if result['success']:
                print(f"✅ Detected: {result['predicted_class']} ({result['confidence']:.1%})")
            else:
                print(f"❌ Error: {result['message']}")
            
            return jsonify(response), 200
            
        finally:
            # Cleanup
            if os.path.exists(temp_path):
                os.remove(temp_path)
    
    except Exception as e:
        print(f"❌ Exception: {str(e)}")
        return jsonify({
            "data": [json.dumps({
                'success': False,
                'message': f'Server error: {str(e)}'
            })]
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'scaler_loaded': scaler is not None,
        'labels': LABELS,
        'version': '1.0.0-docker',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/', methods=['GET'])
def index():
    """Root endpoint with API info"""
    return jsonify({
        'name': 'PCVK Clothing Detection API',
        'version': '1.0.0-docker',
        'endpoints': {
            'POST /detect': 'Detect clothing category (multipart/form-data with data field)',
            'GET /health': 'Health check',
            'GET /': 'API information'
        },
        'model': 'HOG + RBF SVM',
        'categories': list(LABELS.values()),
        'status': 'ready'
    })

if __name__ == '__main__':
    print("🚀 Starting ML API (Docker)...")
    print("📍 Listening on http://0.0.0.0:5000")
    print("🎯 Ready for predictions!")
    app.run(host='0.0.0.0', port=5000, debug=False)
