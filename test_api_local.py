"""
Test clothing detection API locally before deploying
"""
import cv2
import numpy as np
import joblib
from skimage.feature import hog
from PIL import Image

# Load model
model = joblib.load('ml_training/models/clothing_svm_best.pkl')
scaler = joblib.load('ml_training/models/clothing_scaler_best.pkl')

label_mapping = {
    0: "Topi",
    1: "Kemeja",
    2: "Sepatu",
    3: "T-Shirt"
}

def extract_hog_features(img, image_size=(128, 128)):
    """Extract HOG features - EXACT match with training"""
    # Resize
    img_resized = cv2.resize(img, image_size)
    
    # Histogram equalization (CRITICAL!)
    img_equalized = cv2.equalizeHist(img_resized)
    
    # Extract HOG with transform_sqrt (CRITICAL!)
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
    """Test prediction"""
    # Read image
    img = cv2.imread(image_path)
    
    # Convert to grayscale
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Extract features
    hog_features = extract_hog_features(img_gray)
    
    # Scale
    hog_features_scaled = scaler.transform([hog_features])
    
    # Predict
    probabilities = model.predict_proba(hog_features_scaled)[0]
    predicted_class_idx = np.argmax(probabilities)
    confidence = probabilities[predicted_class_idx]
    
    # Top 3
    top3_indices = np.argsort(probabilities)[-3:][::-1]
    top3 = [
        {
            'class': label_mapping[idx],
            'confidence': float(probabilities[idx])
        }
        for idx in top3_indices
    ]
    
    return {
        'predicted_class': label_mapping[predicted_class_idx],
        'confidence': float(confidence),
        'top3': top3
    }

# Test with Hat images
test_images = [
    'ml_training/dataset/Filtered_Image/Hat_00d94e21-5891-492e-be0e-792e7338c077.jpg',
]

print("="*70)
print("TESTING LOCAL MODEL")
print("="*70)

for img_path in test_images:
    print(f"\n📸 Testing: {img_path.split('/')[-1]}")
    result = predict_clothing(img_path)
    print(f"✅ Predicted: {result['predicted_class']} ({result['confidence']*100:.2f}%)")
    print(f"📊 Top 3:")
    for i, pred in enumerate(result['top3'], 1):
        print(f"   {i}. {pred['class']}: {pred['confidence']*100:.2f}%")
