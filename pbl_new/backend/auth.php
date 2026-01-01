<?php
require_once 'config.php';

// Global error & exception handler supaya tidak ada output HTML (<br /><b>...) ke client
set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    // Jika error ini disupress dengan @, biarkan handler default
    if (!(error_reporting() & $errno)) {
        return false;
    }

    sendJsonResponse([
        'success' => false,
        'error' => 'Internal server error: ' . $errstr,
        'code' => $errno,
    ], 500);
});

set_exception_handler(function ($e) {
    sendJsonResponse([
        'success' => false,
        'error' => 'Unhandled exception: ' . $e->getMessage(),
    ], 500);
});

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
        sendJsonResponse(['success' => false, 'error' => 'Method not allowed'], 405);
}

// Helper untuk membaca dan memvalidasi input JSON
function getJsonInput() {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);

    if (json_last_error() !== JSON_ERROR_NONE) {
        sendJsonResponse([
            'success' => false,
            'error' => 'Invalid JSON input: ' . json_last_error_msg(),
        ], 400);
    }

    if (!is_array($data)) {
        sendJsonResponse([
            'success' => false,
            'error' => 'Invalid request body',
        ], 400);
    }

    return $data;
}

function register($conn) {
    $data = getJsonInput();

    // Validasi field wajib
    if (empty($data['name']) || empty($data['email']) || empty($data['password'])) {
        sendJsonResponse([
            'success' => false,
            'error' => 'Name, email, dan password wajib diisi',
        ], 400);
    }

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
    $data = getJsonInput();

    if (empty($data['email']) || empty($data['password'])) {
        sendJsonResponse([
            'success' => false,
            'error' => 'Email dan password wajib diisi',
        ], 400);
    }

    $email = $conn->real_escape_string($data['email']);
    $password = $data['password'];
    
    $sql = "SELECT * FROM users WHERE email='$email'";
    $result = $conn->query($sql);
    
    if ($result->num_rows === 0) {
        $conn->close();
        sendJsonResponse(['success' => false, 'error' => 'User not found'], 404);
    }
    
    $user = $result->fetch_assoc();
    
    if (!password_verify($password, $user['password'])) {
        $conn->close();
        sendJsonResponse(['success' => false, 'error' => 'Invalid password'], 401);
    }
    
    unset($user['password']); // Don't send password back
    $conn->close();
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
    $data = getJsonInput();

    if (empty($data['id']) || empty($data['name'])) {
        sendJsonResponse([
            'success' => false,
            'error' => 'User ID dan name wajib diisi',
        ], 400);
    }

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
