-- ============================================
-- Database untuk Marketplace RT/RW Jawara
-- Gunakan di phpMyAdmin XAMPP/Laragon
-- ============================================

DROP DATABASE IF EXISTS marketplace_rtrw;
CREATE DATABASE marketplace_rtrw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE marketplace_rtrw;

-- ============================================
-- Tabel Users (Warga, RT/RW, Admin)
-- ============================================
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    rt VARCHAR(10),
    rw VARCHAR(10),
    user_type ENUM('warga', 'admin', 'rt') DEFAULT 'warga',
    verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
    photo_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    joined_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_type (user_type),
    INDEX idx_rt (rt),
    INDEX idx_verification (verification_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel Categories
-- ============================================
CREATE TABLE categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel Products
-- ============================================
CREATE TABLE products (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) NOT NULL,
    category_id VARCHAR(50),
    seller_id VARCHAR(50) NOT NULL,
    image_url TEXT,
    location VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    approval_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    approved_by VARCHAR(50),
    approved_at TIMESTAMP NULL,
    rejection_reason TEXT,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_seller (seller_id),
    INDEX idx_category (category_id),
    INDEX idx_approval (approval_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel Transactions
-- ============================================
CREATE TABLE transactions (
    id VARCHAR(50) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    buyer_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_buyer (buyer_id),
    INDEX idx_seller (seller_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel Messages/Chat
-- ============================================
CREATE TABLE messages (
    id VARCHAR(50) PRIMARY KEY,
    sender_id VARCHAR(50) NOT NULL,
    receiver_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel ML Detections (PCVK Model)
-- ============================================
CREATE TABLE ml_detections (
    id VARCHAR(50) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    detected_category VARCHAR(100),
    confidence DECIMAL(5, 2),
    model_version VARCHAR(20),
    detection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_category (detected_category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel RT Dashboard Metrics
-- ============================================
CREATE TABLE rt_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rt VARCHAR(10) NOT NULL,
    metric_type ENUM('warga', 'produk', 'transaksi') NOT NULL,
    metric_value INT DEFAULT 0,
    month INT,
    year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rt (rt),
    INDEX idx_period (year, month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel Activities/Logs
-- ============================================
CREATE TABLE activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    activity_type VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DATA SEEDING - Categories
-- ============================================
INSERT INTO categories (id, name, icon, color) VALUES
('cat1', 'T-Shirt', 'checkroom', '#2196F3'),
('cat2', 'Topi', 'sports_baseball', '#E91E63'),
('cat3', 'Kemeja', 'person', '#4CAF50'),
('cat4', 'Sepatu', 'sports_soccer', '#FF9800');

-- ============================================
-- DATA SEEDING - Users
-- ============================================
-- Password untuk semua user demo: "password123"
-- Hash: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- Catatan: hash di bawah ini adalah hash contoh dan bisa berbeda.
-- Jika setelah import login masih "Invalid password", jalankan:
--   POST http://localhost/jawara/backend/reset_demo_passwords.php
-- untuk reset semua password user menjadi "password123".

-- Admin
INSERT INTO users (id, name, email, password, phone, address, rt, rw, user_type, verification_status, is_active, joined_date) VALUES
('admin001', 'Budi Santoso', 'admin@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567890', 'Kantor Kelurahan Maju Jaya', '', '', 'admin', 'verified', TRUE, '2023-11-01');

-- RT Officers
INSERT INTO users (id, name, email, password, phone, address, rt, rw, user_type, verification_status, is_active, joined_date) VALUES
('rt001', 'Pak Ahmad RT 01', 'ahmad.rt01@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567801', 'Jl. Merdeka No. 1', '01', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt002', 'Pak Budi RT 02', 'budi.rt02@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567802', 'Jl. Merdeka No. 2', '02', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt003', 'Pak Candra RT 03', 'candra.rt03@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567803', 'Jl. Merdeka No. 3', '03', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt004', 'Pak Dedi RT 04', 'dedi.rt04@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567804', 'Jl. Merdeka No. 4', '04', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt005', 'Pak Budi RT 05', 'budi.rt05@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567805', 'Jl. Merdeka No. 5', '05', '05', 'rt', 'verified', TRUE, '2023-12-01');

-- Warga RT 01
INSERT INTO users (id, name, email, password, phone, address, rt, rw, user_type, verification_status, is_active, joined_date) VALUES
('warga001', 'Toko Sepatu Jaya', 'sepatu@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234561001', 'Jl. Sudirman No. 10', '01', '05', 'warga', 'verified', FALSE, '2024-01-15'),
('warga002', 'Ibu Lisa', 'lisa@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234561002', 'Jl. Sudirman No. 12', '01', '05', 'warga', 'verified', TRUE, '2024-02-01'),
('warga003', 'Pak Rudi', 'rudi@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234561003', 'Jl. Sudirman No. 14', '01', '05', 'warga', 'verified', TRUE, '2024-02-10'),

-- Warga RT 02
('warga004', 'Dimas Pratama', 'dimas@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234562001', 'Jl. Gatot Subroto No. 20', '02', '05', 'warga', 'verified', TRUE, '2024-02-15'),
('warga005', 'Ibu Ratna', 'ratna@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234562002', 'Jl. Gatot Subroto No. 22', '02', '05', 'warga', 'verified', TRUE, '2024-03-01'),

-- Warga RT 03
('warga006', 'Sari Wulandari', 'sari@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234563001', 'Jl. Ahmad Yani No. 30', '03', '05', 'warga', 'verified', TRUE, '2024-03-15'),
('warga007', 'Pak Eko', 'eko@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234563002', 'Jl. Ahmad Yani No. 32', '03', '05', 'warga', 'pending', TRUE, '2024-03-20'),

-- Warga RT 04
('warga008', 'Ibu Siti Aminah', 'siti@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234564001', 'Jl. Diponegoro No. 40', '04', '05', 'warga', 'verified', TRUE, '2024-01-20'),
('warga009', 'Pak Agus', 'agus@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234564002', 'Jl. Diponegoro No. 42', '04', '05', 'warga', 'verified', TRUE, '2024-02-05'),

-- Warga RT 05
('warga010', 'Ibu Siti Aminah', 'aminah@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234565001', 'Jl. Veteran No. 50', '05', '05', 'warga', 'verified', TRUE, '2024-01-10'),
('warga011', 'Toko Elektronik Maju', 'elektronik@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234565002', 'Jl. Veteran No. 52', '05', '05', 'warga', 'verified', TRUE, '2024-01-25'),
('warga012', 'Pak Herman', 'herman@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234565003', 'Jl. Veteran No. 54', '05', '05', 'warga', 'pending', TRUE, '2024-03-25');

-- ============================================
-- DATA SEEDING - Products
-- ============================================
INSERT INTO products (id, title, description, price, category_id, seller_id, location, is_active, approval_status, approved_by, view_count) VALUES
-- Approved Products
('prod001', 'T-Shirt Polos Hitam', 'Kaos polos katun combed 30s, nyaman dipakai', 75000, 'cat1', 'warga001', 'Jl. Sudirman No. 10, RT 01', TRUE, 'approved', 'rt001', 245),
('prod002', 'T-Shirt Band Supreme', 'Kaos band original import, size L', 150000, 'cat1', 'warga011', 'Jl. Veteran No. 52, RT 05', TRUE, 'approved', 'rt005', 189),
('prod003', 'Topi Baseball NY', 'Topi baseball original New York Yankees', 120000, 'cat2', 'warga003', 'Jl. Sudirman No. 14, RT 01', TRUE, 'approved', 'rt001', 432),
('prod004', 'Topi Snapback Hitam', 'Topi snapback polos warna hitam premium', 85000, 'cat2', 'warga005', 'Jl. Gatot Subroto No. 22, RT 02', TRUE, 'approved', 'rt002', 167),
('prod005', 'Kemeja Flanel Kotak', 'Kemeja flanel motif kotak merah hitam', 95000, 'cat3', 'warga006', 'Jl. Ahmad Yani No. 30, RT 03', TRUE, 'approved', 'rt003', 203),
('prod006', 'Kemeja Formal Putih', 'Kemeja putih lengan panjang untuk kantor', 125000, 'cat3', 'warga010', 'Jl. Veteran No. 50, RT 05', TRUE, 'approved', 'rt005', 156),
('prod007', 'Sepatu Nike Air Max', 'Sepatu olahraga original, size 42, warna hitam', 850000, 'cat4', 'warga004', 'Jl. Gatot Subroto No. 20, RT 02', TRUE, 'approved', 'rt002', 98),
('prod008', 'Sepatu Converse All Star', 'Sepatu Converse high top warna merah, size 40', 650000, 'cat4', 'warga009', 'Jl. Diponegoro No. 42, RT 04', TRUE, 'approved', 'rt004', 134),

-- Pending Approval
('prod009', 'T-Shirt Oversize Putih', 'Kaos oversize premium cotton, trendy', 110000, 'cat1', 'warga007', 'Jl. Ahmad Yani No. 32, RT 03', TRUE, 'pending', NULL, 0),
('prod010', 'Topi Bucket Hat Cream', 'Topi bucket hat warna cream, cocok untuk jalan', 90000, 'cat2', 'warga012', 'Jl. Veteran No. 54, RT 05', TRUE, 'pending', NULL, 0),
('prod011', 'Kemeja Batik Slim Fit', 'Kemeja batik modern slim fit size M', 180000, 'cat3', 'warga002', 'Jl. Sudirman No. 12, RT 01', TRUE, 'pending', NULL, 0);

-- ============================================
-- DATA SEEDING - Transactions
-- ============================================
INSERT INTO transactions (id, product_id, buyer_id, seller_id, amount, status, payment_method) VALUES
('trx001', 'prod001', 'warga002', 'warga001', 75000, 'completed', 'Cash'),
('trx002', 'prod003', 'warga004', 'warga003', 120000, 'completed', 'Transfer Bank'),
('trx003', 'prod007', 'warga006', 'warga004', 850000, 'completed', 'Cash'),
('trx004', 'prod006', 'warga009', 'warga010', 125000, 'pending', 'Transfer Bank'),
('trx005', 'prod002', 'warga008', 'warga011', 150000, 'completed', 'Transfer Bank');

-- ============================================
-- DATA SEEDING - Messages
-- ============================================
INSERT INTO messages (id, sender_id, receiver_id, product_id, message, is_read, created_at) VALUES
('msg001', 'warga002', 'warga001', 'prod001', 'Kualitas bahannya bagus ga?', TRUE, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('msg002', 'warga001', 'warga002', 'prod001', 'Bagus kak, katun combed premium', TRUE, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('msg003', 'warga002', 'warga001', 'prod001', 'Oke saya ambil ya', TRUE, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('msg004', 'warga004', 'warga003', 'prod003', 'Topinya masih ada ga?', TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('msg005', 'warga003', 'warga004', 'prod003', 'Masih ada kak, original NY', TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('msg006', 'warga006', 'warga004', 'prod007', 'Boleh COD?', FALSE, DATE_SUB(NOW(), INTERVAL 30 MINUTE));

-- ============================================
-- DATA SEEDING - ML Detections
-- ============================================
INSERT INTO ml_detections (id, product_id, detected_category, confidence, model_version, detection_time) VALUES
('det001', 'prod001', 'T-Shirt', 96.5, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 2 MINUTE)),
('det002', 'prod002', 'T-Shirt', 94.2, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
('det003', 'prod003', 'Topi', 98.1, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 10 MINUTE)),
('det004', 'prod005', 'Kemeja', 92.7, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 15 MINUTE)),
('det005', 'prod007', 'Sepatu', 95.3, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 20 MINUTE));

-- ============================================
-- DATA SEEDING - RT Metrics
-- ============================================
INSERT INTO rt_metrics (rt, metric_type, metric_value, month, year) VALUES
-- RT 01
('01', 'warga', 156, 11, 2025),
('01', 'produk', 89, 11, 2025),
('01', 'transaksi', 342, 11, 2025),
-- RT 02
('02', 'warga', 134, 11, 2025),
('02', 'produk', 67, 11, 2025),
('02', 'transaksi', 278, 11, 2025),
-- RT 03
('03', 'warga', 142, 11, 2025),
('03', 'produk', 72, 11, 2025),
('03', 'transaksi', 301, 11, 2025),
-- RT 04
('04', 'warga', 128, 11, 2025),
('04', 'produk', 54, 11, 2025),
('04', 'transaksi', 245, 11, 2025),
-- RT 05
('05', 'warga', 142, 11, 2025),
('05', 'produk', 67, 11, 2025),
('05', 'transaksi', 234, 11, 2025);

-- ============================================
-- DATA SEEDING - Activities
-- ============================================
INSERT INTO activities (user_id, activity_type, description, created_at) VALUES
('warga002', 'product_view', 'Melihat produk Nasi Goreng Spesial', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('warga004', 'product_purchase', 'Membeli Raket Badminton Yonex', DATE_SUB(NOW(), INTERVAL 5 HOUR)),
('rt005', 'product_approval', 'Menyetujui produk Laptop Asus ROG', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('warga007', 'user_register', 'Mendaftar sebagai warga baru RT 03', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('rt003', 'product_approval', 'Menyetujui produk Harry Potter Complete Set', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- ============================================
-- END OF DATABASE MIGRATION
-- ============================================
-- Total Tables: 8
-- Total Records: 
--   - Users: 17 (1 admin, 5 RT, 12 warga)
--   - Categories: 4 (T-Shirt, Topi, Kemeja, Sepatu)
--   - Products: 11 (8 approved, 3 pending)
--   - Transactions: 5
--   - Messages: 6
--   - ML Detections: 5
--   - RT Metrics: 15
--   - Activities: 5
-- 
-- CARA IMPORT:
-- 1. Buka phpMyAdmin (XAMPP/Laragon)
-- 2. Klik tab "Import"
-- 3. Pilih file database.sql ini
-- 4. Klik "Go"
-- 5. Database siap digunakan!
--
-- Login Demo Credentials:
-- Admin: admin@jawara.com / password123
-- RT 05: budi.rt05@jawara.com / password123
-- Warga: aminah@jawara.com / password123
-- ============================================

-- Note: Main seed data already inserted above. Below are legacy duplicates (kept for backward compatibility)
-- The main seed contains the complete dataset with 4 fashion categories.
