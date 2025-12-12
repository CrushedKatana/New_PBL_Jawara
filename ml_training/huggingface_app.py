"""
Hugging Face Gradio App untuk Clothing Detection
HOG + SVM Model untuk klasifikasi pakaian (Topi, Kemeja, Sepatu, T-Shirt)
"""

import gradio as gr
import numpy as np
import cv2
import joblib
import json
from skimage.feature import hog
from PIL import Image
import os

# Load model dan scaler
MODEL_PATH = "clothing_svm_best.pkl"
SCALER_PATH = "clothing_scaler_best.pkl"
LABEL_MAPPING = {
    0: "Topi",
    1: "Kemeja", 
    2: "Sepatu",
    3: "T-Shirt"
}

# Global variables for model (lazy loading)
model = None
scaler = None

def load_models():
    """Load ML models"""
    global model, scaler
    
    if model is None:
        print("Loading model...")
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        print("Models loaded successfully!")
    
    return model, scaler

def extract_hog_features(image, image_size=(128, 128)):
    """
    Extract HOG features from image
    
    Args:
        image: PIL Image or numpy array
        image_size: Target size for resize
        
    Returns:
        HOG features as numpy array
    """
    # Convert PIL Image to numpy array if needed
    if isinstance(image, Image.Image):
        image = np.array(image)
    
    # Convert to grayscale
    if len(image.shape) == 3:
        image_gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    else:
        image_gray = image
    
    # Resize image
    image_resized = cv2.resize(image_gray, image_size)
    
    # Extract HOG features
    # Parameters match training configuration
    hog_features = hog(
        image_resized,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        block_norm='L2-Hys',
        visualize=False,
        feature_vector=True
    )
    
    return hog_features

def predict_clothing(image):
    """
    Predict clothing category from image
    
    Args:
        image: PIL Image or numpy array
        
    Returns:
        Dictionary with prediction results
    """
    try:
        # Load models if not loaded
        model, scaler = load_models()
        
        # Extract HOG features
        hog_features = extract_hog_features(image)
        
        # Reshape for model input
        hog_features = hog_features.reshape(1, -1)
        
        # Scale features
        hog_features_scaled = scaler.transform(hog_features)
        
        # Get prediction with probabilities
        prediction = model.predict(hog_features_scaled)[0]
        probabilities = model.predict_proba(hog_features_scaled)[0]
        
        # Get predicted class name
        predicted_class = LABEL_MAPPING[prediction]
        confidence = float(probabilities[prediction])
        
        # Get top 3 predictions
        top3_indices = np.argsort(probabilities)[-3:][::-1]
        top3_predictions = [
            {
                "class": LABEL_MAPPING[idx],
                "confidence": float(probabilities[idx])
            }
            for idx in top3_indices
        ]
        
        # Format result for Gradio display
        result_text = f"""
## Hasil Deteksi

**Kategori Terdeteksi:** {predicted_class}
**Confidence:** {confidence*100:.2f}%

### Top 3 Predictions:
"""
        for i, pred in enumerate(top3_predictions, 1):
            result_text += f"{i}. **{pred['class']}**: {pred['confidence']*100:.2f}%\n"
        
        # Also return JSON for API usage
        json_result = {
            "success": True,
            "predicted_class": predicted_class,
            "confidence": confidence,
            "top3_predictions": top3_predictions,
            "method": "HOG + SVM"
        }
        
        return result_text, json.dumps(json_result, indent=2)
        
    except Exception as e:
        error_text = f"❌ Error: {str(e)}"
        error_json = {
            "success": False,
            "message": str(e)
        }
        return error_text, json.dumps(error_json, indent=2)

# Create Gradio interface
with gr.Blocks(title="Clothing Detection - HOG + SVM") as demo:
    gr.Markdown("""
    # 👔 Clothing Detection System
    ### Model: HOG + SVM (RBF Kernel)
    
    Upload foto pakaian untuk mendeteksi kategori:
    - 🧢 **Topi** (Hat)
    - 👔 **Kemeja** (Shirt)
    - 👟 **Sepatu** (Shoes)
    - 👕 **T-Shirt**
    
    Model ini menggunakan **Histogram of Oriented Gradients (HOG)** untuk ekstraksi fitur
    dan **Support Vector Machine (SVM)** dengan RBF kernel untuk klasifikasi.
    
    **Training Performance:**
    - Validation Accuracy: 86.47%
    - Test Accuracy: 87.95%
    - Average Confidence: 88.21%
    """)
    
    with gr.Row():
        with gr.Column():
            input_image = gr.Image(type="pil", label="Upload Gambar Pakaian")
            predict_btn = gr.Button("🔍 Deteksi Kategori", variant="primary")
            
            gr.Markdown("""
            ### 💡 Tips:
            - Upload foto pakaian yang jelas
            - Pastikan pakaian terlihat dengan baik
            - Hindari foto yang blur atau gelap
            """)
        
        with gr.Column():
            output_text = gr.Markdown(label="Hasil Deteksi")
            output_json = gr.Code(label="JSON Response (untuk API)", language="json")
    
    # Example images
    gr.Markdown("### 📸 Contoh Gambar untuk Testing:")
    gr.Examples(
        examples=[
            ["examples/topi.jpg"],
            ["examples/kemeja.jpg"],
            ["examples/sepatu.jpg"],
            ["examples/tshirt.jpg"],
        ] if os.path.exists("examples") else [],
        inputs=input_image,
        label="Click untuk test"
    )
    
    # Connect button to prediction function
    predict_btn.click(
        fn=predict_clothing,
        inputs=input_image,
        outputs=[output_text, output_json]
    )
    
    gr.Markdown("""
    ---
    ### 🔌 API Usage
    
    Untuk menggunakan sebagai API dari Flutter/Mobile app:
    
    ```python
    import requests
    
    # Upload image
    files = {"image": open("path/to/image.jpg", "rb")}
    response = requests.post(
        "https://YOUR_HUGGINGFACE_SPACE_URL/api/predict",
        files=files
    )
    result = response.json()
    ```
    
    ### 📊 Model Details
    - **Algorithm:** SVM with RBF kernel
    - **Feature Extraction:** HOG (Histogram of Oriented Gradients)
    - **Parameters:** C=10, gamma='scale', class_weight='balanced'
    - **Training Samples:** 3,982 (with augmentation)
    - **Model Size:** 146 MB
    
    ### 👨‍💻 Developer
    Created for PBL Project - Marketplace RT/RW
    """)

# Launch app
if __name__ == "__main__":
    demo.launch()
