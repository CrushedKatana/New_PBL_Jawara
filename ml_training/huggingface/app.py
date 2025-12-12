"""
Clothing Detection API - Hugging Face Space
FastAPI endpoint untuk deteksi kategori pakaian menggunakan HOG+SVM
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
import cv2
import joblib
import os
from typing import Dict, List
import io
from skimage.feature import hog

app = FastAPI(
    title="Clothing Detection API",
    description="API untuk deteksi kategori pakaian (Topi, Kemeja, Sepatu, T-Shirt) menggunakan HOG+SVM",
    version="1.0.0"
)

# CORS middleware untuk allow requests dari Flutter/web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables untuk model (load sekali saat startup)
model = None
scaler = None
label_mapping = None

# Label mapping
LABELS = {
    0: "Topi",
    1: "Kemeja",
    2: "Sepatu",
    3: "T-Shirt"
}

def load_models():
    """Load model, scaler saat startup"""
    global model, scaler, label_mapping
    
    try:
        model_path = "clothing_svm_best.pkl"
        scaler_path = "clothing_scaler_best.pkl"
        
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found: {model_path}")
        
        model = joblib.load(model_path)
        scaler = joblib.load(scaler_path)
        label_mapping = LABELS
        
        print("✅ Models loaded successfully!")
        print(f"   - Model: {type(model).__name__}")
        print(f"   - Categories: {list(label_mapping.values())}")
        
    except Exception as e:
        print(f"❌ Error loading models: {e}")
        raise

def extract_hog_features(image: np.ndarray) -> np.ndarray:
    """Extract HOG features from image"""
    # Resize to 128x128
    img_resized = cv2.resize(image, (128, 128))
    
    # Convert to grayscale if needed
    if len(img_resized.shape) == 3:
        img_gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    else:
        img_gray = img_resized
    
    # Extract HOG features
    hog_features = hog(
        img_gray,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        block_norm='L2-Hys',
        visualize=False,
        feature_vector=True
    )
    
    return hog_features

def predict_clothing(image_bytes: bytes) -> Dict:
    """Predict clothing category from image bytes"""
    try:
        # Decode image
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise ValueError("Failed to decode image")
        
        # Extract HOG features
        hog_features = extract_hog_features(img)
        hog_features = hog_features.reshape(1, -1)
        
        # Scale features
        hog_features_scaled = scaler.transform(hog_features)
        
        # Predict
        if hasattr(model, 'predict_proba'):
            # RBF SVC with probability
            probabilities = model.predict_proba(hog_features_scaled)[0]
            predicted_class_idx = np.argmax(probabilities)
            confidence = probabilities[predicted_class_idx]
            
            # Get top 3 predictions
            top3_indices = np.argsort(probabilities)[-3:][::-1]
            top3_predictions = [
                {
                    "class": label_mapping[idx],
                    "confidence": float(probabilities[idx])
                }
                for idx in top3_indices
            ]
        else:
            # LinearSVC fallback
            decision_scores = model.decision_function(hog_features_scaled)[0]
            exp_scores = np.exp(decision_scores - np.max(decision_scores))
            probabilities = exp_scores / np.sum(exp_scores)
            
            predicted_class_idx = np.argmax(probabilities)
            confidence = probabilities[predicted_class_idx]
            
            top3_indices = np.argsort(probabilities)[-3:][::-1]
            top3_predictions = [
                {
                    "class": label_mapping[idx],
                    "confidence": float(probabilities[idx])
                }
                for idx in top3_indices
            ]
        
        predicted_class = label_mapping[predicted_class_idx]
        
        return {
            "success": True,
            "predicted_class": predicted_class,
            "confidence": float(confidence),
            "top3_predictions": top3_predictions,
            "method": "HOG + SVM"
        }
        
    except Exception as e:
        return {
            "success": False,
            "message": f"Prediction error: {str(e)}"
        }

@app.on_event("startup")
async def startup_event():
    """Load models on startup"""
    load_models()

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "message": "Clothing Detection API is running",
        "version": "1.0.0",
        "categories": list(LABELS.values())
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    """
    Predict clothing category from uploaded image
    
    Args:
        file: Image file (JPG, PNG)
        
    Returns:
        JSON with predicted_class, confidence, and top3_predictions
    """
    # Validate file type
    if not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400,
            detail="Invalid file type. Only images are allowed."
        )
    
    try:
        # Read image bytes
        image_bytes = await file.read()
        
        # Predict
        result = predict_clothing(image_bytes)
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Prediction failed: {str(e)}"
        )

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    model_loaded = model is not None and scaler is not None
    
    return {
        "status": "healthy" if model_loaded else "unhealthy",
        "model_loaded": model_loaded,
        "categories": list(LABELS.values()) if label_mapping else []
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860)
