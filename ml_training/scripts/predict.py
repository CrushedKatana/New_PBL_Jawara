"""
Prediction Script untuk Model SVM Deteksi Pakaian
Script ini dipanggil dari backend PHP untuk melakukan prediksi
Metode: HOG (Histogram of Oriented Gradients) + SVM (Support Vector Machine)
"""

import os
import sys
import numpy as np
import cv2
import json
import argparse
import joblib
from skimage.feature import hog

def load_model_and_scaler(model_path, scaler_path):
    """Load trained SVM model and scaler"""
    try:
        model = joblib.load(model_path)
        scaler = joblib.load(scaler_path)
        return model, scaler
    except Exception as e:
        print(json.dumps({
            'success': False,
            'message': f'Failed to load model or scaler: {str(e)}'
        }))
        sys.exit(1)

def load_label_mapping(mapping_path='../models/label_mapping.json'):
    """Load label mapping with multiple fallback locations"""
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Try multiple locations
        possible_paths = [
            mapping_path,  # Original path
            os.path.join(script_dir, mapping_path),  # Relative to script
            os.path.join(script_dir, '..', 'models', 'label_mapping.json'),  # Explicit relative
            os.path.join(os.path.dirname(script_dir), 'models', 'label_mapping.json'),  # Parent dir
        ]
        
        # Try each path
        for path in possible_paths:
            if os.path.exists(path):
                with open(path, 'r') as f:
                    mapping = json.load(f)
                return {int(k): v for k, v in mapping.items()}
        
        # If none found, raise error with attempted paths
        raise FileNotFoundError(f"label_mapping.json not found. Tried: {possible_paths}")
        
    except Exception as e:
        print(json.dumps({
            'success': False,
            'message': f'Failed to load label mapping: {str(e)}'
        }))
        sys.exit(1)

def preprocess_image(image_path, image_size=(128, 128)):
    """
    Preprocess image untuk HOG feature extraction
    
    Args:
        image_path: Path to image file
        image_size: Target size for resize
        
    Returns:
        Preprocessed grayscale image
    """
    try:
        # Read image
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Failed to read image: {image_path}")
        
        # Convert to grayscale
        img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Resize
        img_resized = cv2.resize(img_gray, image_size)
        
        # Histogram equalization
        img_equalized = cv2.equalizeHist(img_resized)
        
        return img_equalized
    except Exception as e:
        print(json.dumps({
            'success': False,
            'message': f'Failed to preprocess image: {str(e)}'
        }))
        sys.exit(1)

def extract_hog_features(img, orientations=9, pixels_per_cell=(8, 8), 
                        cells_per_block=(2, 2), transform_sqrt=True):
    """
    Extract HOG features dari gambar
    
    Args:
        img: Grayscale image array
        
    Returns:
        HOG feature vector
    """
    try:
        features = hog(
            img,
            orientations=orientations,
            pixels_per_cell=pixels_per_cell,
            cells_per_block=cells_per_block,
            transform_sqrt=transform_sqrt,
            visualize=False,
            feature_vector=True
        )
        return features
    except Exception as e:
        print(json.dumps({
            'success': False,
            'message': f'Failed to extract HOG features: {str(e)}'
        }))
        sys.exit(1)

def predict(model, scaler, hog_features, label_mapping):
    """
    Make prediction using SVM model
    
    Args:
        model: Trained SVM model
        scaler: Fitted StandardScaler
        hog_features: HOG feature vector
        label_mapping: Dictionary mapping class indices to names
        
    Returns:
        Prediction results
    """
    try:
        # Reshape features
        if len(hog_features.shape) == 1:
            hog_features = hog_features.reshape(1, -1)
        
        # Normalize features
        hog_features_scaled = scaler.transform(hog_features)
        
        # Get predictions - LinearSVC uses decision_function, not predict_proba
        if hasattr(model, 'predict_proba'):
            # For SVC with probability=True
            predictions = model.predict_proba(hog_features_scaled)
            predicted_class_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][predicted_class_idx])
            
            # Get top 3 predictions
            top3_indices = np.argsort(predictions[0])[-3:][::-1]
            top3_predictions = [
                {
                    'class': label_mapping[idx],
                    'confidence': float(predictions[0][idx])
                }
                for idx in top3_indices
            ]
        else:
            # For LinearSVC - use decision_function
            decision_scores = model.decision_function(hog_features_scaled)[0]
            
            # Convert decision scores to confidence-like values (0-1 range)
            # Using softmax function
            exp_scores = np.exp(decision_scores - np.max(decision_scores))
            confidences = exp_scores / np.sum(exp_scores)
            
            predicted_class_idx = np.argmax(confidences)
            confidence = float(confidences[predicted_class_idx])
            
            # Get top 3 predictions
            top3_indices = np.argsort(confidences)[-3:][::-1]
            top3_predictions = [
                {
                    'class': label_mapping[idx],
                    'confidence': float(confidences[idx])
                }
                for idx in top3_indices
            ]
        
        predicted_class = label_mapping[predicted_class_idx]
        
        return {
            'success': True,
            'predicted_class': predicted_class,
            'confidence': confidence,
            'top3_predictions': top3_predictions,
            'method': 'HOG + SVM'
        }
    except Exception as e:
        print(json.dumps({
            'success': False,
            'message': f'Prediction failed: {str(e)}'
        }))
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Predict clothing category from image using HOG+SVM')
    parser.add_argument('--image', type=str, required=True, help='Path to image file')
    parser.add_argument('--model', type=str, required=True, help='Path to trained SVM model (.pkl)')
    parser.add_argument('--scaler', type=str, default=None, 
                       help='Path to fitted scaler (.pkl). If not provided, will try to infer from model path')
    parser.add_argument('--label-mapping', type=str, 
                       default='../models/label_mapping.json',
                       help='Path to label mapping JSON')
    
    args = parser.parse_args()
    
    # Infer scaler path if not provided
    if args.scaler is None:
        # Replace 'model' with 'scaler' in the model path
        args.scaler = args.model.replace('svm_model', 'scaler').replace('svm_best', 'scaler_best')
    
    # Load model, scaler, and label mapping
    model, scaler = load_model_and_scaler(args.model, args.scaler)
    label_mapping = load_label_mapping(args.label_mapping)
    
    # Preprocess image
    img = preprocess_image(args.image)
    
    # Extract HOG features
    hog_features = extract_hog_features(img)
    
    # Make prediction
    result = predict(model, scaler, hog_features, label_mapping)
    
    # Output result as JSON
    print(json.dumps(result))

if __name__ == "__main__":
    main()
