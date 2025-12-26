-- Add notifications table
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

-- Sample notifications (optional - for testing)
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
('user_6755f4d2b4a7d', 'Selamat Datang!', 'Terima kasih telah bergabung dengan Jawara Marketplace', 'general', 0, NOW() - INTERVAL 1 HOUR),
('user_6755f4d2b4a7d', 'Produk Anda Dilihat', 'Kaos Batik telah dilihat 5 kali hari ini', 'views', 1, NOW() - INTERVAL 2 HOUR);
