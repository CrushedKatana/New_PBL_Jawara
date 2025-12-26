<?php 
header('Content-Type: application/json'); 
 
// ML Detection endpoint untuk PCVK 
$pythonScript = __DIR__ . '/../ml_training/scripts/predict.py'; 
$modelPath = __DIR__ . '/../ml_training/models/clothing_svm_best.pkl'; 
$scalerPath = __DIR__ . '/../ml_training/models/clothing_scaler_best.pkl'; 
$pythonExe = 'C:\\Users\\chare\\AppData\\Local\\Python\\bin\\python.exe'; 
 
if (!file_exists($pythonExe)) { 
    die(json_encode(['success' => false, 'message' => 'Python not found'])); 
} 
 
// Rest of the code... 
?>
