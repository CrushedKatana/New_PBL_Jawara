"""
Evaluation Script untuk Model SVM Deteksi Pakaian
Pengolahan Citra dan Visi Komputer (PCVK)
Metode: HOG + SVM
"""

import os
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import json
import argparse
import joblib

from preprocess import ClothingDataPreprocessor

class ModelEvaluator:
    def __init__(self, model_path, scaler_path, label_mapping_path='../models/label_mapping.json'):
        """
        Initialize model evaluator untuk SVM
        
        Args:
            model_path: Path to trained SVM model (.pkl)
            scaler_path: Path to fitted scaler (.pkl)
            label_mapping_path: Path to label mapping JSON
        """
        self.model = joblib.load(model_path)
        self.scaler = joblib.load(scaler_path)
        print(f"Model loaded from {model_path}")
        print(f"Scaler loaded from {scaler_path}")
        
        # Load label mapping
        with open(label_mapping_path, 'r') as f:
            label_mapping = json.load(f)
        self.label_mapping = {int(k): v for k, v in label_mapping.items()}
        self.num_classes = len(self.label_mapping)
        print(f"Loaded {self.num_classes} classes")
        
    def evaluate(self, X_test, y_test):
        """
        Evaluate SVM model on test set
        
        Args:
            X_test: Test features (HOG)
            y_test: Test labels
            
        Returns:
            Dictionary with evaluation metrics
        """
        print("\nEvaluating SVM model...")
        
        # Normalize test features
        X_test_scaled = self.scaler.transform(X_test)
        
        # Get predictions
        y_pred = self.model.predict(X_test_scaled)
        
        # Get probability estimates
        y_proba = self.model.predict_proba(X_test_scaled)
        
        # Calculate accuracy
        test_accuracy = accuracy_score(y_test, y_pred)
        
        # Top-3 accuracy
        top3_accuracy = self.calculate_top_k_accuracy(y_test, y_proba, k=3)
        
        # Classification report
        target_names = [self.label_mapping[i] for i in range(self.num_classes)]
        report = classification_report(y_test, y_pred, target_names=target_names, output_dict=True)
        
        print(f"\nTest Accuracy: {test_accuracy:.4f}")
        print(f"Test Top-3 Accuracy: {top3_accuracy:.4f}")
        
        # Print classification report
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred, target_names=target_names))
        
        return {
            'test_accuracy': test_accuracy,
            'test_top3_accuracy': top3_accuracy,
            'predictions': y_pred,
            'probabilities': y_proba,
            'classification_report': report
        }
    
    def calculate_top_k_accuracy(self, y_true, y_proba, k=3):
        """Calculate top-k accuracy"""
        top_k_preds = np.argsort(y_proba, axis=1)[:, -k:]
        correct = 0
        for i, true_label in enumerate(y_true):
            if true_label in top_k_preds[i]:
                correct += 1
        return correct / len(y_true)
    
    def plot_confusion_matrix(self, y_test, y_pred, save_path='../output/confusion_matrix.png'):
        """Plot confusion matrix"""
        cm = confusion_matrix(y_test, y_pred)
        
        plt.figure(figsize=(12, 10))
        sns.heatmap(
            cm,
            annot=True,
            fmt='d',
            cmap='Blues',
            xticklabels=[self.label_mapping[i] for i in range(self.num_classes)],
            yticklabels=[self.label_mapping[i] for i in range(self.num_classes)]
        )
        plt.title('Confusion Matrix - SVM Clothing Detection (HOG Features)')
        plt.ylabel('True Label')
        plt.xlabel('Predicted Label')
        plt.tight_layout()
        plt.savefig(save_path, dpi=300)
        print(f"Confusion matrix saved to {save_path}")
        plt.close()
    
    def plot_per_class_accuracy(self, report, save_path='../output/per_class_accuracy.png'):
        """Plot per-class F1-score"""
        classes = [self.label_mapping[i] for i in range(self.num_classes)]
        f1_scores = [report[cls]['f1-score'] for cls in classes]
        
        plt.figure(figsize=(12, 6))
        bars = plt.bar(range(len(classes)), f1_scores)
        plt.xlabel('Clothing Category')
        plt.ylabel('F1-Score')
        plt.title('Per-Class Performance (SVM with HOG)')
        plt.xticks(range(len(classes)), classes, rotation=45, ha='right')
        plt.ylim([0, 1])
        plt.grid(axis='y', alpha=0.3)
        
        # Color bars based on performance
        for i, bar in enumerate(bars):
            if f1_scores[i] >= 0.8:
                bar.set_color('green')
            elif f1_scores[i] >= 0.6:
                bar.set_color('orange')
            else:
                bar.set_color('red')
        
        plt.tight_layout()
        plt.savefig(save_path, dpi=300)
        print(f"Per-class accuracy plot saved to {save_path}")
        plt.close()
    
    def predict_single(self, hog_features):
        """
        Predict category for single HOG feature vector
        
        Args:
            hog_features: HOG feature vector
            
        Returns:
            Prediction results
        """
        if len(hog_features.shape) == 1:
            hog_features = hog_features.reshape(1, -1)
        
        # Normalize features
        hog_features_scaled = self.scaler.transform(hog_features)
        
        # Get predictions
        predictions = self.model.predict_proba(hog_features_scaled)
        predicted_class = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class]
        
        # Get top 3 predictions
        top3_indices = np.argsort(predictions[0])[-3:][::-1]
        top3_predictions = [
            {
                'class': self.label_mapping[idx],
                'confidence': float(predictions[0][idx])
            }
            for idx in top3_indices
        ]
        
        return {
            'predicted_class': self.label_mapping[predicted_class],
            'confidence': float(confidence),
            'top3_predictions': top3_predictions
        }
    
    def save_evaluation_results(self, results, save_path='../output/evaluation_results.json'):
        """Save evaluation results to JSON"""
        results_serializable = {
            'algorithm': 'SVM (Support Vector Machine)',
            'feature_extraction': 'HOG (Histogram of Oriented Gradients)',
            'test_accuracy': float(results['test_accuracy']),
            'test_top3_accuracy': float(results['test_top3_accuracy']),
            'classification_report': results['classification_report']
        }
        
        with open(save_path, 'w') as f:
            json.dump(results_serializable, f, indent=2)
        
        print(f"Evaluation results saved to {save_path}")

