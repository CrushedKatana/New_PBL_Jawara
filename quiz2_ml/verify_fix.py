#!/usr/bin/env python3
"""
Quick verification that the dataset fix works.
Tests loading a few samples and extracting HOG features.
"""

import sys
print("🔍 VERIFYING FIX FOR ETHNIC CLASSIFICATION PROJECT", flush=True)
print("=" * 60, flush=True)

# Step 1: Test imports
print("\n[1/4] Testing imports...", flush=True)
try:
    from datasets import load_dataset
    from PIL import Image
    import numpy as np
    from skimage.feature import hog
    from skimage import exposure
    print("✓ All imports successful", flush=True)
except ImportError as e:
    print(f"✗ Import error: {e}", flush=True)
    sys.exit(1)

# Step 2: Load dataset
print("\n[2/4] Loading FairFace dataset...", flush=True)
try:
    ds = load_dataset("Zurich/FairFace", "train", split="train", streaming=False)
    print(f"✓ Dataset loaded: {len(ds)} samples", flush=True)
except Exception as e:
    print(f"✗ Dataset loading failed: {e}", flush=True)
    sys.exit(1)

# Step 3: Check dataset structure
print("\n[3/4] Verifying dataset structure...", flush=True)
try:
    sample = ds[0]
    print(f"✓ Dataset columns: {list(sample.keys())}", flush=True)
    
    # Key verification: check for 'race' column
    if 'race' not in sample:
        print("✗ ERROR: 'race' column not found!", flush=True)
        sys.exit(1)
    
    race_value = sample['race']
    print(f"✓ Sample race value: {race_value} (type: {type(race_value).__name__})", flush=True)
    
    # Verify it's an integer 0-6
    if not isinstance(race_value, int):
        print(f"✗ ERROR: race is not an integer! Type: {type(race_value)}", flush=True)
        sys.exit(1)
    
    if race_value < 0 or race_value > 6:
        print(f"✗ ERROR: race value {race_value} out of range [0-6]!", flush=True)
        sys.exit(1)
    
    print(f"✓ Race value is valid integer in range [0-6]", flush=True)
    
except Exception as e:
    print(f"✗ Dataset verification failed: {e}", flush=True)
    sys.exit(1)

# Step 4: Test HOG feature extraction
print("\n[4/4] Testing HOG feature extraction...", flush=True)
try:
    img = sample['image'].convert('L')
    img_array = np.array(img)
    
    # Extract HOG features
    features, hog_image = hog(
        img_array,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        visualize=True,
        channel_axis=None
    )
    
    print(f"✓ HOG feature extraction successful", flush=True)
    print(f"  - Image shape: {img_array.shape}", flush=True)
    print(f"  - Feature vector shape: {features.shape}", flush=True)
    print(f"  - Number of features: {len(features)}", flush=True)
    
except Exception as e:
    print(f"✗ HOG extraction failed: {e}", flush=True)
    sys.exit(1)

print("\n" + "=" * 60, flush=True)
print("✓ ALL VERIFICATIONS PASSED!", flush=True)
print("=" * 60, flush=True)
print("\n✅ The fix is working correctly!", flush=True)
print("✅ You can now run: python train_fast.py", flush=True)
print("", flush=True)
