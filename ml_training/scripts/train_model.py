"""
Training Script untuk Model Deteksi Pakaian
Pengolahan Citra dan Visi Komputer (PCVK)
Metode: HOG (Histogram of Oriented Gradients) + SVM (Support Vector Machine)
"""

import os
import numpy as np
from sklearn.svm import SVC
from sklearn.model_selection import GridSearchCV
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, accuracy_score
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import json
import joblib
from tqdm import tqdm

from preprocess import ClothingDataPreprocessor

class ClothingDetectionSVM:
    def __init__(self, num_classes):
        """
        Initialize SVM classifier untuk deteksi pakaian
        
        Args:
            num_classes: Number of clothing categories
        """
        self.num_classes = num_classes
        self.model = None
        self.scaler = StandardScaler()
        self.best_params = None
        
    def build_model(self, kernel='rbf', C=1.0, gamma='scale'):
        """
        Build SVM model
        
        Args:
            kernel: SVM kernel type ('linear', 'rbf', 'poly')
            C: Regularization parameter
            gamma: Kernel coefficient
        """
        print(f"Building SVM model with kernel={kernel}, C={C}, gamma={gamma}")
        print("Using all CPU cores for faster training...")
        
        # Use LinearSVC for linear kernel (much faster and supports n_jobs)
        if kernel == 'linear':
            from sklearn.svm import LinearSVC
            from sklearn.calibration import CalibratedClassifierCV
            
            # LinearSVC is faster but doesn't support probability directly
            base_model = LinearSVC(
                C=C,
                max_iter=2000,
                random_state=42,
                verbose=1,
                dual='auto'  # Let sklearn choose best algorithm
            )
            # Wrap with calibration to get probability estimates
            self.model = CalibratedClassifierCV(base_model, cv=3, n_jobs=-1)
        else:
            self.model = SVC(
                kernel=kernel,
                C=C,
                gamma=gamma,
                probability=True,  # Enable probability estimates
                decision_function_shape='ovr',  # One-vs-Rest for multiclass
                random_state=42,
                verbose=True,  # Show training progress
                cache_size=1000  # Increase cache for faster training
            )
        
        return self.model
    
    def hyperparameter_tuning(self, X_train, y_train, cv=3):
        """
        Hyperparameter tuning dengan GridSearchCV
        
        Args:
            X_train: Training features
            y_train: Training labels
            cv: Cross-validation folds
            
        Returns:
            Best parameters
        """
        print("\n" + "="*50)
        print("Hyperparameter Tuning dengan GridSearchCV")
        print("="*50)
        
        # Parameter grid untuk tuning
        param_grid = {
            'C': [0.1, 1, 10, 100],
            'gamma': ['scale', 'auto', 0.001, 0.01, 0.1],
            'kernel': ['rbf', 'linear']
        }
        
        print(f"Testing {len(param_grid['C']) * len(param_grid['gamma']) * len(param_grid['kernel'])} combinations...")
        
        grid_search = GridSearchCV(
            SVC(probability=True, random_state=42),
            param_grid,
            cv=cv,
            scoring='accuracy',
            n_jobs=-1,
            verbose=2
        )
        
        grid_search.fit(X_train, y_train)
        
        self.best_params = grid_search.best_params_
        print(f"\nBest parameters: {self.best_params}")
        print(f"Best cross-validation accuracy: {grid_search.best_score_:.4f}")
        
        return self.best_params
    
    def train(self, X_train, y_train, X_val, y_val, use_grid_search=False):
        """
        Train SVM model
        
        Args:
            X_train, y_train: Training data
            X_val, y_val: Validation data
            use_grid_search: Whether to use hyperparameter tuning
        """
        print("\n" + "="*50)
        print("Training SVM Classifier")
        print("="*50)
        
        # Normalize features
        print("\nNormalizing features...")
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_val_scaled = self.scaler.transform(X_val)
        
        # Hyperparameter tuning (optional)
        if use_grid_search:
            best_params = self.hyperparameter_tuning(X_train_scaled, y_train)
            self.build_model(**best_params)
        else:
            # Use default parameters or manually set (linear kernel for faster training)
            self.build_model(kernel='linear', C=1.0)
        
        # Train model
        print(f"\nTraining SVM on {len(X_train)} samples...")
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate on training set
        train_pred = self.model.predict(X_train_scaled)
        train_accuracy = accuracy_score(y_train, train_pred)
        
        # Evaluate on validation set
        val_pred = self.model.predict(X_val_scaled)
        val_accuracy = accuracy_score(y_val, val_pred)
        
        print(f"\nTraining Results:")
        print(f"Train Accuracy: {train_accuracy:.4f}")
        print(f"Validation Accuracy: {val_accuracy:.4f}")
        
        # Save model and scaler
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        model_path = f'../models/clothing_svm_model_{timestamp}.pkl'
        scaler_path = f'../models/clothing_scaler_{timestamp}.pkl'
        
        joblib.dump(self.model, model_path)
        joblib.dump(self.scaler, scaler_path)
        
        print(f"\nModel saved to: {model_path}")
        print(f"Scaler saved to: {scaler_path}")
        
        # Save best model (without timestamp for easy reference)
        joblib.dump(self.model, '../models/clothing_svm_best.pkl')
        joblib.dump(self.scaler, '../models/clothing_scaler_best.pkl')
        print("Best model saved as: clothing_svm_best.pkl")
        
        return {
            'train_accuracy': train_accuracy,
            'val_accuracy': val_accuracy,
            'model_path': model_path,
            'scaler_path': scaler_path
        }
    
    def save_model_info(self, train_results):
        """Save model information"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Get model type
        model_type = type(self.model).__name__
        
        # Model info
        model_info = {
            'algorithm': 'SVM (Support Vector Machine)',
            'feature_extraction': 'HOG (Histogram of Oriented Gradients)',
            'model_type': model_type,
            'num_classes': self.num_classes,
            'train_accuracy': float(train_results['train_accuracy']),
            'val_accuracy': float(train_results['val_accuracy']),
            'timestamp': timestamp
        }
        
        # Add kernel info if available
        if hasattr(self.model, 'kernel'):
            model_info['kernel'] = self.model.kernel
            model_info['C'] = self.model.C
            model_info['gamma'] = self.model.gamma
        elif hasattr(self.model, 'base_estimator'):
            # For CalibratedClassifierCV
            model_info['kernel'] = 'linear (LinearSVC)'
            if hasattr(self.model.base_estimator, 'C'):
                model_info['C'] = self.model.base_estimator.C
        
        if self.best_params:
            model_info['best_params'] = self.best_params
        
        # Save to JSON
        info_path = f'../output/model_info_{timestamp}.json'
        with open(info_path, 'w') as f:
            json.dump(model_info, f, indent=2)
        
        print(f"\nModel info saved to: {info_path}")
        
        # Print model info
        print("\n" + "="*50)
        print("Model Information")
        print("="*50)
        print(f"Algorithm: {model_info['algorithm']}")
        print(f"Feature Extraction: {model_info['feature_extraction']}")
        print(f"Model Type: {model_info['model_type']}")
        if 'kernel' in model_info:
            print(f"Kernel: {model_info['kernel']}")
        if 'C' in model_info:
            print(f"C: {model_info['C']}")
        print(f"Number of Classes: {model_info['num_classes']}")
        print(f"Train Accuracy: {model_info['train_accuracy']:.4f}")
        print(f"Validation Accuracy: {model_info['val_accuracy']:.4f}")

def main():
    """Main training pipeline"""
    print("="*60)
    print("PCVK Clothing Detection - HOG + SVM Training")
    print("="*60)
    
    # Step 1: Preprocess data and extract HOG features
    print("\n[1/3] Extracting HOG features from dataset...")
    preprocessor = ClothingDataPreprocessor(
        '../dataset/ml_ready_images_data.csv',
        base_image_dir=os.path.normpath('../dataset/Filtered_Image'),
        default_ext='.jpg'
    )
    dataset = preprocessor.prepare_dataset(test_size=0.2, val_size=0.1, augment=True)
    
    print(f"\nDataset Summary:")
    print(f"- Number of classes: {dataset['num_classes']}")
    print(f"- HOG feature dimension: {dataset['feature_dim']}")
    print(f"- Training samples: {len(dataset['X_train'])}")
    print(f"- Validation samples: {len(dataset['X_val'])}")
    print(f"- Test samples: {len(dataset['X_test'])}")
    
    # Step 2: Train SVM model
    print("\n[2/3] Training SVM classifier...")
    svm_trainer = ClothingDetectionSVM(num_classes=dataset['num_classes'])
    
    # Train with or without grid search
    # Set use_grid_search=True for hyperparameter tuning (slower but better results)
    train_results = svm_trainer.train(
        dataset['X_train'], dataset['y_train'],
        dataset['X_val'], dataset['y_val'],
        use_grid_search=False  # Set to True for hyperparameter tuning
    )
    
    # Step 3: Save model info
    print("\n[3/3] Saving model information...")
    svm_trainer.save_model_info(train_results)
    
    print("\n" + "="*60)
    print("Training completed successfully!")
    print("="*60)
    print("\nNext steps:")
    print("1. Evaluate model: python evaluate.py --model ../models/clothing_svm_best.pkl")
    print("2. Test prediction: python predict.py --image <path_to_image>")

if __name__ == "__main__":
    main()
