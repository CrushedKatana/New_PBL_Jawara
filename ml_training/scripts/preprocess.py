"""
Preprocessing Script untuk Data Pakaian
Pengolahan Citra dan Visi Komputer (PCVK)
Metode: HOG (Histogram of Oriented Gradients) Feature Extraction
"""

import os
import pandas as pd
import numpy as np
import cv2
from PIL import Image
from sklearn.model_selection import train_test_split
from skimage.feature import hog
from skimage import exposure
import json
from tqdm import tqdm

class ClothingDataPreprocessor:
    def __init__(self, csv_path, image_size=(128, 128), base_image_dir=None, default_ext='.jpg'):
        """
        Initialize preprocessor dengan HOG feature extraction
        
        Args:
            csv_path: Path ke file CSV dataset
            image_size: Target size untuk resize gambar (default 128x128 untuk HOG)
        """
        self.csv_path = csv_path
        self.image_size = image_size
        self.data = None
        self.categories = []
        # Optional base dir if CSV contains only image ids
        self.base_image_dir = base_image_dir
        self.default_ext = default_ext
        
        # HOG parameters
        self.hog_orientations = 9
        self.hog_pixels_per_cell = (8, 8)
        self.hog_cells_per_block = (2, 2)
        self.hog_visualize = False
        self.hog_transform_sqrt = True
        
    def load_data(self):
        """Load dataset dari CSV dan validasi path gambar"""
        print("Loading dataset...")
        self.data = pd.read_csv(self.csv_path)
        print(f"Loaded {len(self.data)} records")
        
        # Validasi kolom
        has_path = ('image_path' in self.data.columns) or ('path' in self.data.columns)
        has_image_id = 'image' in self.data.columns
        if not has_path and not has_image_id:
            raise ValueError("CSV must contain 'image_path'/'path' or 'image' column")
        if 'category' not in self.data.columns and 'label' not in self.data.columns:
            raise ValueError("CSV must contain 'category' or 'label' column")

        # Normalisasi dan validasi path
        # Tentukan kolom path
        if has_path:
            path_col = 'image_path' if 'image_path' in self.data.columns else 'path'
            self.data[path_col] = self.data[path_col].astype(str).apply(lambda p: os.path.normpath(p))
        else:
            # Bangun path dari image id + base_image_dir
            if not self.base_image_dir:
                # Default ke ../dataset/images
                self.base_image_dir = os.path.normpath(os.path.join(os.path.dirname(self.csv_path), 'images'))
            path_col = 'image_path'
            
            # Get category column to build filenames like "Label_UUID.jpg"
            cat_col = 'category' if 'category' in self.data.columns else 'label'
            
            def resolve_kaggle_path(row):
                img_id = str(row['image'])
                category = str(row.get(cat_col, ''))
                
                # Normalize category name for filesystem (remove hyphens, spaces)
                category_normalized = category.replace('-', '').replace(' ', '')
                
                # Try different naming patterns common in Kaggle datasets
                patterns = [
                    # Pattern 1: Normalized Category_UUID.ext (e.g., TShirt_UUID.jpg for T-Shirt)
                    os.path.join(self.base_image_dir, f"{category_normalized}_{img_id}{self.default_ext}"),
                    # Pattern 2: Original Category_UUID.ext (in case no normalization needed)
                    os.path.join(self.base_image_dir, f"{category}_{img_id}{self.default_ext}"),
                    # Pattern 3: UUID.ext (direct)
                    os.path.join(self.base_image_dir, f"{img_id}{self.default_ext}"),
                    # Pattern 4: Try .png extension
                    os.path.join(self.base_image_dir, f"{category_normalized}_{img_id}.png"),
                    os.path.join(self.base_image_dir, f"{category}_{img_id}.png"),
                    os.path.join(self.base_image_dir, f"{img_id}.png"),
                ]
                
                # Return first existing path
                for path in patterns:
                    if os.path.isfile(path):
                        return path
                
                # Return default if not found (will be filtered)
                return patterns[0]
            
            self.data[path_col] = self.data.apply(resolve_kaggle_path, axis=1)
        
        exists_mask = self.data[path_col].apply(lambda p: os.path.isfile(p))
        missing = (~exists_mask).sum()
        if missing:
            print(f"Warning: {missing} image paths do not exist and will be skipped.")
        self.data = self.data[exists_mask].reset_index(drop=True)
        if len(self.data) == 0:
            raise FileNotFoundError("No valid images found. Please check CSV 'image_path' values.")
        
        # Extract unique categories
        cat_col = 'category' if 'category' in self.data.columns else 'label'
        self.categories = sorted(self.data[cat_col].unique().tolist())
        print(f"Found {len(self.categories)} categories: {self.categories}")
        
        return self.data
    
    def preprocess_image(self, image_path):
        """
        Preprocess single image untuk HOG feature extraction
        
        Args:
            image_path: Path to image file
            
        Returns:
            Preprocessed image array (grayscale)
        """
        try:
            # Read image
            img = cv2.imread(image_path)
            if img is None:
                return None
            
            # Convert to grayscale (HOG bekerja pada grayscale)
            img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            
            # Resize
            img_resized = cv2.resize(img_gray, self.image_size)
            
            # Histogram equalization untuk meningkatkan kontras
            img_equalized = cv2.equalizeHist(img_resized)
            
            return img_equalized
        except Exception as e:
            print(f"Error processing {image_path}: {e}")
            return None
    
    def extract_hog_features(self, img):
        """
        Extract HOG features dari gambar
        
        Args:
            img: Grayscale image array
            
        Returns:
            HOG feature vector
        """
        try:
            # Extract HOG features
            features = hog(
                img,
                orientations=self.hog_orientations,
                pixels_per_cell=self.hog_pixels_per_cell,
                cells_per_block=self.hog_cells_per_block,
                transform_sqrt=self.hog_transform_sqrt,
                visualize=self.hog_visualize,
                feature_vector=True
            )
            
            return features
        except Exception as e:
            print(f"Error extracting HOG features: {e}")
            return None
    
    def apply_augmentation(self, img):
        """
        Apply data augmentation untuk grayscale image
        
        Args:
            img: Input grayscale image array
            
        Returns:
            Augmented image
        """
        # Random horizontal flip
        if np.random.rand() > 0.5:
            img = cv2.flip(img, 1)
        
        # Random rotation (-15 to 15 degrees)
        angle = np.random.uniform(-15, 15)
        h, w = img.shape[:2]
        M = cv2.getRotationMatrix2D((w/2, h/2), angle, 1.0)
        img = cv2.warpAffine(img, M, (w, h))
        
        # Random brightness adjustment
        factor = np.random.uniform(0.8, 1.2)
        img = np.clip(img * factor, 0, 255).astype('uint8')
        
        return img
    
    def prepare_dataset(self, test_size=0.2, val_size=0.1, augment=True):
        """
        Prepare dataset dengan HOG feature extraction untuk SVM
        
        Args:
            test_size: Proportion of test set
            val_size: Proportion of validation set
            augment: Whether to apply augmentation
            
        Returns:
            Dictionary with train, val, test splits (HOG features)
        """
        if self.data is None:
            self.load_data()
        
        features_list = []
        labels = []
        
        print("Extracting HOG features from images...")
        for idx, row in tqdm(self.data.iterrows(), total=len(self.data), desc="Processing"):
            image_path = row.get('image_path', row.get('path', ''))
            category = row.get('category', row.get('label', ''))
            
            # Preprocess image
            img = self.preprocess_image(image_path)
            if img is not None:
                # Extract HOG features
                hog_features = self.extract_hog_features(img)
                if hog_features is not None:
                    features_list.append(hog_features)
                    labels.append(category)
                    
                    # Apply augmentation untuk training data
                    if augment:
                        aug_img = self.apply_augmentation(img.copy())
                        aug_hog_features = self.extract_hog_features(aug_img)
                        if aug_hog_features is not None:
                            features_list.append(aug_hog_features)
                            labels.append(category)
        
        features = np.array(features_list)
        labels = np.array(labels)
        
        print(f"\nTotal samples: {len(features)}")
        if features.size == 0:
            raise RuntimeError("No HOG features extracted. Ensure dataset images are readable and paths are correct.")
        print(f"HOG feature dimension: {features.shape[1]}")
        
        # Encode labels
        from sklearn.preprocessing import LabelEncoder
        label_encoder = LabelEncoder()
        labels_encoded = label_encoder.fit_transform(labels)
        
        # Split dataset
        X_temp, X_test, y_temp, y_test = train_test_split(
            features, labels_encoded, test_size=test_size, random_state=42, stratify=labels_encoded
        )
        
        val_size_adjusted = val_size / (1 - test_size)
        X_train, X_val, y_train, y_val = train_test_split(
            X_temp, y_temp, test_size=val_size_adjusted, random_state=42, stratify=y_temp
        )
        
        print(f"\nDataset split:")
        print(f"Train set: {len(X_train)} samples")
        print(f"Validation set: {len(X_val)} samples")
        print(f"Test set: {len(X_test)} samples")
        
        # Save label encoder
        label_mapping = {i: label for i, label in enumerate(label_encoder.classes_)}
        with open('../models/label_mapping.json', 'w') as f:
            json.dump(label_mapping, f, indent=2)
        
        print(f"\nLabel mapping saved to ../models/label_mapping.json")
        
        return {
            'X_train': X_train,
            'y_train': y_train,
            'X_val': X_val,
            'y_val': y_val,
            'X_test': X_test,
            'y_test': y_test,
            'label_encoder': label_encoder,
            'num_classes': len(label_encoder.classes_),
            'feature_dim': features.shape[1]
        }

if __name__ == "__main__":
    # Example usage
    preprocessor = ClothingDataPreprocessor('../dataset/ml_ready_images_data.csv')
    dataset = preprocessor.prepare_dataset()
    
    print("\n" + "="*50)
    print("HOG Feature Extraction completed successfully!")
    print("="*50)
    print(f"Number of classes: {dataset['num_classes']}")
    print(f"HOG feature dimension: {dataset['feature_dim']}")
    print(f"Ready for SVM training!")

if __name__ == "__main__":
    # Example usage
    preprocessor = ClothingDataPreprocessor('../dataset/ml_ready_images_data.csv')
    dataset = preprocessor.prepare_dataset()
    
    print("\n" + "="*50)
    print("HOG Feature Extraction completed successfully!")
    print("="*50)
    print(f"Number of classes: {dataset['num_classes']}")
    print(f"HOG feature dimension: {dataset['feature_dim']}")
    print(f"Ready for SVM training!")

