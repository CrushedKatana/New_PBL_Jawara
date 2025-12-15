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
    
    case 'change_password':
        changePassword($conn);
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
 * For RT/RW: shows warga stats, verified count, products in RT
 * For Warga: shows personal selling stats
 */
function getUserStats($conn) {
    $userId = $_POST['user_id'] ?? $_GET['user_id'] ?? null;
    
    if (!$userId) {
        sendJsonResponse(['error' => 'User ID required'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    
    // Get user role and RT number
    $sqlUser = "SELECT role, rt_number FROM users WHERE id = '$userId'";
    $userResult = $conn->query($sqlUser);
    
    if ($userResult->num_rows === 0) {
        sendJsonResponse(['error' => 'User not found'], 404);
        return;
    }
    
    $user = $userResult->fetch_assoc();
    $role = $user['role'] ?? 'warga';
    
    if ($role === 'rt' || $role === 'rw') {
        // RT/RW Stats - show community stats
        $rtNumber = $user['rt_number'];
        
        // Total warga in RT
        $sqlWarga = "SELECT COUNT(*) as total FROM users WHERE rt_number = '$rtNumber'";
        $totalWarga = $conn->query($sqlWarga)->fetch_assoc()['total'] ?? 0;
        
        // Total verified warga
        $sqlVerified = "SELECT COUNT(*) as total FROM users WHERE rt_number = '$rtNumber' AND is_verified = 1";
        $totalVerified = $conn->query($sqlVerified)->fetch_assoc()['total'] ?? 0;
        
        // Total products in RT
        $sqlProducts = "SELECT COUNT(*) as total FROM products p 
                        INNER JOIN users u ON p.seller_id = u.id 
                        WHERE u.rt_number = '$rtNumber'";
        $totalProducts = $conn->query($sqlProducts)->fetch_assoc()['total'] ?? 0;
        
        // Pending approvals
        $sqlPending = "SELECT COUNT(*) as total FROM users WHERE rt_number = '$rtNumber' AND is_verified = 0";
        $pendingApproval = $conn->query($sqlPending)->fetch_assoc()['total'] ?? 0;
        
        sendJsonResponse([
            'success' => true,
            'stats' => [
                'total_warga' => (int)$totalWarga,
                'total_verified' => (int)$totalVerified,
                'total_products' => (int)$totalProducts,
                'pending_approval' => (int)$pendingApproval
            ]
        ]);
    } else {
        // Regular Warga Stats - personal selling stats
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
}

/**
 * Change user password
 */
function changePassword($conn) {
    $userId = $_POST['user_id'] ?? null;
    $currentPassword = $_POST['current_password'] ?? null;
    $newPassword = $_POST['new_password'] ?? null;
    
    if (!$userId || !$currentPassword || !$newPassword) {
        sendJsonResponse(['success' => false, 'message' => 'Missing required fields'], 400);
        return;
    }
    
    $userId = $conn->real_escape_string($userId);
    
    // Verify current password
    $sql = "SELECT password FROM users WHERE id = '$userId'";
    $result = $conn->query($sql);
    
    if ($result->num_rows === 0) {
        sendJsonResponse(['success' => false, 'message' => 'User not found'], 404);
        return;
    }
    
    $user = $result->fetch_assoc();
    
    if (!password_verify($currentPassword, $user['password'])) {
        sendJsonResponse(['success' => false, 'message' => 'Password saat ini salah'], 401);
        return;
    }
    
    // Hash new password
    $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
    
    // Update password
    $updateSql = "UPDATE users SET password = '$hashedPassword', updated_at = NOW() WHERE id = '$userId'";
    
    if ($conn->query($updateSql)) {
        sendJsonResponse([
            'success' => true,
            'message' => 'Password berhasil diubah'
        ]);
    } else {
        sendJsonResponse([
            'success' => false,
            'message' => 'Gagal mengubah password: ' . $conn->error
        ], 500);
    }
}
?>
