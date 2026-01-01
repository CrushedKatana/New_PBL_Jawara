"""
Inference Script - Test the trained model on new images
Usage: python inference.py --image path/to/image.jpg --model output/model_80:20_Random_Forest.joblib
"""

import argparse
import joblib
import numpy as np
import os
from PIL import Image
from skimage.feature import hog
from skimage import color
import sys

class ModelInference:
    """Load and use trained models for inference"""
    
    def __init__(self, model_path, pca_path=None):
        """Initialize inference with trained model"""
        self.model_path = model_path
        self.pca_path = pca_path
        
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model not found: {model_path}")
        
        self.model = joblib.load(model_path)
        self.pca = joblib.load(pca_path) if pca_path and os.path.exists(pca_path) else None
        
        self.ethnicity_classes = [
            'White', 'Black', 'Indian', 'East Asian', 
            'Southeast Asian', 'Middle Eastern', 'Latino'
        ]
        
        self.idx_to_class = {idx: cls for idx, cls in enumerate(self.ethnicity_classes)}
    
    def preprocess_image(self, image_path, size=(224, 224)):
        """Load and preprocess image"""
        try:
            img = Image.open(image_path).convert('RGB')
            img = img.resize(size, Image.Resampling.LANCZOS)
            img_array = np.array(img, dtype=np.float32) / 255.0
            return img_array
        except Exception as e:
            print(f"Error loading image: {e}")
            return None
    
    def extract_hog_features(self, image):
        """Extract HOG features from image"""
        try:
            if len(image.shape) == 3:
                img_gray = color.rgb2gray(image)
            else:
                img_gray = image
            
            features = hog(
                img_gray,
                orientations=9,
                pixels_per_cell=(8, 8),
                cells_per_block=(2, 2),
                visualize=False,
                channel_axis=None
            )
            
            return features
        except Exception as e:
            print(f"Error extracting features: {e}")
            return None
    
    def predict(self, image_path):
        """Predict ethnicity from image"""
        # Load image
        image = self.preprocess_image(image_path)
        if image is None:
            return None
        
        # Extract features
        features = self.extract_hog_features(image)
        if features is None:
            return None
        
        # Reshape for prediction
        features = features.reshape(1, -1)
        
        # Apply PCA if available
        if self.pca:
            features = self.pca.transform(features)
        
        # Predict
        try:
            prediction = self.model.predict(features)[0]
            probabilities = self.model.predict_proba(features)[0] if hasattr(self.model, 'predict_proba') else None
            
            result = {
                'predicted_class': self.idx_to_class[prediction],
                'class_index': prediction,
                'confidence': probabilities[prediction] if probabilities is not None else None,
                'probabilities': {
                    self.ethnicity_classes[i]: float(prob) 
                    for i, prob in enumerate(probabilities) 
                    if probabilities is not None
                } if probabilities is not None else {}
            }
            
            return result
        except Exception as e:
            print(f"Error during prediction: {e}")
            return None


def main():
    """Main inference function"""
    parser = argparse.ArgumentParser(
        description='Predict ethnicity from facial image',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python inference.py --image face.jpg
  python inference.py --image face.jpg --model output/model_80:20_Random_Forest.joblib
        """
    )
    
    parser.add_argument('--image', required=True, help='Path to image file')
    parser.add_argument('--model', default='output/model_80:20_Random_Forest.joblib', 
                       help='Path to trained model (default: output/model_80:20_Random_Forest.joblib)')
    
    args = parser.parse_args()
    
    # Verify image exists
    if not os.path.exists(args.image):
        print(f"Error: Image not found: {args.image}")
        sys.exit(1)
    
    # Run inference
    try:
        print(f"Loading model: {args.model}")
        inferencer = ModelInference(args.model)
        
        print(f"Processing image: {args.image}")
        result = inferencer.predict(args.image)
        
        if result:
            print("\n" + "="*50)
            print("PREDICTION RESULT")
            print("="*50)
            print(f"Predicted Ethnicity: {result['predicted_class']}")
            
            if result['confidence']:
                print(f"Confidence: {result['confidence']*100:.2f}%")
            
            if result['probabilities']:
                print("\nClass Probabilities:")
                for cls, prob in sorted(result['probabilities'].items(), key=lambda x: x[1], reverse=True):
                    bar = '█' * int(prob * 50) + '░' * (50 - int(prob * 50))
                    print(f"  {cls:20s} [{bar}] {prob*100:6.2f}%")
            print("="*50)
        else:
            print("Error: Prediction failed")
            sys.exit(1)
    
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
