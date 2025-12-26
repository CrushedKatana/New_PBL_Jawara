-- ============================================
-- MIGRATION: ML Detection (PCVK Model)
-- Feature: Machine Learning - Clothing Detection
-- Related Files:
--   - ml_training/scripts/train_model.py
--   - backend/ml_detection.php
--   - backend/ml_detection_history.php
--   - lib/features/warga/screens/clothing_detection_screen.dart
--   - lib/features/admin/screens/ml_statistics_screen.dart
-- ============================================

USE marketplace_rtrw;

-- ============================================
-- Tabel ML Detections (PCVK Model)
-- Menyimpan hasil deteksi pakaian dari user
-- ============================================
CREATE TABLE IF NOT EXISTS ml_detections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    image_path VARCHAR(500) NOT NULL,
    predicted_class VARCHAR(100) NOT NULL,
    confidence DECIMAL(5, 4) NOT NULL,
    top3_predictions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES auth_users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_predicted_class (predicted_class),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEED DATA: ML Detections
-- Sample data untuk testing
-- ============================================
INSERT INTO ml_detections (user_id, image_path, predicted_class, confidence, top3_predictions, created_at) VALUES
(3, '/uploads/ml_detections/ml_1701615000.jpg', 'Kemeja', 0.9245, 
 '[{"class":"Kemeja","confidence":0.9245},{"class":"Blouse","confidence":0.0512},{"class":"Jaket","confidence":0.0143}]',
 '2025-12-03 10:30:00'),

(4, '/uploads/ml_detections/ml_1701615120.jpg', 'Celana', 0.8876, 
 '[{"class":"Celana","confidence":0.8876},{"class":"Celana Jeans","confidence":0.0893},{"class":"Celana Pendek","confidence":0.0156}]',
 '2025-12-03 11:15:00'),

(5, '/uploads/ml_detections/ml_1701615240.jpg', 'Dress', 0.9512, 
 '[{"class":"Dress","confidence":0.9512},{"class":"Rok","confidence":0.0298},{"class":"Blouse","confidence":0.0123}]',
 '2025-12-03 11:45:00'),

(3, '/uploads/ml_detections/ml_1701615360.jpg', 'Jaket', 0.7634, 
 '[{"class":"Jaket","confidence":0.7634},{"class":"Sweater","confidence":0.1823},{"class":"Kemeja","confidence":0.0412}]',
 '2025-12-03 12:20:00'),

(6, '/uploads/ml_detections/ml_1701615480.jpg', 'Rok', 0.9123, 
 '[{"class":"Rok","confidence":0.9123},{"class":"Dress","confidence":0.0634},{"class":"Celana","confidence":0.0156}]',
 '2025-12-03 13:00:00'),

(7, '/uploads/ml_detections/ml_1701615600.jpg', 'Kemeja', 0.8934, 
 '[{"class":"Kemeja","confidence":0.8934},{"class":"Blouse","confidence":0.0745},{"class":"Kaos","confidence":0.0234}]',
 '2025-12-03 13:30:00'),

(4, '/uploads/ml_detections/ml_1701615720.jpg', 'Celana Jeans', 0.9234, 
 '[{"class":"Celana Jeans","confidence":0.9234},{"class":"Celana","confidence":0.0523},{"class":"Celana Pendek","confidence":0.0167}]',
 '2025-12-03 14:00:00'),

(5, '/uploads/ml_detections/ml_1701615840.jpg', 'Blouse', 0.8567, 
 '[{"class":"Blouse","confidence":0.8567},{"class":"Kemeja","confidence":0.1123},{"class":"Kaos","confidence":0.0234}]',
 '2025-12-03 14:30:00'),

(8, '/uploads/ml_detections/ml_1701615960.jpg', 'Kaos', 0.9456, 
 '[{"class":"Kaos","confidence":0.9456},{"class":"Kemeja","confidence":0.0345},{"class":"Blouse","confidence":0.0134}]',
 '2025-12-03 15:00:00'),

(9, '/uploads/ml_detections/ml_1701616080.jpg', 'Sweater', 0.8789, 
 '[{"class":"Sweater","confidence":0.8789},{"class":"Jaket","confidence":0.0923},{"class":"Hoodie","confidence":0.0234}]',
 '2025-12-03 15:30:00'),

(3, '/uploads/ml_detections/ml_1701616200.jpg', 'Kemeja', 0.9012, 
 '[{"class":"Kemeja","confidence":0.9012},{"class":"Blouse","confidence":0.0678},{"class":"Kaos","confidence":0.0234}]',
 '2025-12-03 16:00:00'),

(6, '/uploads/ml_detections/ml_1701616320.jpg', 'Dress', 0.9345, 
 '[{"class":"Dress","confidence":0.9345},{"class":"Rok","confidence":0.0456},{"class":"Blouse","confidence":0.0145}]',
 '2025-12-03 16:30:00');

-- ============================================
-- VERIFIKASI & STATISTIK
-- ============================================

-- Verifikasi total data
SELECT 
    COUNT(*) as total_detections,
    COUNT(DISTINCT user_id) as total_users,
    COUNT(DISTINCT predicted_class) as total_categories,
    AVG(confidence) as avg_confidence
FROM ml_detections;

-- Statistik per kategori
SELECT 
    predicted_class,
    COUNT(*) as count,
    AVG(confidence) as avg_confidence
FROM ml_detections
GROUP BY predicted_class
ORDER BY count DESC;

-- Deteksi terbaru dengan info user
SELECT 
    md.id,
    md.predicted_class,
    md.confidence,
    md.created_at,
    au.nama as user_name,
    au.rt
FROM ml_detections md
JOIN auth_users au ON md.user_id = au.id
ORDER BY md.created_at DESC
LIMIT 10;

-- Statistik per RT
SELECT 
    au.rt,
    COUNT(md.id) as total_detections,
    AVG(md.confidence) as avg_confidence
FROM ml_detections md
JOIN auth_users au ON md.user_id = au.id
GROUP BY au.rt
ORDER BY total_detections DESC;
