-- ============================================
-- UPDATE DATABASE UNTUK FIX PROFILE & NOTIFICATIONS
-- ============================================
-- Jalankan di phpMyAdmin (http://localhost/phpmyadmin)
-- Database: marketplace_rtrw
-- ============================================

USE marketplace_rtrw;

-- 1. Tambah column 'role' di table users kalau belum ada
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'warga' AFTER email;

-- 2. Set default role untuk user yang sudah ada
UPDATE users SET role = 'warga' WHERE role IS NULL OR role = '';

-- 3. Buat table notifications kalau belum ada
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('pesanan', 'pesan', 'umum') DEFAULT 'umum',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Insert sample notifications untuk testing
INSERT IGNORE INTO notifications (user_id, title, message, type, is_read) VALUES
(1, 'Selamat Datang!', 'Terima kasih telah bergabung dengan marketplace RT/RW', 'umum', FALSE),
(1, 'Pesanan Baru', 'Anda mendapat pesanan untuk Kaos Polo', 'pesanan', FALSE),
(1, 'Pesan Masuk', 'Budi mengirim pesan: "Apakah barang masih ada?"', 'pesan', FALSE);

-- 5. Verify structure
SELECT 'USERS TABLE STRUCTURE:' as Info;
DESCRIBE users;

SELECT 'NOTIFICATIONS TABLE STRUCTURE:' as Info;
DESCRIBE notifications;

SELECT 'SAMPLE DATA:' as Info;
SELECT id, name, email, role FROM users LIMIT 5;

SELECT COUNT(*) as total_notifications FROM notifications;

SELECT '✅ DATABASE UPDATE COMPLETE!' as Status;
