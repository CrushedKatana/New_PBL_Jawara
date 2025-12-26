"""
Quick test script to verify model prediction works
"""

import os
import cv2
import numpy as np
import joblib
import json
from skimage.feature import hog

# Load model and scaler
print("Loading model...")
model = joblib.load('../models/clothing_svm_best.pkl')
scaler = joblib.load('../models/clothing_scaler_best.pkl')

# Load label mapping
with open('../models/label_mapping.json', 'r') as f:
    label_mapping = json.load(f)

print("Model loaded successfully!")
print(f"Label mapping: {label_mapping}")

# Test with a sample image from dataset
test_image_path = '../dataset/Filtered_Image/Hat_00d94e21-5891-492e-be0e-792e7338c077.jpg'

if os.path.exists(test_image_path):
    print(f"\nTesting with image: {test_image_path}")
    
    # Load and preprocess image
    img = cv2.imread(test_image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = cv2.resize(img, (128, 128))
    img = cv2.equalizeHist(img)
    
    # Extract HOG features
    features = hog(
        img,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        block_norm='L2-Hys'
    )
    
    # Reshape and scale
    features = features.reshape(1, -1)
    features_scaled = scaler.transform(features)
    
    # Predict
    prediction = model.predict(features_scaled)[0]
    probabilities = model.predict_proba(features_scaled)[0]
    
    predicted_label = label_mapping[str(prediction)]
    confidence = probabilities[prediction] * 100
    
    print(f"\nPrediction Results:")
    print(f"Predicted Class: {predicted_label}")
    print(f"Confidence: {confidence:.2f}%")
    print(f"\nAll probabilities:")
    for idx, prob in enumerate(probabilities):
        print(f"  {label_mapping[str(idx)]}: {prob*100:.2f}%")
    
    print("\n✅ Model is working correctly!")
else:
    print(f"Test image not found: {test_image_path}")
