<?php
require_once 'config.php';

$conn = getDbConnection();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $sql = "SELECT * FROM categories ORDER BY name ASC";
    $result = $conn->query($sql);
    $categories = [];
    
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $categories[] = $row;
        }
    }
    
    sendJsonResponse(['success' => true, 'data' => $categories]);
} else {
    sendJsonResponse(['error' => 'Method not allowed'], 405);
}

$conn->close();
?>
