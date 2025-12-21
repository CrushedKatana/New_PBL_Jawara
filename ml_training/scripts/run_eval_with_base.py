"""Utility runner to evaluate the SVM model when images live in the Filtered_Image folder.

This exists to emit y_true/y_pred arrays and a confusion matrix for reporting without
changing the main evaluate.py entrypoint.
"""

import sys
import numpy as np
from sklearn.metrics import confusion_matrix

sys.path.append(".")

from preprocess import ClothingDataPreprocessor  # noqa: E402
from evaluate import ModelEvaluator  # noqa: E402


def main():
    preprocessor = ClothingDataPreprocessor(
        csv_path="../dataset/ml_ready_images_data.csv",
        base_image_dir="../dataset/Filtered_Image",
    )
    dataset = preprocessor.prepare_dataset(test_size=0.2, val_size=0.1, augment=False)

    evaluator = ModelEvaluator(
        model_path="../models/clothing_svm_best.pkl",
        scaler_path="../models/clothing_scaler_best.pkl",
        label_mapping_path="../models/label_mapping.json",
    )

    results = evaluator.evaluate(dataset["X_test"], dataset["y_test"])

    cm = confusion_matrix(dataset["y_test"], results["predictions"])
    np.save("../output/y_true.npy", dataset["y_test"])
    np.save("../output/y_pred.npy", results["predictions"])
    np.save("../output/confusion_matrix.npy", cm)

    print("Confusion matrix (rows=true, cols=pred):")
    print(cm)
    print("\nSaved arrays:")
    print(" - ../output/y_true.npy")
    print(" - ../output/y_pred.npy")
    print(" - ../output/confusion_matrix.npy")


if __name__ == "__main__":
    main()