"""Quick test to verify HOG feature extraction works"""

from datasets import load_dataset
from skimage.feature import hog
from skimage import color
from PIL import Image
import numpy as np

print("Loading a small sample of FairFace dataset...")
ds = load_dataset("HuggingFaceM4/FairFace", "0.25", split="train")
sample = ds[0]

image = sample['image']
race = sample['race']

print(f"Image type: {type(image)}")
print(f"Image size: {image.size if hasattr(image, 'size') else image.shape}")
print(f"Race label: {race}")

# Convert to RGB if needed
if isinstance(image, Image.Image):
    img = image.convert('RGB')
    img_resized = img.resize((224, 224), Image.Resampling.LANCZOS)
    img_array = np.array(img_resized, dtype=np.float32) / 255.0
else:
    img_array = image

print(f"Array shape: {img_array.shape}")
print(f"Array dtype: {img_array.dtype}")

# Convert to grayscale
if len(img_array.shape) == 3:
    img_gray = color.rgb2gray(img_array)
else:
    img_gray = img_array

print(f"Gray shape: {img_gray.shape}")

# Extract HOG
try:
    features = hog(
        img_gray,
        orientations=9,
        pixels_per_cell=(8, 8),
        cells_per_block=(2, 2),
        visualize=False,
        channel_axis=None
    )
    print(f"✓ HOG features extracted successfully!")
    print(f"  Feature vector length: {len(features)}")
except Exception as e:
    print(f"✗ Error extracting HOG features: {e}")
    import traceback
    traceback.print_exc()
