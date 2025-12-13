<?php
require_once 'config.php';

$conn = getDbConnection();
$action = $_POST['action'] ?? $_GET['action'] ?? '';

switch ($action) {
    case 'get_profile':
        getUserProfile($conn);
        break;
    
    case 'update_profile':
        updateUserProfile($conn);
        break;
    
    case 'get_stats':
        getUserStats($conn);
        break;
    
    default:
        sendJsonResponse(['error' => 'Invalid action'], 400);
}

/**
 * Get user profile data
 */
function getUserProfile($conn) {
    $userId = $_POST['user_id'] ?? $_GET['user_id'] ?? null;
    
    if (!$userId) {
        sendJsonResponse(['error' => 'User ID required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    
    $sql = "SELECT 
                id,
                name,
                email,
                phone,
                address,
                role,
                rt_number,
                rw_number,
                is_verified,
                created_at,
                photo_url as profile_image
            FROM users
            WHERE id = '$userId'";
    
    $result = $conn->query($sql);
    
    if ($result && $user = $result->fetch_assoc()) {
        sendJsonResponse([
            'success' => true,
            'user' => $user
        ]);
    } else {
        sendJsonResponse([
            'success' => false,
            'error' => 'User not found'
        ], 404);
    }
}

/**
 * Update user profile
 */
function updateUserProfile($conn) {
    $userId = $_POST['user_id'] ?? null;
    $name = $_POST['name'] ?? null;
    $phone = $_POST['phone'] ?? null;
    $address = $_POST['address'] ?? null;
    
    if (!$userId) {
        sendJsonResponse(['error' => 'User ID required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    $updates = [];
    
    if ($name !== null) {
        $name = $conn->real_escape_string($name);
        $updates[] = "name = '$name'";
    }
    
    if ($phone !== null) {
        $phone = $conn->real_escape_string($phone);
        $updates[] = "phone = '$phone'";
    }
    
    if ($address !== null) {
        $address = $conn->real_escape_string($address);
        $updates[] = "address = '$address'";
    }
    
    if (empty($updates)) {
        sendJsonResponse(['error' => 'No fields to update'], 400);
        return;
    }
    
    $sql = "UPDATE users SET " . implode(", ", $updates) . ", updated_at = NOW() WHERE id = '$userId'";
    
    if ($conn->query($sql)) {
        sendJsonResponse([
            'success' => true,
            'message' => 'Profile updated successfully'
        ]);
    } else {
        sendJsonResponse([
            'success' => false,
            'error' => 'Failed to update profile: ' . $conn->error
        ], 500);
    }
}

/**
 * Get user statistics (products sold, ratings, etc.)
 */
function getUserStats($conn) {
    $userId = $_POST['user_id'] ?? $_GET['user_id'] ?? null;
    
    if (!$userId) {
        sendJsonResponse(['error' => 'User ID required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    
    // Get products count
    $sqlProducts = "SELECT COUNT(*) as total_products FROM products WHERE seller_id = '$userId'";
    $products = $conn->query($sqlProducts)->fetch_assoc()['total_products'] ?? 0;
    
    // Get sold products count (from transactions)
    $sqlSold = "SELECT COUNT(DISTINCT p.id) as total_sold 
                FROM products p 
                JOIN transactions t ON p.id = t.product_id 
                WHERE p.seller_id = '$userId' AND t.status = 'completed'";
    $sold = $conn->query($sqlSold)->fetch_assoc()['total_sold'] ?? 0;
    
    // Get favorites count
    $sqlFavorites = "SELECT COUNT(*) as total_favorites 
                     FROM product_favorites 
                     WHERE product_id IN (SELECT id FROM products WHERE seller_id = '$userId')";
    $favorites = $conn->query($sqlFavorites)->fetch_assoc()['total_favorites'] ?? 0;
    
    // Calculate average rating
    $sqlRating = "SELECT AVG(rating) as avg_rating 
                  FROM product_reviews 
                  WHERE product_id IN (SELECT id FROM products WHERE seller_id = '$userId')";
    $ratingResult = $conn->query($sqlRating)->fetch_assoc();
    $avgRating = $ratingResult['avg_rating'] ? round($ratingResult['avg_rating'], 1) : 0;
    
    sendJsonResponse([
        'success' => true,
        'stats' => [
            'total_products' => (int)$products,
            'total_sold' => (int)$sold,
            'total_favorites' => (int)$favorites,
            'avg_rating' => (float)$avgRating
        ]
    ]);
}
?>
