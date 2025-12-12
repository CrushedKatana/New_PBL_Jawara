<?php
/**
 * ML Detection API
 * Endpoint untuk deteksi pakaian menggunakan Machine Learning
 */

// Suppress all errors/warnings to ensure clean JSON output
error_reporting(0);
ini_set('display_errors', '0');

// Increase limits for ML processing
ini_set('max_execution_time', '180'); // 3 minutes
ini_set('memory_limit', '512M'); // 512MB for model loading
set_time_limit(180);

// Start output buffering to catch any stray output
ob_start();

// phpcs:ignoreFile - Using require_once for project config include
@require_once 'config.php'; // NOSONAR - project uses file include for config

// Clear any output from config
ob_clean();

// Ensure database connection exists (fallback if config.php failed)
if (!isset($conn) || $conn === null) {
    // Try to create connection directly
    $host = 'localhost';
    $user = 'root';
    $pass = '';
    $dbname = 'marketplace_rtrw';
    
    @$conn = new mysqli($host, $user, $pass, $dbname);
    
    // If still fails, set to null (will skip database save)
    if ($conn->connect_error) {
        $conn = null;
    }
}

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
 * Send JSON response and exit cleanly
 */
function sendJsonResponse($data) {
    // Get current buffer contents and clear it
    while (ob_get_level() > 0) {
        ob_end_clean();
    }
    
    // Start fresh buffer for JSON only
    ob_start();
    
    // Set headers
    header('Content-Type: application/json');
    header('Content-Length: ' . strlen(json_encode($data)));
    
    // Output JSON
    echo json_encode($data);
    
    // Flush and close buffer
    ob_end_flush();
    flush();
    exit;
}

/**
 * Call Python ML model untuk deteksi pakaian
 *
 * @param string $imagePath Path ke file gambar
 * @return array Hasil deteksi
 */
function detectClothing($imagePath) {
    // Increase execution time limit for ML processing (model loading takes time)
    set_time_limit(120); // 2 minutes
    
    // Path ke Python script dan model SVM + HOG
    $pythonScript = __DIR__ . '/../ml_training/scripts/predict.py';
    $modelPath = __DIR__ . '/../ml_training/models/clothing_svm_best.pkl';
    $scalerPath = __DIR__ . '/../ml_training/models/clothing_scaler_best.pkl';
    $pythonExe = 'C:\\Users\\chare\\AppData\\Local\\Python\\bin\\python.exe';
    
    // Verify files exist
    if (!file_exists($pythonExe)) {
        return [
            'success' => false,
            'message' => 'Python executable not found',
            'debug' => ['python_path' => $pythonExe]
        ];
    }
    
    if (!file_exists($pythonScript)) {
        return [
            'success' => false,
            'message' => 'Python script not found',
            'debug' => ['script_path' => $pythonScript]
        ];
    }
    
    if (!file_exists($modelPath)) {
        return [
            'success' => false,
            'message' => 'Model file not found',
            'debug' => ['model_path' => $modelPath]
        ];
    }
    
    if (!file_exists($imagePath)) {
        return [
            'success' => false,
            'message' => 'Image file not found',
            'debug' => ['image_path' => $imagePath]
        ];
    }
    
    // Command untuk menjalankan Python script dengan HOG+SVM
    $command = sprintf(
        '"%s" "%s" --image "%s" --model "%s" --scaler "%s" 2>&1',
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
    
    $outputStr = implode("\n", $output);
    
    if ($returnCode !== 0) {
        return [
            'success' => false,
            'message' => 'Python script execution failed',
            'debug' => [
                'return_code' => $returnCode,
                'output' => $outputStr,
                'command' => $command
            ]
        ];
    }
    
    // Parse JSON output dari Python
    $result = json_decode($outputStr, true);
    
    if (!$result) {
        return [
            'success' => false,
            'message' => 'Failed to parse ML output',
            'debug' => [
                'raw_output' => $outputStr,
                'json_error' => json_last_error_msg()
            ]
        ];
    }
    
    return $result;
}

/**
 * Simpan hasil deteksi ke database
 */
function saveDetection($conn, $userId, $imagePath, $predictedClass, $confidence, $top3Predictions) {
    // Check if database connection exists
    if ($conn === null || !$conn) {
        // Skip database save if connection not available
        return true;
    }
    
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
        sendJsonResponse([
            'success' => false,
            'message' => 'No image uploaded or upload error'
        ]);
    }
    
    // Get user ID
    $userId = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
    
    if ($userId <= 0) {
        sendJsonResponse([
            'success' => false,
            'message' => 'Invalid user ID'
        ]);
    }
    
    // Validate image file - use extension-based validation (more reliable)
    $tmpPath = $_FILES['image']['tmp_name'];
    $originalName = $_FILES['image']['name'];
    $fileType = $_FILES['image']['type'];
    
    // Get extension from filename
    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
    
    // If no extension, try to detect from tmp file
    if (empty($extension)) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $detectedType = finfo_file($finfo, $tmpPath);
        finfo_close($finfo);
        
        // Map MIME to extension
        $mimeToExt = [
            'image/jpeg' => 'jpg',
            'image/jpg' => 'jpg',
            'image/png' => 'png',
        ];
        $extension = $mimeToExt[$detectedType] ?? 'jpg'; // Default to jpg
    }
    
    // Validate extension
    $allowedExtensions = ['jpg', 'jpeg', 'png'];
    if (!in_array($extension, $allowedExtensions)) {
        sendJsonResponse([
            'success' => false,
            'message' => 'Invalid file type. Only JPG and PNG allowed',
            'debug' => [
                'extension' => $extension,
                'mime_type' => $fileType,
                'original_name' => $originalName
            ]
        ]);
    }
    
    // Create upload directory if not exists
    $uploadDir = __DIR__ . '/uploads/ml_detections/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    
    // Generate unique filename with validated extension
    $filename = uniqid('ml_') . '_' . time() . '.' . $extension;
    $uploadPath = $uploadDir . $filename;
    
    // Move uploaded file
    if (!move_uploaded_file($_FILES['image']['tmp_name'], $uploadPath)) {
        sendJsonResponse([
            'success' => false,
            'message' => 'Failed to save uploaded file'
        ]);
    }
    
    // Run ML detection
    $detectionResult = detectClothing($uploadPath);
    
    if (!$detectionResult['success']) {
        // Delete uploaded file if detection failed
        unlink($uploadPath);
        
        sendJsonResponse($detectionResult);
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
        
        sendJsonResponse([
            'success' => false,
            'message' => 'Failed to save detection result'
        ]);
    }
    
    // Return success result
    sendJsonResponse([
        'success' => true,
        'predicted_class' => $detectionResult['predicted_class'],
        'confidence' => $detectionResult['confidence'],
        'top3_predictions' => $detectionResult['top3_predictions'],
        'message' => 'Detection successful'
    ]);
    
} else {
    sendJsonResponse([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

// Close database connection if exists
if ($conn !== null && $conn) {
    $conn->close();
}

