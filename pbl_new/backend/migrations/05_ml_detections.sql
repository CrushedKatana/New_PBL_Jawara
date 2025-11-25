-- ============================================
-- MIGRATION: ML Detection (PCVK Model)
-- Feature: Camera AI Detection untuk kategori produk
-- ============================================

USE marketplace_rtrw;

-- ============================================
-- Tabel ML Detections (PCVK Model)
-- ============================================
CREATE TABLE IF NOT EXISTS ml_detections (
    id VARCHAR(50) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    detected_category VARCHAR(100),
    confidence DECIMAL(5, 2),
    model_version VARCHAR(20),
    detection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_category (detected_category),
    INDEX idx_detection_time (detection_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEED DATA: ML Detections
-- ============================================
-- Sample detections for ML Analytics dashboard
INSERT IGNORE INTO ml_detections (id, product_id, detected_category, confidence, model_version, detection_time) VALUES
('det001', 'prod001', 'Elektronik', 96.5, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 2 MINUTE)),
('det002', 'prod002', 'Fashion', 94.2, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
('det003', 'prod003', 'Makanan', 98.1, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 10 MINUTE)),
('det004', 'prod004', 'Furniture', 92.7, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 15 MINUTE)),
('det005', 'prod005', 'Olahraga', 95.3, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 20 MINUTE)),
('det006', 'prod006', 'Buku', 93.8, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('det007', 'prod007', 'Mainan', 97.2, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('det008', 'prod008', 'Elektronik', 95.6, 'PCVK-v1.2', DATE_SUB(NOW(), INTERVAL 3 HOUR));

-- Category distribution stats for dashboard
-- T-Shirt: 32%, Kemeja: 23%, Sepatu: 18%, Topi: 12%, etc (mocked in app UI)
