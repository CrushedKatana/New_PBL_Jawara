"""
Hugging Face Spaces Gradio App for Clothing Detection
HOG + SVM Model untuk deteksi kategori pakaian (Topi, Kemeja, Sepatu, T-Shirt)
"""

import gradio as gr
import numpy as np
import cv2
import joblib
from skimage.feature import hog
from PIL import Image
import json

# Load model, scaler, dan label mapping
model = joblib.load('clothing_svm_best.pkl')
scaler = joblib.load('clothing_scaler_best.pkl')

label_mapping = {
    0: "Topi",
    1: "Kemeja",
    2: "Sepatu",
    3: "Kaos"
}

def extract_hog_features(img, image_size=(128, 128)):
    """Extract HOG features from image - MUST match training preprocessing"""
    # Resize
    img_resized = cv2.resize(img, image_size)
    
    # CRITICAL: Histogram equalization (same as training!)
    img_equalized = cv2.equalizeHist(img_resized)
    
    # Extract HOG features (EXACT match with training!)
    features = hog(
        img_equalized,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        block_norm='L2-Hys',
        transform_sqrt=True,  # CRITICAL: Square root normalization (from training)
        visualize=False,
        feature_vector=True
    )
    
    return features

def predict_clothing(image):
    """
    Predict clothing category from image
    
    Args:
        image: PIL Image or numpy array
        
    Returns:
        dict: Prediction results
    """
    try:
        # Convert PIL to numpy if needed
        if isinstance(image, Image.Image):
            image = np.array(image)
        
        # Convert to grayscale directly from RGB (Gradio input is RGB)
        if len(image.shape) == 3 and image.shape[2] == 3:
            img_gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        elif len(image.shape) == 2:
            img_gray = image
        else:
            raise ValueError(f"Unexpected image shape: {image.shape}")
        
        # Extract HOG features
        hog_features = extract_hog_features(img_gray)
        
        # Scale features
        hog_features_scaled = scaler.transform([hog_features])
        
        # Predict with probabilities
        probabilities = model.predict_proba(hog_features_scaled)[0]
        predicted_class_idx = np.argmax(probabilities)
        confidence = probabilities[predicted_class_idx]
        
        # Get top 3 predictions
        top3_indices = np.argsort(probabilities)[-3:][::-1]
        top3_predictions = [
            {
                'class': label_mapping[idx],
                'confidence': float(probabilities[idx])
            }
            for idx in top3_indices
        ]
        
        result = {
            'success': True,
            'predicted_class': label_mapping[predicted_class_idx],
            'confidence': float(confidence),
            'top3_predictions': top3_predictions,
            'method': 'HOG + SVM'
        }
        
        # Format output untuk Gradio
        output_text = f"""
### 🎯 Hasil Deteksi

**Kategori Terdeteksi:** {result['predicted_class']}  
**Confidence:** {result['confidence']*100:.2f}%

---

### 📊 Top 3 Prediksi:
"""
        for i, pred in enumerate(top3_predictions, 1):
            output_text += f"\n{i}. **{pred['class']}** - {pred['confidence']*100:.2f}%"
        
        output_text += "\n\n---\n*Model: HOG + SVM (RBF Kernel)*"
        
        # Return both text and JSON
        return output_text, json.dumps(result, indent=2, ensure_ascii=False)
        
    except Exception as e:
        error_result = {
            'success': False,
            'message': f'Error: {str(e)}'
        }
        return f"❌ Error: {str(e)}", json.dumps(error_result, indent=2)

# Create Gradio Interface
with gr.Blocks(title="Clothing Detection API - PCVK") as demo:
    gr.Markdown("""
    # 👕 Clothing Detection API
    ## Model: HOG + SVM untuk Deteksi Kategori Pakaian
    
    Upload gambar pakaian untuk mendapatkan prediksi kategori:
    - 🧢 **Topi** (Hat)
    - 👔 **Kemeja** (Shirt)
    - 👟 **Sepatu** (Shoes)
    - 👕 **Kaos** (T-Shirt)
    """)
    
    with gr.Row():
        with gr.Column():
            image_input = gr.Image(type="numpy", label="Upload Gambar Pakaian")
            predict_btn = gr.Button("🔍 Detect Category", variant="primary")
        
        with gr.Column():
            result_text = gr.Markdown(label="Hasil Deteksi")
            result_json = gr.Code(label="JSON Response (untuk API)", language="json")
    
    predict_btn.click(
        fn=predict_clothing,
        inputs=image_input,
        outputs=[result_text, result_json]
    )
    
    gr.Markdown("""
    ---
    ### 📡 API Endpoint Usage
    
    **POST Request:**
    ```python
    import requests
    
    url = "https://huggingface.co/spaces/CrushedKatana/clothing-detection-api"
    files = {"data": open("image.jpg", "rb")}
    response = requests.post(url, files=files)
    result = response.json()
    
    ---
    **Model Info:**
    - Training Accuracy: 100%
    - Validation Accuracy: 86.47%
    - Test Accuracy: 87.95%
    - Model Size: 145MB
    - Features: HOG (Histogram of Oriented Gradients)
    - Classifier: SVM with RBF kernel
    """)

# Launch
if __name__ == "__main__":
    demo.launch()
