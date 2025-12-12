#!/bin/bash

# Setup script untuk Hugging Face Space deployment

echo "==================================="
echo "Clothing Detection - Setup Script"
echo "==================================="

# Check if models directory exists
if [ ! -d "models" ]; then
    echo "Creating models directory..."
    mkdir -p models
fi

# Copy model files
echo "Copying model files..."
if [ -f "models/clothing_svm_best.pkl" ]; then
    echo "✓ Model file found"
else
    echo "⚠ Warning: clothing_svm_best.pkl not found in models/"
    echo "Please upload the model file to models/ directory"
fi

if [ -f "models/clothing_scaler_best.pkl" ]; then
    echo "✓ Scaler file found"
else
    echo "⚠ Warning: clothing_scaler_best.pkl not found in models/"
    echo "Please upload the scaler file to models/ directory"
fi

# Create examples directory
if [ ! -d "examples" ]; then
    echo "Creating examples directory..."
    mkdir -p examples
    echo "Please add example images: topi.jpg, kemeja.jpg, sepatu.jpg, tshirt.jpg"
fi

echo ""
echo "Setup complete!"
echo "Run: python huggingface_app.py"
echo "Or deploy to Hugging Face Spaces"
