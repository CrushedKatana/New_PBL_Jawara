"""Quick debug script to understand FairFace dataset structure"""

from datasets import load_dataset
import warnings
warnings.filterwarnings('ignore')

print("Loading FairFace dataset...")
ds = load_dataset("HuggingFaceM4/FairFace", "0.25", split="train")

print(f"Dataset size: {len(ds)}")
print(f"\nDataset columns: {ds.column_names}")

# Check first few samples
print("\n" + "="*60)
print("First 5 samples:")
print("="*60)

for i in range(min(5, len(ds))):
    sample = ds[i]
    print(f"\nSample {i}:")
    print(f"  Keys: {sample.keys()}")
    for key in sample.keys():
        if key != 'image':
            print(f"  {key}: {sample[key]} (type: {type(sample[key]).__name__})")

# Get unique ethnicity values
print("\n" + "="*60)
print("Unique ethnicity values:")
print("="*60)

ethnicities = set()
for i in range(min(1000, len(ds))):
    ethnicities.add(ds[i]['ethnicity'])

print(f"Found {len(ethnicities)} unique ethnicities:")
for eth in sorted(ethnicities):
    print(f"  - {eth}")
