// Define constants to avoid duplicated literals
class MLDetectionHistory {
    public const ERR_INVALID_USER_ID = 'Invalid user ID';
}
<?php
/**
 * ML Detection History API
 * Endpoint untuk riwayat dan statistik deteksi pakaian
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
 * Get detection history for user
 */
function getDetectionHistory($conn, $userId, $limit = 20) {
        $sql = "SELECT id, predicted_class, confidence, top3_predictions, created_at
            FROM ml_detections
            WHERE user_id = ?
            ORDER BY created_at DESC
            LIMIT ?";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $userId, $limit);
    $stmt->execute();
    
    $result = $stmt->get_result();
    $history = [];
    
    while ($row = $result->fetch_assoc()) {
        $row['top3_predictions'] = json_decode($row['top3_predictions'], true);
        $history[] = $row;
    }
    
    return [
        'success' => true,
        'data' => $history
    ];
}

/**
 * Get category statistics for user
 */
function getCategoryStats($conn, $userId) {
    // Total detections
    $sqlTotal = "SELECT COUNT(*) as total FROM ml_detections WHERE user_id = ?";
    $stmt = $conn->prepare($sqlTotal);
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $totalResult = $stmt->get_result()->fetch_assoc();
    $totalDetections = $totalResult['total'];
    
    // By category
    $sqlCategory = "SELECT predicted_class as category, COUNT(*) as count
                    FROM ml_detections
                    WHERE user_id = ?
                    GROUP BY predicted_class
                    ORDER BY count DESC";
    
    $stmt = $conn->prepare($sqlCategory);
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    
    $result = $stmt->get_result();
    $byCategory = [];
    
    while ($row = $result->fetch_assoc()) {
        $byCategory[] = $row;
    }
    
    // Average confidence
    $sqlAvg = "SELECT AVG(confidence) as avg_confidence FROM ml_detections WHERE user_id = ?";
    $stmt = $conn->prepare($sqlAvg);
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $avgResult = $stmt->get_result()->fetch_assoc();
    
    return [
        'success' => true,
        'stats' => [
            'total_detections' => $totalDetections,
            'by_category' => $byCategory,
            'avg_confidence' => floatval($avgResult['avg_confidence'] ?? 0)
        ]
    ];
}

/**
 * Get global statistics (for admin)
 */
function getGlobalStats($conn) {
    // Total detections
    $sqlTotal = "SELECT COUNT(*) as total FROM ml_detections";
    $totalResult = $conn->query($sqlTotal)->fetch_assoc();
    $totalDetections = $totalResult['total'];
    
    // Total users who used ML
    $sqlUsers = "SELECT COUNT(DISTINCT user_id) as total_users FROM ml_detections";
    $usersResult = $conn->query($sqlUsers)->fetch_assoc();
    $totalUsers = $usersResult['total_users'];
    
    // Average confidence
    $sqlAvg = "SELECT AVG(confidence) as avg_confidence FROM ml_detections";
    $avgResult = $conn->query($sqlAvg)->fetch_assoc();
    
    // Most detected category
    $sqlMost = "SELECT predicted_class, COUNT(*) as count
                FROM ml_detections
                GROUP BY predicted_class
                ORDER BY count DESC
                LIMIT 1";
    $mostResult = $conn->query($sqlMost)->fetch_assoc();
    
    // By category
    $sqlCategory = "SELECT predicted_class as category, COUNT(*) as count
                    FROM ml_detections
                    GROUP BY predicted_class
                    ORDER BY count DESC
                    LIMIT 10";
    
    $categoryResult = $conn->query($sqlCategory);
    $byCategory = [];
    while ($row = $categoryResult->fetch_assoc()) {
        $byCategory[] = $row;
    }
    
    // Recent detections with user info
    $sqlRecent = "SELECT md.id, md.predicted_class, md.confidence, md.created_at,
                         u.nama as user_name
                  FROM ml_detections md
                  LEFT JOIN auth_users u ON md.user_id = u.id
                  ORDER BY md.created_at DESC
                  LIMIT 10";
    
    $recentResult = $conn->query($sqlRecent);
    $recentDetections = [];
    while ($row = $recentResult->fetch_assoc()) {
        $recentDetections[] = $row;
    }
    
    return [
        'success' => true,
        'stats' => [
            'total_detections' => $totalDetections,
            'total_users' => $totalUsers,
            'avg_confidence' => floatval($avgResult['avg_confidence'] ?? 0),
            'most_detected_category' => $mostResult['predicted_class'] ?? 'N/A',
            'by_category' => $byCategory,
            'recent_detections' => $recentDetections
        ]
    ];
}

/**
 * Save detection result
 */
function saveDetection($conn, $data) {
    $sql = "INSERT INTO ml_detections (user_id, image_path, predicted_class, confidence, top3_predictions, created_at)
            VALUES (?, ?, ?, ?, ?, NOW())";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param(
        "issds",
        $data['user_id'],
        $data['image_path'],
        $data['predicted_class'],
        $data['confidence'],
        $data['top3_predictions']
    );
    
    if ($stmt->execute()) {
        return [
            'success' => true,
            'message' => 'Detection saved successfully',
            'id' => $conn->insert_id
        ];
    } else {
        return [
            'success' => false,
            'message' => 'Failed to save detection'
        ];
    }
}

// Main request handler
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    switch ($action) {
        case 'get_history':
            $userId = intval($_POST['user_id'] ?? 0);
            $limit = intval($_POST['limit'] ?? 20);
            
            if ($userId <= 0) {
                echo json_encode([
                    'success' => false,
                    'message' => MLDetectionHistory::ERR_INVALID_USER_ID
                ]);
                exit;
            }
            
            $result = getDetectionHistory($conn, $userId, $limit);
            echo json_encode($result);
            break;
            
        case 'get_stats':
            $userId = intval($_POST['user_id'] ?? 0);
            
            if ($userId <= 0) {
                echo json_encode([
                    'success' => false,
                    'message' => MLDetectionHistory::ERR_INVALID_USER_ID
                ]);
                exit;
            }
            
            $result = getCategoryStats($conn, $userId);
            echo json_encode($result);
            break;
            
        case 'get_global_stats':
            // For admin only - add authentication check here
            $result = getGlobalStats($conn);
            echo json_encode($result);
            break;
            
        case 'save':
            $data = [
                'user_id' => intval($_POST['user_id'] ?? 0),
                'image_path' => $_POST['image_path'] ?? '',
                'predicted_class' => $_POST['predicted_class'] ?? '',
                'confidence' => floatval($_POST['confidence'] ?? 0),
                'top3_predictions' => $_POST['top3_predictions'] ?? '[]'
            ];
            
            if ($data['user_id'] <= 0) {
                echo json_encode([
                    'success' => false,
                    'message' => MLDetectionHistory::ERR_INVALID_USER_ID
                ]);
                exit;
            }
            
            $result = saveDetection($conn, $data);
            echo json_encode($result);
            break;
            
        default:
            echo json_encode([
                'success' => false,
                'message' => 'Invalid action'
            ]);
    }
    
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
}

$conn->close();

