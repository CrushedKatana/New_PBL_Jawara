"""
Test script untuk verify Gradio app locally sebelum deploy
"""

import sys
sys.path.insert(0, 'd:/CloneGithub/New_PBL_Jawara/huggingface_deployment')

from app import predict_clothing
import cv2
import numpy as np

# Test dengan sample image
print("Testing local Gradio app...")
print("=" * 50)

# Load test image
test_image_path = "d:/CloneGithub/New_PBL_Jawara/.conda/Lib/site-packages/matplotlib/mpl-data/sample_data/grace_hopper.jpg"

try:
    img = cv2.imread(test_image_path)
    if img is None:
        print(f"❌ Cannot load image: {test_image_path}")
        sys.exit(1)
    
    print(f"✅ Image loaded: {img.shape}")
    print(f"Testing prediction...")
    
    # Convert BGR to RGB for PIL compatibility
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Run prediction
    result_text, result_json = predict_clothing(img_rgb)
    
    print("\n" + "=" * 50)
    print("RESULT TEXT:")
    print(result_text)
    print("\n" + "=" * 50)
    print("RESULT JSON:")
    print(result_json)
    print("=" * 50)
    
    print("\n✅ Local test SUCCESS! App ready for Hugging Face deployment.")
    
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
