<?php
require_once 'config.php';

$conn = getDbConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getMessages($conn);
        break;
    case 'POST':
        sendMessage($conn);
        break;
    case 'PUT':
        markAsRead($conn);
        break;
    default:
        sendJsonResponse(['error' => 'Method not allowed'], 405);
}

function getMessages($conn) {
    $userId = $_GET['user_id'] ?? null;
    $conversationWith = $_GET['conversation_with'] ?? null;
    
    if (!$userId) {
        sendJsonResponse(['success' => false, 'error' => 'User ID required'], 400);
    }
    
    $userId = $conn->real_escape_string($userId);
    
    if ($conversationWith) {
        // Get specific conversation
        $conversationWith = $conn->real_escape_string($conversationWith);
        $sql = "SELECT m.*, 
                       sender.name as sender_name, sender.photo_url as sender_photo,
                       receiver.name as receiver_name, receiver.photo_url as receiver_photo,
                       p.title as product_title, p.image_url as product_image
                FROM messages m
                LEFT JOIN users sender ON m.sender_id = sender.id
                LEFT JOIN users receiver ON m.receiver_id = receiver.id
                LEFT JOIN products p ON m.product_id = p.id
                WHERE (m.sender_id = '$userId' AND m.receiver_id = '$conversationWith')
                   OR (m.sender_id = '$conversationWith' AND m.receiver_id = '$userId')
                ORDER BY m.created_at ASC";
    } else {
        // Get conversation list (latest message from each conversation)
        $sql = "SELECT m.*, 
                       sender.name as sender_name, sender.photo_url as sender_photo,
                       receiver.name as receiver_name, receiver.photo_url as receiver_photo,
                       p.title as product_title, p.image_url as product_image
                FROM messages m
                LEFT JOIN users sender ON m.sender_id = sender.id
                LEFT JOIN users receiver ON m.receiver_id = receiver.id
                LEFT JOIN products p ON m.product_id = p.id
                WHERE m.id IN (
                    SELECT MAX(id) FROM messages
                    WHERE sender_id = '$userId' OR receiver_id = '$userId'
                    GROUP BY LEAST(sender_id, receiver_id), GREATEST(sender_id, receiver_id)
                )
                ORDER BY m.created_at DESC";
    }
    
    $result = $conn->query($sql);
    $messages = [];
    
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $messages[] = $row;
        }
    }
    
    sendJsonResponse(['success' => true, 'data' => $messages]);
}

function sendMessage($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $id = uniqid('msg_');
    $senderId = $conn->real_escape_string($data['sender_id']);
    $receiverId = $conn->real_escape_string($data['receiver_id']);
    $productId = isset($data['product_id']) ? $conn->real_escape_string($data['product_id']) : null;
    $message = $conn->real_escape_string($data['message']);
    
    $productIdSql = $productId ? "'$productId'" : "NULL";
    
    $sql = "INSERT INTO messages (id, sender_id, receiver_id, product_id, message) 
            VALUES ('$id', '$senderId', '$receiverId', $productIdSql, '$message')";
    
    if ($conn->query($sql)) {
        sendJsonResponse(['success' => true, 'data' => ['id' => $id]], 201);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error], 500);
    }
}

function markAsRead($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $userId = $conn->real_escape_string($data['user_id']);
    $conversationWith = $conn->real_escape_string($data['conversation_with']);
    
    $sql = "UPDATE messages 
            SET is_read = TRUE 
            WHERE receiver_id = '$userId' AND sender_id = '$conversationWith'";
    
    if ($conn->query($sql)) {
        sendJsonResponse(['success' => true]);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error], 500);
    }
}

$conn->close();
?>
