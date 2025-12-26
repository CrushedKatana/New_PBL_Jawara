<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getTransactions();
        break;
    case 'POST':
        createTransaction();
        break;
    case 'PUT':
        updateTransactionStatus();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        break;
}

function getTransactions() {
    global $conn;
    
    $user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
    $type = isset($_GET['type']) ? $_GET['type'] : 'all'; // 'buyer', 'seller', 'all'
    $status = isset($_GET['status']) ? $_GET['status'] : null;
    
    try {
        $query = "
            SELECT t.*, 
                   p.nama as product_name, 
                   p.harga as product_price,
                   p.image_url as product_image,
                   buyer.nama as buyer_name,
                   buyer.email as buyer_email,
                   seller.nama as seller_name,
                   seller.email as seller_email
            FROM transactions t
            JOIN products p ON t.product_id = p.product_id
            JOIN users buyer ON t.buyer_id = buyer.user_id
            JOIN users seller ON t.seller_id = seller.user_id
            WHERE 1=1
        ";
        
        $params = [];
        $types = "";
        
        if ($user_id) {
            if ($type === 'buyer') {
                $query .= " AND t.buyer_id = ?";
                $params[] = $user_id;
                $types .= "s";
            } elseif ($type === 'seller') {
                $query .= " AND t.seller_id = ?";
                $params[] = $user_id;
                $types .= "s";
            } else {
                $query .= " AND (t.buyer_id = ? OR t.seller_id = ?)";
                $params[] = $user_id;
                $params[] = $user_id;
                $types .= "ss";
            }
        }
        
        if ($status) {
            $query .= " AND t.status = ?";
            $params[] = $status;
            $types .= "s";
        }
        
        $query .= " ORDER BY t.transaction_date DESC";
        
        $stmt = $conn->prepare($query);
        
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        
        $stmt->execute();
        $result = $stmt->get_result();
        $transactions = [];
        
        while ($row = $result->fetch_assoc()) {
            $transactions[] = [
                'transaction_id' => $row['transaction_id'],
                'product_id' => $row['product_id'],
                'product_name' => $row['product_name'],
                'product_price' => (float)$row['product_price'],
                'product_image' => $row['product_image'],
                'buyer_id' => $row['buyer_id'],
                'buyer_name' => $row['buyer_name'],
                'buyer_email' => $row['buyer_email'],
                'seller_id' => $row['seller_id'],
                'seller_name' => $row['seller_name'],
                'seller_email' => $row['seller_email'],
                'quantity' => (int)$row['quantity'],
                'total_price' => (float)$row['total_price'],
                'status' => $row['status'],
                'transaction_date' => $row['transaction_date']
            ];
        }
        
        echo json_encode([
            'success' => true,
            'data' => $transactions,
            'count' => count($transactions)
        ]);
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

function createTransaction() {
    global $conn;
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    $product_id = $input['product_id'] ?? null;
    $buyer_id = $input['buyer_id'] ?? null;
    $seller_id = $input['seller_id'] ?? null;
    $quantity = $input['quantity'] ?? 1;
    $total_price = $input['total_price'] ?? null;
    
    if (!$product_id || !$buyer_id || !$seller_id || !$total_price) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: product_id, buyer_id, seller_id, total_price'
        ]);
        return;
    }
    
    // Validate product exists
    $checkStmt = $conn->prepare("SELECT product_id FROM products WHERE product_id = ? AND status = 'approved'");
    $checkStmt->bind_param("s", $product_id);
    $checkStmt->execute();
    if ($checkStmt->get_result()->num_rows === 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Product not found or not approved'
        ]);
        return;
    }
    
    try {
        $status = 'pending';
        $stmt = $conn->prepare("
            INSERT INTO transactions (product_id, buyer_id, seller_id, quantity, total_price, status, transaction_date)
            VALUES (?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->bind_param("sssids", $product_id, $buyer_id, $seller_id, $quantity, $total_price, $status);
        
        if ($stmt->execute()) {
            $transaction_id = $conn->insert_id;
            
            // Get the newly created transaction
            $getStmt = $conn->prepare("
                SELECT t.*, 
                       p.nama as product_name, 
                       buyer.nama as buyer_name,
                       seller.nama as seller_name
                FROM transactions t
                JOIN products p ON t.product_id = p.product_id
                JOIN users buyer ON t.buyer_id = buyer.user_id
                JOIN users seller ON t.seller_id = seller.user_id
                WHERE t.transaction_id = ?
            ");
            $getStmt->bind_param("i", $transaction_id);
            $getStmt->execute();
            $result = $getStmt->get_result();
            $transaction = $result->fetch_assoc();
            
            echo json_encode([
                'success' => true,
                'message' => 'Transaction created successfully',
                'data' => [
                    'transaction_id' => $transaction['transaction_id'],
                    'product_id' => $transaction['product_id'],
                    'product_name' => $transaction['product_name'],
                    'buyer_id' => $transaction['buyer_id'],
                    'buyer_name' => $transaction['buyer_name'],
                    'seller_id' => $transaction['seller_id'],
                    'seller_name' => $transaction['seller_name'],
                    'quantity' => (int)$transaction['quantity'],
                    'total_price' => (float)$transaction['total_price'],
                    'status' => $transaction['status'],
                    'transaction_date' => $transaction['transaction_date']
                ]
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to create transaction'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

function updateTransactionStatus() {
    global $conn;
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    $transaction_id = $input['transaction_id'] ?? null;
    $status = $input['status'] ?? null;
    
    if (!$transaction_id || !$status) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields: transaction_id, status'
        ]);
        return;
    }
    
    $valid_statuses = ['pending', 'processing', 'completed', 'cancelled'];
    if (!in_array($status, $valid_statuses)) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid status. Must be one of: ' . implode(', ', $valid_statuses)
        ]);
        return;
    }
    
    try {
        $stmt = $conn->prepare("
            UPDATE transactions 
            SET status = ? 
            WHERE transaction_id = ?
        ");
        $stmt->bind_param("si", $status, $transaction_id);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                // Get updated transaction
                $getStmt = $conn->prepare("
                    SELECT t.*, 
                           p.nama as product_name, 
                           buyer.nama as buyer_name,
                           seller.nama as seller_name
                    FROM transactions t
                    JOIN products p ON t.product_id = p.product_id
                    JOIN users buyer ON t.buyer_id = buyer.user_id
                    JOIN users seller ON t.seller_id = seller.user_id
                    WHERE t.transaction_id = ?
                ");
                $getStmt->bind_param("i", $transaction_id);
                $getStmt->execute();
                $result = $getStmt->get_result();
                $transaction = $result->fetch_assoc();
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Transaction status updated successfully',
                    'data' => [
                        'transaction_id' => $transaction['transaction_id'],
                        'product_id' => $transaction['product_id'],
                        'product_name' => $transaction['product_name'],
                        'buyer_id' => $transaction['buyer_id'],
                        'buyer_name' => $transaction['buyer_name'],
                        'seller_id' => $transaction['seller_id'],
                        'seller_name' => $transaction['seller_name'],
                        'quantity' => (int)$transaction['quantity'],
                        'total_price' => (float)$transaction['total_price'],
                        'status' => $transaction['status'],
                        'transaction_date' => $transaction['transaction_date']
                    ]
                ]);
            } else {
                echo json_encode([
                    'success' => false,
                    'message' => 'Transaction not found'
                ]);
            }
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update transaction status'
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