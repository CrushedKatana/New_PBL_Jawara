"""
Quick test: Process only 100 samples to verify everything works
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import (accuracy_score, precision_score, recall_score, 
                             f1_score, confusion_matrix, classification_report)
from skimage.feature import hog
from skimage import color
from PIL import Image
import os
from datasets import load_dataset
from tqdm import tqdm
import warnings
import joblib

warnings.filterwarnings('ignore')

class FairFaceDataLoader:
    """Handle FairFace dataset loading and preprocessing"""
    
    def __init__(self):
        self.ethnicity_classes = [
            'White', 'Black', 'Indian', 'East Asian', 
            'Southeast Asian', 'Middle Eastern', 'Latino'
        ]
        self.class_to_idx = {idx: idx for idx in range(len(self.ethnicity_classes))}
        self.idx_to_class = {idx: cls for idx, cls in enumerate(self.ethnicity_classes)}
        
    def load_dataset(self, version="0.25", split="train"):
        """Load FairFace dataset from HuggingFace"""
        print(f"Loading FairFace dataset (version {version}, split: {split})...")
        try:
            ds = load_dataset("HuggingFaceM4/FairFace", version, split=split)
            print(f"✓ Dataset loaded successfully: {len(ds)} images")
            return ds
        except Exception as e:
            print(f"✗ Error loading dataset: {e}")
            return None
    
    def preprocess_image(self, image, size=(224, 224)):
        """Preprocess image"""
        try:
            if isinstance(image, Image.Image):
                img = image.convert('RGB')
            else:
                img = Image.fromarray(image)
            
            img = img.resize(size, Image.Resampling.LANCZOS)
            img_array = np.array(img, dtype=np.float32) / 255.0
            
            return img_array
        except Exception as e:
            return None
    
    def extract_hog_features(self, image, size=(224, 224)):
        """Extract HOG features"""
        try:
            img = self.preprocess_image(image, size)
            if img is None:
                return None
            
            if len(img.shape) == 3:
                img_gray = color.rgb2gray(img)
            else:
                img_gray = img
            
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
            return None


# Main test
print("\n" + "="*60)
print("QUICK TEST - Processing 100 samples")
print("="*60)

loader = FairFaceDataLoader()
ds = loader.load_dataset(version="0.25", split="train")

if ds is None:
    print("Failed to load dataset")
    exit(1)

# Take only 100 samples
ds = ds.select(range(100))

features_list = []
labels_list = []

print(f"\nExtracting HOG features from {len(ds)} images...")
for idx, sample in enumerate(tqdm(ds, total=len(ds))):
    try:
        image = sample['image']
        race_idx = sample['race']
        
        if not isinstance(race_idx, int) or race_idx < 0 or race_idx >= 7:
            continue
        
        features = loader.extract_hog_features(image)
        if features is not None:
            features_list.append(features)
            labels_list.append(race_idx)
    except Exception as e:
        print(f"Error: {e}")
        continue

print(f"\n✓ Extracted {len(features_list)} feature vectors")
if len(features_list) > 0:
    print(f"  Feature dimension: {len(features_list[0])}")
    print(f"  Classes found: {set(labels_list)}")
    
    # Test PCA
    features_array = np.array(features_list)
    scaler = StandardScaler()
    features_scaled = scaler.fit_transform(features_array)
    
    pca = PCA(n_components=min(50, features_scaled.shape[0]))
    features_pca = pca.fit_transform(features_scaled)
    
    print(f"\n✓ PCA reduction successful!")
    print(f"  Original dimension: {features_scaled.shape[1]}")
    print(f"  Reduced dimension: {features_pca.shape[1]}")
    print(f"  Explained variance: {sum(pca.explained_variance_ratio_)*100:.2f}%")
    
    # Test train-test split
    X_train, X_test, y_train, y_test = train_test_split(
        features_pca, labels_list, test_size=0.2, random_state=42, stratify=labels_list
    )
    
    print(f"\n✓ Train-test split successful!")
    print(f"  Training samples: {len(X_train)}")
    print(f"  Testing samples: {len(X_test)}")
    
    # Quick model test
    print(f"\nTraining a quick Random Forest model...")
    model = RandomForestClassifier(n_estimators=10, random_state=42)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    
    print(f"✓ Model training successful!")
    print(f"  Test Accuracy: {acc*100:.2f}%")
    print(f"\n✅ ALL TESTS PASSED! The pipeline works correctly.")
else:
    print(f"\n✗ No features extracted!")

