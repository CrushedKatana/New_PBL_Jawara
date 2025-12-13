<?php
/**
 * Mock ML Detection API untuk testing Dart parsing
 * Simulates Gradio response format
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Simulate processing delay
sleep(1);

// Mock ML result (same as Hugging Face API)
$mlResult = [
    'success' => true,
    'predicted_class' => 'Topi',
    'confidence' => 0.998,
    'top3_predictions' => [
        ['class' => 'Topi', 'confidence' => 0.998],
        ['class' => 'T-Shirt', 'confidence' => 0.001],
        ['class' => 'Sepatu', 'confidence' => 0.001],
    ],
    'method' => 'HOG + SVM (Mock)'
];

// Gradio format: wrap in data array with JSON string
$gradioResponse = [
    'data' => [
        json_encode($mlResult, JSON_UNESCAPED_UNICODE)
    ]
];

echo json_encode($gradioResponse, JSON_UNESCAPED_UNICODE);
?>
