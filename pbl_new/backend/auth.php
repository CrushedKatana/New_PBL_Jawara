<?php
require_once 'config.php';

$conn = getDbConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'POST':
        $action = $_GET['action'] ?? 'login';
        if ($action === 'register') {
            register($conn);
        } else {
            login($conn);
        }
        break;
    case 'GET':
        getUserProfile($conn);
        break;
    case 'PUT':
        updateUserProfile($conn);
        break;
    default:
        sendJsonResponse(['error' => 'Method not allowed'], 405);
}

function register($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $id = uniqid('user_');
    $name = $conn->real_escape_string($data['name']);
    $email = $conn->real_escape_string($data['email']);
    $password = password_hash($data['password'], PASSWORD_DEFAULT);
    $phone = $conn->real_escape_string($data['phone'] ?? '');
    $address = $conn->real_escape_string($data['address'] ?? '');
    $rt = $conn->real_escape_string($data['rt'] ?? '');
    $rw = $conn->real_escape_string($data['rw'] ?? '');
    
    // Check if email already exists
    $checkSql = "SELECT id FROM users WHERE email='$email'";
    $result = $conn->query($checkSql);
    
    if ($result->num_rows > 0) {
        sendJsonResponse(['success' => false, 'error' => 'Email already registered'], 400);
    }
    
    $sql = "INSERT INTO users (id, name, email, password, phone, address, rt, rw) 
            VALUES ('$id', '$name', '$email', '$password', '$phone', '$address', '$rt', '$rw')";
    
    if ($conn->query($sql)) {
        $user = [
            'id' => $id,
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'address' => $address,
            'rt' => $rt,
            'rw' => $rw,
            'user_type' => 'warga'
        ];
        sendJsonResponse(['success' => true, 'data' => $user], 201);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error], 500);
    }
}

function login($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $email = $conn->real_escape_string($data['email']);
    $password = $data['password'];
    
    $sql = "SELECT * FROM users WHERE email='$email'";
    $result = $conn->query($sql);
    
    if ($result->num_rows === 0) {
        sendJsonResponse(['success' => false, 'error' => 'User not found'], 404);
    }
    
    $user = $result->fetch_assoc();
    
    if (!password_verify($password, $user['password'])) {
        sendJsonResponse(['success' => false, 'error' => 'Invalid password'], 401);
    }
    
    unset($user['password']); // Don't send password back
    sendJsonResponse(['success' => true, 'data' => $user]);
}

function getUserProfile($conn) {
    $userId = $_GET['user_id'] ?? null;
    
    if (!$userId) {
        sendJsonResponse(['success' => false, 'error' => 'User ID required'], 400);
    }
    
    $userId = $conn->real_escape_string($userId);
    $sql = "SELECT id, name, email, phone, address, rt, rw, user_type, photo_url, created_at FROM users WHERE id='$userId'";
    $result = $conn->query($sql);
    
    if ($result->num_rows === 0) {
        sendJsonResponse(['success' => false, 'error' => 'User not found'], 404);
    }
    
    $user = $result->fetch_assoc();
    sendJsonResponse(['success' => true, 'data' => $user]);
}

function updateUserProfile($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $id = $conn->real_escape_string($data['id']);
    $name = $conn->real_escape_string($data['name']);
    $phone = $conn->real_escape_string($data['phone'] ?? '');
    $address = $conn->real_escape_string($data['address'] ?? '');
    $rt = $conn->real_escape_string($data['rt'] ?? '');
    $rw = $conn->real_escape_string($data['rw'] ?? '');
    $photoUrl = $conn->real_escape_string($data['photo_url'] ?? '');
    
    $sql = "UPDATE users 
            SET name='$name', phone='$phone', address='$address', rt='$rt', rw='$rw', photo_url='$photoUrl' 
            WHERE id='$id'";
    
    if ($conn->query($sql)) {
        sendJsonResponse(['success' => true]);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error], 500);
    }
}

$conn->close();
?>
