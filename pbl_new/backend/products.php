<?php
require_once 'config.php';

$conn = getDbConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getProducts($conn);
        break;
    case 'POST':
        addProduct($conn);
        break;
    case 'PUT':
        updateProduct($conn);
        break;
    case 'DELETE':
        deleteProduct($conn);
        break;
    default:
        sendJsonResponse(['error' => 'Method not allowed'], 405);
}

function getProducts($conn) {
    $sellerId = $_GET['seller_id'] ?? null;
    $categoryId = $_GET['category_id'] ?? null;
    $search = $_GET['search'] ?? null;
    
    $sql = "SELECT p.*, u.name as seller_name, u.phone as seller_phone, c.name as category_name 
            FROM products p 
            LEFT JOIN users u ON p.seller_id = u.id 
            LEFT JOIN categories c ON p.category_id = c.id 
            WHERE p.is_active = TRUE";
    
    if ($sellerId) {
        $sql .= " AND p.seller_id = '" . $conn->real_escape_string($sellerId) . "'";
    }
    
    if ($categoryId) {
        $sql .= " AND p.category_id = '" . $conn->real_escape_string($categoryId) . "'";
    }
    
    if ($search) {
        $search = $conn->real_escape_string($search);
        $sql .= " AND (p.title LIKE '%$search%' OR p.description LIKE '%$search%')";
    }
    
    $sql .= " ORDER BY p.created_at DESC";
    
    $result = $conn->query($sql);
    $products = [];
    
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }
    }
    
    sendJsonResponse(['success' => true, 'data' => $products]);
}

function addProduct($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $id = uniqid('prod_');
    $title = $conn->real_escape_string($data['title']);
    $description = $conn->real_escape_string($data['description'] ?? '');
    $price = floatval($data['price']);
    $categoryId = $conn->real_escape_string($data['category_id'] ?? '');
    $sellerId = $conn->real_escape_string($data['seller_id']);
    $imageUrl = $conn->real_escape_string($data['image_url'] ?? '');
    $location = $conn->real_escape_string($data['location'] ?? '');
    
    $sql = "INSERT INTO products (id, title, description, price, category_id, seller_id, image_url, location) 
            VALUES ('$id', '$title', '$description', $price, '$categoryId', '$sellerId', '$imageUrl', '$location')";
    
    if ($conn->query($sql)) {
        sendJsonResponse(['success' => true, 'data' => ['id' => $id]], 201);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error], 500);
    }
}

function updateProduct($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $id = $conn->real_escape_string($data['id']);
    $title = $conn->real_escape_string($data['title']);
    $description = $conn->real_escape_string($data['description'] ?? '');
    $price = floatval($data['price']);
    $categoryId = $conn->real_escape_string($data['category_id'] ?? '');
    $imageUrl = $conn->real_escape_string($data['image_url'] ?? '');
    $location = $conn->real_escape_string($data['location'] ?? '');
    
    $sql = "UPDATE products 
            SET title='$title', description='$description', price=$price, 
                category_id='$categoryId', image_url='$imageUrl', location='$location' 
            WHERE id='$id'";
    
    if ($conn->query($sql)) {
        sendJsonResponse(['success' => true]);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error], 500);
    }
}

function deleteProduct($conn) {
    $data = json_decode(file_get_contents('php://input'), true);
    $id = $conn->real_escape_string($data['id']);
    
    $sql = "UPDATE products SET is_active = FALSE WHERE id='$id'";
    
    if ($conn->query($sql)) {
        sendJsonResponse(['success' => true]);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error], 500);
    }
}

$conn->close();
?>
