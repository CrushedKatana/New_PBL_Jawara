<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getActivities();
        break;
    case 'POST':
        addActivity();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        break;
}

function getActivities() {
    global $conn;
    
    $rt = isset($_GET['rt']) ? $_GET['rt'] : null;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;
    
    try {
        if ($rt) {
            // Get activities untuk RT tertentu
            $stmt = $conn->prepare("
                SELECT a.*, u.nama as user_name 
                FROM activities a
                LEFT JOIN users u ON a.user_id = u.user_id
                WHERE a.rt = ?
                ORDER BY a.activity_date DESC
                LIMIT ? OFFSET ?
            ");
            $stmt->bind_param("sii", $rt, $limit, $offset);
        } else {
            // Get all activities
            $stmt = $conn->prepare("
                SELECT a.*, u.nama as user_name 
                FROM activities a
                LEFT JOIN users u ON a.user_id = u.user_id
                ORDER BY a.activity_date DESC
                LIMIT ? OFFSET ?
            ");
            $stmt->bind_param("ii", $limit, $offset);
        }
        
        $stmt->execute();
        $result = $stmt->get_result();
        $activities = [];
        
        while ($row = $result->fetch_assoc()) {
            $activities[] = [
                'activity_id' => $row['activity_id'],
                'user_id' => $row['user_id'],
                'user_name' => $row['user_name'],
                'rt' => $row['rt'],
                'activity_type' => $row['activity_type'],
                'description' => $row['description'],
                'activity_date' => $row['activity_date']
            ];
        }
        
        echo json_encode([
            'success' => true,
            'data' => $activities,
            'count' => count($activities)
        ]);
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

function addActivity() {
    global $conn;
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    $user_id = $input['user_id'] ?? null;
    $rt = $input['rt'] ?? null;
    $activity_type = $input['activity_type'] ?? null;
    $description = $input['description'] ?? null;
    
    if (!$user_id || !$rt || !$activity_type || !$description) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: user_id, rt, activity_type, description'
        ]);
        return;
    }
    
    try {
        $stmt = $conn->prepare("
            INSERT INTO activities (user_id, rt, activity_type, description, activity_date)
            VALUES (?, ?, ?, ?, NOW())
        ");
        $stmt->bind_param("ssss", $user_id, $rt, $activity_type, $description);
        
        if ($stmt->execute()) {
            $activity_id = $conn->insert_id;
            
            // Get the newly created activity
            $getStmt = $conn->prepare("
                SELECT a.*, u.nama as user_name 
                FROM activities a
                LEFT JOIN users u ON a.user_id = u.user_id
                WHERE a.activity_id = ?
            ");
            $getStmt->bind_param("i", $activity_id);
            $getStmt->execute();
            $result = $getStmt->get_result();
            $activity = $result->fetch_assoc();
            
            echo json_encode([
                'success' => true,
                'message' => 'Activity logged successfully',
                'data' => [
                    'activity_id' => $activity['activity_id'],
                    'user_id' => $activity['user_id'],
                    'user_name' => $activity['user_name'],
                    'rt' => $activity['rt'],
                    'activity_type' => $activity['activity_type'],
                    'description' => $activity['description'],
                    'activity_date' => $activity['activity_date']
                ]
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to log activity'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

$conn->close();
?>