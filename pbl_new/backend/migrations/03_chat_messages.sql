-- ============================================
-- MIGRATION: Chat & Messages
-- Feature: Chat (Warga - Chat antar pembeli/penjual)
-- ============================================

USE marketplace_rtrw;

-- ============================================
-- Tabel Messages/Chat
-- ============================================
CREATE TABLE IF NOT EXISTS messages (
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
    INDEX idx_created (created_at),
    INDEX idx_conversation (sender_id, receiver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEED DATA: Messages
-- ============================================
INSERT IGNORE INTO messages (id, sender_id, receiver_id, product_id, message, is_read, created_at) VALUES
('msg001', 'warga002', 'warga010', 'prod003', 'Masih ada?', TRUE, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('msg002', 'warga010', 'warga002', 'prod003', 'Masih ada kak, mau pesan berapa?', TRUE, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('msg003', 'warga002', 'warga010', 'prod003', 'Pesan 2 porsi ya', TRUE, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('msg004', 'warga004', 'warga002', 'prod005', 'Raketnya masih bagus kan?', TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('msg005', 'warga002', 'warga004', 'prod005', 'Masih bagus banget, jarang dipakai', TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('msg006', 'warga006', 'warga001', 'prod002', 'Boleh COD?', FALSE, DATE_SUB(NOW(), INTERVAL 30 MINUTE)),
('msg007', 'warga007', 'warga011', 'prod001', 'Laptopnya masih garansi?', FALSE, DATE_SUB(NOW(), INTERVAL 15 MINUTE)),
('msg008', 'warga011', 'warga007', 'prod001', 'Garansi sampai bulan depan kak', TRUE, DATE_SUB(NOW(), INTERVAL 10 MINUTE));
