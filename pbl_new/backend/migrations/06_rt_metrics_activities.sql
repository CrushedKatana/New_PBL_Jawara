-- ============================================
-- MIGRATION: RT Metrics & Activities
-- Feature: RT Dashboard & Admin Dashboard
-- ============================================

USE marketplace_rtrw;

-- ============================================
-- Tabel RT Dashboard Metrics
-- ============================================
CREATE TABLE IF NOT EXISTS rt_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rt VARCHAR(10) NOT NULL,
    metric_type ENUM('warga', 'produk', 'transaksi') NOT NULL,
    metric_value INT DEFAULT 0,
    month INT,
    year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rt (rt),
    INDEX idx_period (year, month),
    INDEX idx_type (metric_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel Activities/Logs
-- ============================================
CREATE TABLE IF NOT EXISTS activities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    activity_type VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_created (created_at),
    INDEX idx_type (activity_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEED DATA: RT Metrics
-- ============================================
-- Data untuk RT Performance table di Admin Dashboard
INSERT IGNORE INTO rt_metrics (rt, metric_type, metric_value, month, year) VALUES
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
-- SEED DATA: Activities
-- ============================================
-- Sample activities for RT Dashboard
INSERT IGNORE INTO activities (user_id, activity_type, description, created_at) VALUES
('warga002', 'product_view', 'Melihat produk Nasi Goreng Spesial', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('warga004', 'product_purchase', 'Membeli Raket Badminton Yonex', DATE_SUB(NOW(), INTERVAL 5 HOUR)),
('rt005', 'product_approval', 'Menyetujui produk Laptop Asus ROG', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('warga007', 'user_register', 'Mendaftar sebagai warga baru RT 03', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('rt003', 'product_approval', 'Menyetujui produk Harry Potter Complete Set', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('warga010', 'product_post', 'Menambahkan produk Nasi Goreng Spesial', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('rt001', 'user_verification', 'Memverifikasi warga baru Ibu Lisa', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('warga006', 'message_sent', 'Mengirim pesan ke Toko Sepatu Jaya', DATE_SUB(NOW(), INTERVAL 6 HOUR));
