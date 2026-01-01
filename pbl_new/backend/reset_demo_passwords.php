<?php
require_once 'config.php';

// Safety: hanya boleh dijalankan dari localhost (bukan via ngrok/internet)
$remote = $_SERVER['REMOTE_ADDR'] ?? '';
if ($remote !== '127.0.0.1' && $remote !== '::1') {
    sendJsonResponse([
        'success' => false,
        'error' => 'Forbidden: hanya bisa dijalankan dari localhost',
        'remote_addr' => $remote,
    ], 403);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse([
        'success' => false,
        'error' => 'Method not allowed. Use POST.',
        'hint' => 'Kirim POST ke http://localhost/jawara/backend/reset_demo_passwords.php',
    ], 405);
}

$conn = getDbConnection();

// Set semua password user menjadi password123
$newPasswordPlain = 'password123';
$newHash = password_hash($newPasswordPlain, PASSWORD_DEFAULT);

$stmt = $conn->prepare('UPDATE users SET password = ?');
if (!$stmt) {
    $conn->close();
    sendJsonResponse([
        'success' => false,
        'error' => 'Prepare failed: ' . $conn->error,
    ], 500);
}

$stmt->bind_param('s', $newHash);

if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendJsonResponse([
        'success' => false,
        'error' => 'Execute failed: ' . $stmt->error,
    ], 500);
}

$affected = $stmt->affected_rows;
$stmt->close();
$conn->close();

sendJsonResponse([
    'success' => true,
    'message' => 'All user passwords set to password123',
    'affected_rows' => $affected,
]);
