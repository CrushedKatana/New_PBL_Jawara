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
    """Load label mapping"""
    try:
        with open(mapping_path, 'r') as f:
            mapping = json.load(f)
        return {int(k): v for k, v in mapping.items()}
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
        
        # Get predictions
        predictions = model.predict_proba(hog_features_scaled)
        
        # Get predicted class
        predicted_class_idx = np.argmax(predictions[0])
        predicted_class = label_mapping[predicted_class_idx]
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
