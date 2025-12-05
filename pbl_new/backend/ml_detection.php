<?php
/**
 * ML Detection API
 * Endpoint untuk deteksi pakaian menggunakan Machine Learning
 */

// phpcs:ignoreFile - Using require_once for project config include
require_once 'config.php'; // NOSONAR - project uses file include for config

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

/**
 * Call Python ML model untuk deteksi pakaian
 *
 * @param string $imagePath Path ke file gambar
 * @return array Hasil deteksi
 */
function detectClothing($imagePath) {
    // Path ke Python script dan model SVM + HOG
    $pythonScript = __DIR__ . '/../ml_training/scripts/predict.py';
    $modelPath = __DIR__ . '/../ml_training/models/clothing_svm_best.pkl';
    $scalerPath = __DIR__ . '/../ml_training/models/clothing_scaler_best.pkl';
    $pythonExe = __DIR__ . '/../.conda/python.exe';
    
    // Command untuk menjalankan Python script dengan HOG+SVM
    $command = sprintf(
        '"%s" "%s" --image "%s" --model "%s" --scaler "%s"',
        $pythonExe,
        $pythonScript,
        $imagePath,
        $modelPath,
        $scalerPath
    );
    
    // Execute command dan capture output
    $output = [];
    $returnCode = 0;
    exec($command, $output, $returnCode);
    
    if ($returnCode !== 0) {
        return [
            'success' => false,
            'message' => 'Failed to run ML model'
        ];
    }
    
    // Parse JSON output dari Python
    $result = json_decode(implode('', $output), true);
    
    if (!$result) {
        return [
            'success' => false,
            'message' => 'Failed to parse ML output'
        ];
    }
    
    return $result;
}

/**
 * Simpan hasil deteksi ke database
 */
function saveDetection($conn, $userId, $imagePath, $predictedClass, $confidence, $top3Predictions) {
    $sql = "INSERT INTO ml_detections (user_id, image_path, predicted_class, confidence, top3_predictions, created_at)
            VALUES (?, ?, ?, ?, ?, NOW())";
    
    $stmt = $conn->prepare($sql);
    $top3Json = json_encode($top3Predictions);
    
    $stmt->bind_param(
        "issds",
        $userId,
        $imagePath,
        $predictedClass,
        $confidence,
        $top3Json
    );
    
    return $stmt->execute();
}

// Main endpoint handler
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // Check if file uploaded
    if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        echo json_encode([
            'success' => false,
            'message' => 'No image uploaded or upload error'
        ]);
        exit;
    }
    
    // Get user ID
    $userId = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
    
    if ($userId <= 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid user ID'
        ]);
        exit;
    }
    
    // Validate image file
    $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
    $fileType = $_FILES['image']['type'];
    
    if (!in_array($fileType, $allowedTypes)) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid file type. Only JPG and PNG allowed'
        ]);
        exit;
    }
    
    // Create upload directory if not exists
    $uploadDir = __DIR__ . '/uploads/ml_detections/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    
    // Generate unique filename
    $extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
    $filename = uniqid('ml_') . '_' . time() . '.' . $extension;
    $uploadPath = $uploadDir . $filename;
    
    // Move uploaded file
    if (!move_uploaded_file($_FILES['image']['tmp_name'], $uploadPath)) {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to save uploaded file'
        ]);
        exit;
    }
    
    // Run ML detection
    $detectionResult = detectClothing($uploadPath);
    
    if (!$detectionResult['success']) {
        // Delete uploaded file if detection failed
        unlink($uploadPath);
        
        echo json_encode($detectionResult);
        exit;
    }
    
    // Save to database
    $saved = saveDetection(
        $conn,
        $userId,
        $uploadPath,
        $detectionResult['predicted_class'],
        $detectionResult['confidence'],
        $detectionResult['top3_predictions']
    );
    
    if (!$saved) {
        // Delete uploaded file if save failed
        unlink($uploadPath);
        
        echo json_encode([
            'success' => false,
            'message' => 'Failed to save detection result'
        ]);
        exit;
    }
    
    // Return success result
    echo json_encode([
        'success' => true,
        'predicted_class' => $detectionResult['predicted_class'],
        'confidence' => $detectionResult['confidence'],
        'top3_predictions' => $detectionResult['top3_predictions'],
        'message' => 'Detection successful'
    ]);
    
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

$conn->close();

