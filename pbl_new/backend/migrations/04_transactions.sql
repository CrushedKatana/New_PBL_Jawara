-- ============================================
-- MIGRATION: Transactions
-- Feature: Transaksi Pembelian
-- ============================================

USE marketplace_rtrw;

-- ============================================
-- Tabel Transactions
-- ============================================
CREATE TABLE IF NOT EXISTS transactions (
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
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEED DATA: Transactions
-- ============================================
INSERT IGNORE INTO transactions (id, product_id, buyer_id, seller_id, amount, status, payment_method, created_at) VALUES
('trx001', 'prod003', 'warga002', 'warga010', 15000, 'completed', 'Cash', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('trx002', 'prod005', 'warga004', 'warga002', 450000, 'completed', 'Transfer Bank', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('trx003', 'prod002', 'warga006', 'warga001', 850000, 'completed', 'Cash', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('trx004', 'prod006', 'warga004', 'warga006', 650000, 'pending', 'Transfer Bank', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('trx005', 'prod001', 'warga007', 'warga011', 12500000, 'completed', 'Transfer Bank', DATE_SUB(NOW(), INTERVAL 10 DAY)),
('trx006', 'prod004', 'warga010', 'warga004', 2500000, 'completed', 'Transfer Bank', DATE_SUB(NOW(), INTERVAL 15 DAY)),
('trx007', 'prod007', 'warga002', 'warga004', 1200000, 'pending', 'Cash', DATE_SUB(NOW(), INTERVAL 1 HOUR));
