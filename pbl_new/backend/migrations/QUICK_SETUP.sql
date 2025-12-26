-- ========================================
-- QUICK SETUP untuk Bug Fix
-- ========================================
-- File: pbl_new/backend/migrations/QUICK_SETUP.sql
-- 
-- Jalankan SQL ini di phpMyAdmin untuk:
-- 1. Create tabel notifications
-- 2. Insert sample data untuk testing
-- ========================================

USE marketplace_rtrw;

-- 1. Create notifications table (jika belum ada)
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'general',
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    related_id VARCHAR(50) NULL,
    data TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Get user_id dari tabel users untuk testing
-- (Ganti 'user_xxxxx' dengan id user Anda yang sebenarnya)
SELECT id, name, email FROM users LIMIT 5;

-- 3. Insert sample notifications (GANTI user_id dengan hasil query di atas!)
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
('user_6755f4d2b4a7d', '🎉 Selamat Datang!', 'Terima kasih telah bergabung dengan Jawara Marketplace RT/RW', 'general', 0, NOW() - INTERVAL 10 MINUTE),
('user_6755f4d2b4a7d', '📦 Pesanan Dikirim', 'Pesanan #ORD-001 sedang dalam perjalanan ke alamat Anda', 'order', 0, NOW() - INTERVAL 30 MINUTE),
('user_6755f4d2b4a7d', '💬 Pesan Baru', 'Anda memiliki pesan baru dari Pak Budi', 'message', 0, NOW() - INTERVAL 1 HOUR),
('user_6755f4d2b4a7d', '💰 Pembayaran Berhasil', 'Pembayaran untuk pesanan #ORD-001 telah dikonfirmasi', 'payment', 1, NOW() - INTERVAL 2 HOUR),
('user_6755f4d2b4a7d', '✅ Verifikasi Disetujui', 'Status verifikasi Anda telah disetujui oleh RT 05', 'verification', 1, NOW() - INTERVAL 5 HOUR),
('user_6755f4d2b4a7d', '👀 Produk Anda Dilihat', 'Kaos Batik mendapat 15 views minggu ini!', 'views', 1, NOW() - INTERVAL 1 DAY);

-- 4. Verify data inserted
SELECT COUNT(*) as total_notifications FROM notifications;
SELECT * FROM notifications ORDER BY created_at DESC LIMIT 10;

-- 5. Check unread count (untuk testing badge)
SELECT COUNT(*) as unread_count FROM notifications WHERE user_id = 'user_6755f4d2b4a7d' AND is_read = 0;

-- ========================================
-- Testing Queries
-- ========================================

-- Test get notifications by user
SELECT * FROM notifications 
WHERE user_id = 'user_6755f4d2b4a7d' 
ORDER BY created_at DESC;

-- Test filter by type
SELECT * FROM notifications 
WHERE user_id = 'user_6755f4d2b4a7d' AND type IN ('order', 'payment')
ORDER BY created_at DESC;

-- Test mark as read
UPDATE notifications SET is_read = 1 WHERE id = 1;

-- Test mark all as read
UPDATE notifications SET is_read = 1 WHERE user_id = 'user_6755f4d2b4a7d' AND is_read = 0;

-- ========================================
-- Cleanup (jika perlu reset)
-- ========================================

-- Delete all notifications (WARNING: Deletes all data!)
-- TRUNCATE TABLE notifications;

-- Drop table (WARNING: Removes table completely!)
-- DROP TABLE IF EXISTS notifications;

-- ========================================
-- SELESAI!
-- ========================================
-- Setelah run SQL ini:
-- 1. Buka Flutter app
-- 2. Login sebagai user
-- 3. Lihat badge notifikasi di Beranda
-- 4. Tap icon notifikasi → lihat list notifikasi
-- 5. Test filter: Semua, Pesanan, Pesan
-- 6. Test "Tandai semua dibaca"
-- ========================================
