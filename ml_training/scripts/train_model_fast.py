"""
Fast Training Script - Using LinearSVC for faster training
"""

import os
import numpy as np
from sklearn.svm import LinearSVC
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, accuracy_score
from datetime import datetime
import json
import joblib

from preprocess import ClothingDataPreprocessor

def main():
    print("="*60)
    print("PCVK Clothing Detection - FAST Training (Linear SVC)")
    print("="*60)
    
    # Step 1: Load and preprocess data
    print("\n[1/3] Extracting HOG features...")
    preprocessor = ClothingDataPreprocessor(
        csv_path='../dataset/ml_ready_images_data.csv',
        base_image_dir='../dataset/Filtered_Image'
    )
    
    dataset = preprocessor.prepare_dataset(augment=False)  # No augmentation for faster training
    
    print(f"\nDataset Summary:")
    print(f"- Number of classes: {dataset['num_classes']}")
    print(f"- Training samples: {len(dataset['X_train'])}")
    print(f"- Validation samples: {len(dataset['X_val'])}")
    
    # Step 2: Train Linear SVC (much faster than SVC)
    print("\n[2/3] Training Linear SVC...")
    print("Normalizing features...")
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(dataset['X_train'])
    X_val_scaled = scaler.transform(dataset['X_val'])
    
    print("Building Linear SVC model...")
    model = LinearSVC(C=1.0, max_iter=1000, random_state=42)
    
    print(f"Training on {len(X_train_scaled)} samples...")
    model.fit(X_train_scaled, dataset['y_train'])
    
    # Evaluate
    train_pred = model.predict(X_train_scaled)
    val_pred = model.predict(X_val_scaled)
    
    train_acc = accuracy_score(dataset['y_train'], train_pred)
    val_acc = accuracy_score(dataset['y_val'], val_pred)
    
    print(f"\nTraining Results:")
    print(f"Train Accuracy: {train_acc:.4f}")
    print(f"Validation Accuracy: {val_acc:.4f}")
    
    # Step 3: Save model
    print("\n[3/3] Saving model...")
    model_path = '../models/clothing_svm_best.pkl'
    scaler_path = '../models/clothing_scaler_best.pkl'
    
    joblib.dump(model, model_path)
    joblib.dump(scaler, scaler_path)
    
    print(f"Model saved to: {model_path}")
    print(f"Scaler saved to: {scaler_path}")
    
    # Save model info
    info = {
        'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        'model_type': 'LinearSVC',
        'num_classes': dataset['num_classes'],
        'train_accuracy': float(train_acc),
        'val_accuracy': float(val_acc),
        'num_train_samples': len(dataset['X_train']),
        'feature_dim': dataset['feature_dim']
    }
    
    info_path = f'../output/model_info_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
    with open(info_path, 'w') as f:
        json.dump(info, f, indent=2)
    
    print(f"\nModel info saved to: {info_path}")
    print("\n" + "="*60)
    print("Training completed successfully!")
    print("="*60)

if __name__ == "__main__":
    main()
