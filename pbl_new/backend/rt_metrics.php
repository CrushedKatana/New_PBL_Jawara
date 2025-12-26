<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        getRTMetrics();
        break;
    default:
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
        break;
}

function getRTMetrics() {
    global $conn;
    
    $rt = isset($_GET['rt']) ? $_GET['rt'] : null;
    $month = isset($_GET['month']) ? (int)$_GET['month'] : date('n');
    $year = isset($_GET['year']) ? (int)$_GET['year'] : date('Y');
    
    try {
        if ($rt) {
            // Get metrics untuk RT tertentu
            $stmt = $conn->prepare("
                SELECT * FROM rt_metrics 
                WHERE rt = ? AND month = ? AND year = ?
            ");
            $stmt->bind_param("sii", $rt, $month, $year);
            $stmt->execute();
            $result = $stmt->get_result();
            $metrics = $result->fetch_assoc();
            
            if (!$metrics) {
                // Calculate metrics jika belum ada di table
                $metrics = calculateRTMetrics($rt, $month, $year);
            }
            
            echo json_encode([
                'success' => true,
                'data' => $metrics
            ]);
        } else {
            // Get all RT metrics
            $stmt = $conn->prepare("
                SELECT * FROM rt_metrics 
                WHERE month = ? AND year = ?
                ORDER BY rt ASC
            ");
            $stmt->bind_param("ii", $month, $year);
            $stmt->execute();
            $result = $stmt->get_result();
            $allMetrics = [];
            
            while ($row = $result->fetch_assoc()) {
                $allMetrics[] = $row;
            }
            
            echo json_encode([
                'success' => true,
                'data' => $allMetrics
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
}

function calculateRTMetrics($rt, $month, $year) {
    global $conn;
    
    // Hitung total warga
    $stmt = $conn->prepare("SELECT COUNT(*) as total FROM users WHERE rt = ? AND role = 'warga'");
    $stmt->bind_param("s", $rt);
    $stmt->execute();
    $totalWarga = $stmt->get_result()->fetch_assoc()['total'];
    
    // Hitung total produk yang approved
    $stmt = $conn->prepare("
        SELECT COUNT(*) as total FROM products p
        JOIN users u ON p.user_id = u.user_id
        WHERE u.rt = ? AND p.status = 'approved'
    ");
    $stmt->bind_param("s", $rt);
    $stmt->execute();
    $totalProduk = $stmt->get_result()->fetch_assoc()['total'];
    
    // Hitung total transaksi bulan ini
    $stmt = $conn->prepare("
        SELECT COUNT(*) as total FROM transactions t
        JOIN users u ON t.buyer_id = u.user_id
        WHERE u.rt = ? AND MONTH(t.transaction_date) = ? AND YEAR(t.transaction_date) = ?
    ");
    $stmt->bind_param("sii", $rt, $month, $year);
    $stmt->execute();
    $totalTransaksi = $stmt->get_result()->fetch_assoc()['total'];
    
    // Hitung total pendapatan bulan ini
    $stmt = $conn->prepare("
        SELECT COALESCE(SUM(t.total_price), 0) as total FROM transactions t
        JOIN users u ON t.buyer_id = u.user_id
        WHERE u.rt = ? AND MONTH(t.transaction_date) = ? AND YEAR(t.transaction_date) = ? AND t.status = 'completed'
    ");
    $stmt->bind_param("sii", $rt, $month, $year);
    $stmt->execute();
    $totalPendapatan = $stmt->get_result()->fetch_assoc()['total'];
    
    // Hitung produk pending approval
    $stmt = $conn->prepare("
        SELECT COUNT(*) as total FROM products p
        JOIN users u ON p.user_id = u.user_id
        WHERE u.rt = ? AND p.status = 'pending'
    ");
    $stmt->bind_param("s", $rt);
    $stmt->execute();
    $pendingApproval = $stmt->get_result()->fetch_assoc()['total'];
    
    // Save ke database
    $insertStmt = $conn->prepare("
        INSERT INTO rt_metrics (rt, month, year, total_warga, total_produk, total_transaksi, total_pendapatan, pending_approval)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            total_warga = VALUES(total_warga),
            total_produk = VALUES(total_produk),
            total_transaksi = VALUES(total_transaksi),
            total_pendapatan = VALUES(total_pendapatan),
            pending_approval = VALUES(pending_approval)
    ");
    $insertStmt->bind_param("siiiiidi", $rt, $month, $year, $totalWarga, $totalProduk, $totalTransaksi, $totalPendapatan, $pendingApproval);
    $insertStmt->execute();
    
    return [
        'rt' => $rt,
        'month' => $month,
        'year' => $year,
        'total_warga' => $totalWarga,
        'total_produk' => $totalProduk,
        'total_transaksi' => $totalTransaksi,
        'total_pendapatan' => (float)$totalPendapatan,
        'pending_approval' => $pendingApproval,
        'created_at' => date('Y-m-d H:i:s')
    ];
}

$conn->close();
?>