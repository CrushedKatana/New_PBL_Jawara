<?php
// Matikan tampilan error HTML ke client, log saja ke server
ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);
ini_set('log_errors', 1);
error_reporting(E_ALL);

// Buffer semua output supaya tidak ada "<br /><b>..."/whitespace nyasar yang merusak JSON
ob_start();

// Konfigurasi Database MySQL XAMPP
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); // Default XAMPP password kosong
define('DB_NAME', 'marketplace_rtrw');

// Koneksi Database (PDO)
function get_db() {
    try {
        $pdo = new PDO(
            'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
            DB_USER,
            DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
            ]
        );
        return $pdo;
    } catch (PDOException $e) {
        sendJsonResponse([
            'success' => false,
            'error' => 'Database connection failed: ' . $e->getMessage(),
        ], 500);
    }
}

// Koneksi Database (MySQLi - legacy)
function getDbConnection() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    if ($conn->connect_error) {
        sendJsonResponse([
            'success' => false,
            'error' => 'Database connection failed: ' . $conn->connect_error,
        ], 500);
    }
    
    $conn->set_charset("utf8mb4");
    return $conn;
}

// Helper untuk response JSON
function sendJsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json');

    // Bersihkan output yang mungkin sudah terlanjur tercetak
    if (ob_get_length()) {
        ob_clean();
    }
    echo json_encode($data);
    exit;
}

// Enable CORS untuk Flutter
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}
?>
