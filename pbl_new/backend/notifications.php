<?php
require_once 'config.php';

$conn = getDbConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $action = $_GET['action'] ?? 'list';
        if ($action === 'count') {
            getUnreadCount($conn);
        } else {
            getNotifications($conn);
        }
        break;
    case 'POST':
        createNotification($conn);
        break;
    case 'PUT':
        markAsRead($conn);
        break;
    default:
        sendJsonResponse(['error' => 'Method not allowed'], 405);
}

/**
 * Get notifications for user
 */
function getNotifications($conn) {
    $userId = $_GET['user_id'] ?? null;
    $filter = $_GET['filter'] ?? 'semua'; // semua, pesanan, pesan
    $limit = (int)($_GET['limit'] ?? 20);
    $offset = (int)($_GET['offset'] ?? 0);
    
    if (!$userId) {
        sendJsonResponse(['error' => 'User ID required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    
    $sql = "SELECT 
                n.id,
                n.user_id,
                n.title,
                n.message,
                n.type,
                n.is_read,
                n.related_id,
                n.created_at,
                n.data
            FROM notifications n
            WHERE n.user_id = '$userId'";
    
    // Filter by type
    if ($filter === 'pesanan') {
        $sql .= " AND n.type IN ('order', 'transaction', 'payment')";
    } elseif ($filter === 'pesan') {
        $sql .= " AND n.type = 'message'";
    }
    
    $sql .= " ORDER BY n.created_at DESC LIMIT $limit OFFSET $offset";
    
    $result = $conn->query($sql);
    $notifications = [];
    
    while ($row = $result->fetch_assoc()) {
        $row['is_read'] = (bool)$row['is_read'];
        $row['data'] = $row['data'] ? json_decode($row['data'], true) : null;
        $notifications[] = $row;
    }
    
    sendJsonResponse([
        'success' => true,
        'notifications' => $notifications
    ]);
}

/**
 * Get unread notification count
 */
function getUnreadCount($conn) {
    $userId = $_GET['user_id'] ?? null;
    
    if (!$userId) {
        sendJsonResponse(['error' => 'User ID required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    
    $sql = "SELECT COUNT(*) as count 
            FROM notifications 
            WHERE user_id = '$userId' AND is_read = 0";
    
    $result = $conn->query($sql);
    $count = $result->fetch_assoc()['count'] ?? 0;
    
    sendJsonResponse([
        'success' => true,
        'count' => (int)$count
    ]);
}

/**
 * Create a new notification
 */
function createNotification($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $userId = $data['user_id'] ?? null;
    $title = $data['title'] ?? null;
    $message = $data['message'] ?? null;
    $type = $data['type'] ?? 'general'; // general, order, message, transaction, payment
    $relatedId = $data['related_id'] ?? null;
    $extraData = isset($data['data']) ? json_encode($data['data']) : null;
    
    if (!$userId || !$title || !$message) {
        sendJsonResponse(['error' => 'User ID, title, and message required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    $title = $conn->real_escape_string($title);
    $message = $conn->real_escape_string($message);
    $type = $conn->real_escape_string($type);
    
    $sql = "INSERT INTO notifications (user_id, title, message, type, related_id, data, is_read, created_at) 
            VALUES ('$userId', '$title', '$message', '$type', ";
    
    $sql .= $relatedId ? "'$relatedId'" : "NULL";
    $sql .= ", ";
    $sql .= $extraData ? "'" . $conn->real_escape_string($extraData) . "'" : "NULL";
    $sql .= ", 0, NOW())";
    
    if ($conn->query($sql)) {
        sendJsonResponse([
            'success' => true,
            'id' => $conn->insert_id,
            'message' => 'Notification created'
        ]);
    } else {
        sendJsonResponse([
            'success' => false,
            'error' => 'Failed to create notification: ' . $conn->error
        ], 500);
    }
}

/**
 * Mark notification(s) as read
 */
function markAsRead($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $notificationId = $data['id'] ?? null;
    $userId = $data['user_id'] ?? null;
    $markAll = $data['mark_all'] ?? false;
    
    if (!$userId) {
        sendJsonResponse(['error' => 'User ID required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    
    if ($markAll) {
        // Mark all as read for user
        $sql = "UPDATE notifications SET is_read = 1 WHERE user_id = '$userId' AND is_read = 0";
    } else {
        if (!$notificationId) {
            sendJsonResponse(['error' => 'Notification ID required'], 400);
            return;
        }
        $notificationId = $conn->real_escape_string($notificationId);
        $sql = "UPDATE notifications SET is_read = 1 WHERE id = '$notificationId' AND user_id = '$userId'";
    }
    
    if ($conn->query($sql)) {
        sendJsonResponse([
            'success' => true,
            'message' => 'Notification(s) marked as read',
            'affected' => $conn->affected_rows
        ]);
    } else {
        sendJsonResponse([
            'success' => false,
            'error' => 'Failed to mark as read: ' . $conn->error
        ], 500);
    }
}
?>
