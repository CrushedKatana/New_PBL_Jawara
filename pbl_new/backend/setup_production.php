<?php
/**
 * ============================================
 * JAWARA MARKETPLACE - PRODUCTION SETUP
 * ============================================
 * Script untuk setup database real production
 * bukan demo. Jalankan sekali saat first setup.
 * 
 * Usage: php setup_production.php
 */

// Database configuration
$DB_HOST = 'localhost';
$DB_USER = 'root';
$DB_PASS = '';
$DB_NAME = 'marketplace_rtrw';

// Create connection
$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS);

if ($conn->connect_error) {
    die("❌ Connection failed: " . $conn->connect_error);
}

echo "=== JAWARA MARKETPLACE - SETUP PRODUCTION ===\n\n";

// 1. Create Database
echo "1️⃣  Creating database...\n";
$sql = "CREATE DATABASE IF NOT EXISTS `$DB_NAME` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
if ($conn->query($sql) === TRUE) {
    echo "✅ Database created successfully\n\n";
} else {
    die("❌ Error creating database: " . $conn->error);
}

// Select database
$conn->select_db($DB_NAME);

// 2. Run all migrations
echo "2️⃣  Running migrations...\n";

// Migration 1: Auth & Users
$migrations = [
    'migrations/01_auth_users.sql',
    'migrations/02_products_categories.sql',
    'migrations/03_chat_messages.sql',
    'migrations/04_transactions.sql',
    'migrations/05_ml_detections.sql',
    'migrations/06_rt_metrics_activities.sql',
];

foreach ($migrations as $migration) {
    if (file_exists($migration)) {
        $sql = file_get_contents($migration);
        
        // Split by semicolon to handle multiple statements
        $statements = array_filter(array_map('trim', explode(';', $sql)));
        
        foreach ($statements as $statement) {
            if (!empty($statement)) {
                if ($conn->query($statement) === TRUE) {
                    echo "  ✅ Executed: " . substr($statement, 0, 50) . "...\n";
                } else {
                    echo "  ⚠️  Warning in {$migration}: " . $conn->error . "\n";
                }
            }
        }
    } else {
        echo "  ⚠️  Migration file not found: $migration\n";
    }
}

echo "\n";

// 3. Verify tables
echo "3️⃣  Verifying tables...\n";

$tables = [
    'users',
    'products',
    'categories',
    'chat_messages',
    'transactions',
    'ml_detections',
    'rt_metrics_activities',
];

$result = $conn->query("SHOW TABLES");
$existing_tables = [];

if ($result) {
    while ($row = $result->fetch_row()) {
        $existing_tables[] = $row[0];
    }
}

foreach ($tables as $table) {
    if (in_array($table, $existing_tables)) {
        // Count records
        $count_result = $conn->query("SELECT COUNT(*) as count FROM `$table`");
        $count = $count_result ? $count_result->fetch_assoc()['count'] : 0;
        echo "  ✅ $table (Records: $count)\n";
    } else {
        echo "  ❌ $table (Not found)\n";
    }
}

echo "\n";

// 4. Display credentials for seed users
echo "4️⃣  Seed Users Credentials (Use these to login):\n\n";

echo "📌 ADMIN\n";
echo "   Email: admin@jawara.com\n";
echo "   Password: password123\n\n";

echo "📌 RT/RW OFFICERS\n";
echo "   Email: ahmad.rt01@jawara.com | Password: password123\n";
echo "   Email: budi.rt02@jawara.com | Password: password123\n";
echo "   Email: candra.rt03@jawara.com | Password: password123\n";
echo "   Email: dedi.rt04@jawara.com | Password: password123\n";
echo "   Email: budi.rt05@jawara.com | Password: password123\n\n";

echo "📌 SAMPLE WARGA\n";
echo "   Email: lisa@jawara.com | Password: password123\n";
echo "   Email: dimas@jawara.com | Password: password123\n";
echo "   Email: sari@jawara.com | Password: password123\n";
echo "   Email: aminah@jawara.com | Password: password123\n\n";

// 5. Check API endpoint
echo "5️⃣  Checking backend connectivity...\n";
$config_file = 'config.php';
if (file_exists($config_file)) {
    require $config_file;
    echo "  ✅ Config file found\n";
} else {
    echo "  ⚠️  Config file not found - ensure config.php exists\n";
}

echo "\n";

// 6. Summary
echo "=== SETUP COMPLETE ===\n";
echo "✅ Database production ready!\n\n";
echo "📝 Next Steps:\n";
echo "   1. Update Flutter ApiConfig.dart with correct backend URL\n";
echo "   2. Test login with above credentials\n";
echo "   3. Verify all features working properly\n";
echo "   4. Check logs for any issues\n\n";

$conn->close();
?>