def main():
    parser = argparse.ArgumentParser(description='Evaluate SVM clothing detection model')
    parser.add_argument('--model', type=str, default='../models/clothing_svm_best.pkl',
                       help='Path to trained SVM model')
    parser.add_argument('--scaler', type=str, default='../models/clothing_scaler_best.pkl',
                       help='Path to fitted scaler')
    parser.add_argument('--dataset', type=str, default='../dataset/ml_ready_images_data.csv',
                       help='Path to dataset CSV')
    args = parser.parse_args()
    
    print("="*60)
    print("PCVK Clothing Detection - SVM Model Evaluation")
    print("="*60)
    
    # Load and preprocess test data
    print("\n[1/3] Loading test dataset and extracting HOG features...")
    preprocessor = ClothingDataPreprocessor(args.dataset)
    dataset = preprocessor.prepare_dataset(test_size=0.2, val_size=0.1, augment=False)
    
    # Initialize evaluator
    print("\n[2/3] Initializing evaluator...")
    evaluator = ModelEvaluator(args.model, args.scaler)
    
    # Evaluate model
    print("\n[3/3] Running evaluation...")
    results = evaluator.evaluate(dataset['X_test'], dataset['y_test'])
    
    # Plot results
    evaluator.plot_confusion_matrix(dataset['y_test'], results['predictions'])
    evaluator.plot_per_class_accuracy(results['classification_report'])
    
    # Save results
    evaluator.save_evaluation_results(results)
    
    print("\n" + "="*60)
    print("Evaluation completed successfully!")
    print("="*60)
    print(f"\nFinal Test Accuracy: {results['test_accuracy']:.4f}")
    print(f"Top-3 Accuracy: {results['test_top3_accuracy']:.4f}")

if __name__ == "__main__":
    main()
