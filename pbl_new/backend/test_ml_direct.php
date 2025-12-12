<?php
/**
 * Test ML Detection directly - untuk debugging
 */

// Test Python execution langsung
$pythonExe = 'C:\\Users\\chare\\AppData\\Local\\Python\\bin\\python.exe';
$pythonScript = __DIR__ . '/../ml_training/scripts/predict.py';
$modelPath = __DIR__ . '/../ml_training/models/clothing_svm_best.pkl';
$scalerPath = __DIR__ . '/../ml_training/models/clothing_scaler_best.pkl';

// Gunakan image yang diupload user (ambil yang terakhir)
$uploadDir = __DIR__ . '/uploads/ml_detections/';
$files = glob($uploadDir . '*.{jpg,jpeg,png}', GLOB_BRACE);
if (empty($files)) {
    die("No uploaded images found in $uploadDir\n");
}
$imagePath = end($files); // Get latest file

echo "Testing ML Detection...\n";
echo "======================\n";
echo "Python: $pythonExe\n";
echo "Script: $pythonScript\n";
echo "Model: $modelPath\n";
echo "Scaler: $scalerPath\n";
echo "Image: $imagePath\n\n";

// Check file existence
echo "File checks:\n";
echo "- Python exists: " . (file_exists($pythonExe) ? 'YES' : 'NO') . "\n";
echo "- Script exists: " . (file_exists($pythonScript) ? 'YES' : 'NO') . "\n";
echo "- Model exists: " . (file_exists($modelPath) ? 'YES' : 'NO') . "\n";
echo "- Scaler exists: " . (file_exists($scalerPath) ? 'YES' : 'NO') . "\n";
echo "- Image exists: " . (file_exists($imagePath) ? 'YES' : 'NO') . "\n\n";

// Build command
$command = sprintf(
    '"%s" "%s" --image "%s" --model "%s" --scaler "%s" 2>&1',
    $pythonExe,
    $pythonScript,
    $imagePath,
    $modelPath,
    $scalerPath
);

echo "Command:\n$command\n\n";

// Execute
echo "Executing...\n";
$output = [];
$returnCode = 0;
exec($command, $output, $returnCode);

echo "Return code: $returnCode\n";
echo "Output:\n";
print_r($output);
echo "\n";

// Parse result
$outputStr = implode('', $output);
echo "Raw output string:\n$outputStr\n\n";

$result = json_decode($outputStr, true);
if ($result) {
    echo "Parsed JSON:\n";
    print_r($result);
} else {
    echo "Failed to parse JSON!\n";
    echo "JSON error: " . json_last_error_msg() . "\n";
}
