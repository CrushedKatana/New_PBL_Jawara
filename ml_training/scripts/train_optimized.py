"""
Optimized Training Script - Maximum Confidence
HOG + RBF SVC with GridSearchCV and Data Augmentation
Target: 85%+ confidence for all categories
"""

import os
import sys
import numpy as np
from sklearn.svm import SVC
from sklearn.model_selection import GridSearchCV, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
from datetime import datetime
import json
import joblib
from tqdm import tqdm

from preprocess import ClothingDataPreprocessor

def main():
    print("="*70)
    print("OPTIMIZED PCVK TRAINING - Maximum Confidence")
    print("HOG + RBF SVC with GridSearchCV")
    print("="*70)
    
    # Step 1: Load and preprocess data WITH AUGMENTATION
    print("\n[1/4] Loading dataset with augmentation...")
    
    # Get script directory and build absolute paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(script_dir, '..', 'dataset', 'ml_ready_images_data.csv')
    images_dir = os.path.join(script_dir, '..', 'dataset', 'Filtered_Image')
    
    preprocessor = ClothingDataPreprocessor(
        csv_path=csv_path,
        base_image_dir=images_dir
    )
    
    # Enable augmentation for better generalization
    dataset = preprocessor.prepare_dataset(augment=True)
    
    print(f"\nDataset Summary:")
    print(f"- Number of classes: {dataset['num_classes']}")
    print(f"- Training samples: {len(dataset['X_train'])} (with augmentation)")
    print(f"- Validation samples: {len(dataset['X_val'])}")
    print(f"- Test samples: {len(dataset['X_test'])}")
    print(f"- Feature dimension: {dataset['feature_dim']}")
    
    # Step 2: Scale features
    print("\n[2/4] Scaling features...")
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(dataset['X_train'])
    X_val_scaled = scaler.transform(dataset['X_val'])
    X_test_scaled = scaler.transform(dataset['X_test'])
    
    print("Feature scaling completed.")
    
    # Step 3: Hyperparameter Tuning with GridSearchCV
    print("\n[3/4] Hyperparameter Tuning (GridSearchCV)...")
    print("This will use all CPU cores for parallel training.")
    print("Testing multiple combinations of C, gamma, and kernel...")
    
    # Parameter grid - optimized for better confidence
    param_grid = {
        'C': [1, 10, 100, 1000],  # Regularization
        'gamma': [0.001, 0.01, 0.1, 'scale'],  # Kernel coefficient
        'kernel': ['rbf'],  # RBF kernel is best for HOG features
        'class_weight': ['balanced', None],  # Handle imbalanced classes
    }
    
    # Calculate total combinations
    total_combinations = (
        len(param_grid['C']) * 
        len(param_grid['gamma']) * 
        len(param_grid['kernel']) * 
        len(param_grid['class_weight'])
    )
    print(f"Testing {total_combinations} combinations with 3-fold CV...")
    print(f"Total fits: {total_combinations * 3} = {total_combinations * 3} models")
    
    # Create base SVC with probability
    base_svc = SVC(
        probability=True,  # CRITICAL: Enable probability for confidence scores
        random_state=42,
        cache_size=2000,  # Increase cache for faster training (2GB)
        verbose=False,  # Disable verbose to avoid clutter
    )
    
    # GridSearchCV with parallel processing
    grid_search = GridSearchCV(
        estimator=base_svc,
        param_grid=param_grid,
        cv=3,  # 3-fold cross-validation
        scoring='accuracy',
        n_jobs=-1,  # Use all CPU cores
        verbose=2,  # Show progress
        return_train_score=True
    )
    
    print("\nStarting grid search (this may take 10-30 minutes)...")
    grid_search.fit(X_train_scaled, dataset['y_train'])
    
    # Best parameters
    print("\n" + "="*70)
    print("GRID SEARCH RESULTS")
    print("="*70)
    print(f"Best parameters found: {grid_search.best_params_}")
    print(f"Best CV accuracy: {grid_search.best_score_:.4f} ({grid_search.best_score_*100:.2f}%)")
    print(f"Best estimator: {grid_search.best_estimator_}")
    
    # Use best model
    model = grid_search.best_estimator_
    
    # Step 4: Final Evaluation
    print("\n[4/4] Final Model Evaluation...")
    
    # Training accuracy
    train_pred = model.predict(X_train_scaled)
    train_acc = accuracy_score(dataset['y_train'], train_pred)
    
    # Validation accuracy
    val_pred = model.predict(X_val_scaled)
    val_acc = accuracy_score(dataset['y_val'], val_pred)
    
    # Test accuracy
    test_pred = model.predict(X_test_scaled)
    test_acc = accuracy_score(dataset['y_test'], test_pred)
    
    print("\n" + "="*70)
    print("FINAL RESULTS")
    print("="*70)
    print(f"Training Accuracy:   {train_acc:.4f} ({train_acc*100:.2f}%)")
    print(f"Validation Accuracy: {val_acc:.4f} ({val_acc*100:.2f}%)")
    print(f"Test Accuracy:       {test_acc:.4f} ({test_acc*100:.2f}%)")
    
    # Get label names from encoder
    label_names = dataset['label_encoder'].classes_
    
    # Per-class accuracy
    print("\n" + "-"*70)
    print("Classification Report (Validation Set):")
    print("-"*70)
    print(classification_report(
        dataset['y_val'], 
        val_pred, 
        target_names=label_names
    ))
    
    # Test confidence scores
    print("\n" + "-"*70)
    print("Average Confidence per Class (Test Set):")
    print("-"*70)
    
    test_proba = model.predict_proba(X_test_scaled)
    test_confidence = np.max(test_proba, axis=1)
    
    for class_idx, class_name in enumerate(label_names):
        class_mask = dataset['y_test'] == class_idx
        if np.sum(class_mask) > 0:
            avg_confidence = np.mean(test_confidence[class_mask])
            print(f"{class_name:12s}: {avg_confidence:.4f} ({avg_confidence*100:.2f}%)")
    
    overall_avg_confidence = np.mean(test_confidence)
    print(f"\n{'Overall Avg':12s}: {overall_avg_confidence:.4f} ({overall_avg_confidence*100:.2f}%)")
    
    # Save model and scaler
    print("\n" + "="*70)
    print("SAVING MODEL")
    print("="*70)
    
    models_dir = os.path.join(script_dir, '..', 'models')
    model_path = os.path.join(models_dir, 'clothing_svm_best.pkl')
    scaler_path = os.path.join(models_dir, 'clothing_scaler_best.pkl')
    
    joblib.dump(model, model_path)
    joblib.dump(scaler, scaler_path)
    
    print(f"Model saved to: {model_path}")
    print(f"Scaler saved to: {scaler_path}")
    
    # Save model info
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    info = {
        'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        'model_type': 'RBF SVC with Probability',
        'best_params': grid_search.best_params_,
        'num_classes': dataset['num_classes'],
        'train_accuracy': float(train_acc),
        'val_accuracy': float(val_acc),
        'test_accuracy': float(test_acc),
        'avg_confidence': float(overall_avg_confidence),
        'num_train_samples': len(dataset['X_train']),
        'num_val_samples': len(dataset['X_val']),
        'num_test_samples': len(dataset['X_test']),
        'feature_dim': dataset['feature_dim'],
        'augmentation': True,
        'grid_search_cv_folds': 3,
        'total_grid_combinations': total_combinations,
    }
    
    output_dir = os.path.join(script_dir, '..', 'output')
    info_path = os.path.join(output_dir, f'model_info_{timestamp}.json')
    os.makedirs(output_dir, exist_ok=True)
    with open(info_path, 'w') as f:
        json.dump(info, f, indent=2)
    
    print(f"Model info saved to: {info_path}")
    
    # Update label mapping (convert to Indonesian)
    label_mapping_english = {str(idx): name for idx, name in enumerate(label_names)}
    
    # Map to Indonesian
    english_to_indonesian = {
        'Hat': 'Topi',
        'Shirt': 'Kemeja',
        'Shoes': 'Sepatu',
        'T-Shirt': 'T-Shirt'
    }
    
    label_mapping = {
        idx: english_to_indonesian.get(name, name)
        for idx, name in label_mapping_english.items()
    }
    
    mapping_path = os.path.join(models_dir, 'label_mapping.json')
    with open(mapping_path, 'w') as f:
        json.dump(label_mapping, f, indent=2)
    
    print(f"Label mapping saved to: {mapping_path}")
    
    print("\n" + "="*70)
    print("TRAINING COMPLETED SUCCESSFULLY!")
    print("="*70)
    print("\nNext steps:")
    print("1. Test the model with: python predict.py --image <path>")
    print("2. Copy models to backend: xcopy models\\*.pkl C:\\xampp\\htdocs\\jawara\\ml_training\\models\\")
    print("3. Hot restart Flutter app to use new model")

if __name__ == "__main__":
    main()
