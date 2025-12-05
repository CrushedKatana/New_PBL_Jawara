-- ============================================
-- MIGRATION: Authentication & Users
-- Feature: Auth (Login, Register, User Management)
-- ============================================

USE marketplace_rtrw;

-- ============================================
-- Tabel Users (Warga, RT/RW, Admin)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
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
    INDEX idx_verification (verification_status),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEED DATA: Users
-- ============================================
-- Password: "password123"
-- Hash: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi

-- Admin
INSERT IGNORE INTO users (id, name, email, password, phone, address, rt, rw, user_type, verification_status, is_active, joined_date) VALUES
('admin001', 'Budi Santoso', 'admin@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567890', 'Kantor Kelurahan Maju Jaya', '', '', 'admin', 'verified', TRUE, '2023-11-01');

-- RT Officers
INSERT IGNORE INTO users (id, name, email, password, phone, address, rt, rw, user_type, verification_status, is_active, joined_date) VALUES
('rt001', 'Pak Ahmad RT 01', 'ahmad.rt01@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567801', 'Jl. Merdeka No. 1', '01', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt002', 'Pak Budi RT 02', 'budi.rt02@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567802', 'Jl. Merdeka No. 2', '02', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt003', 'Pak Candra RT 03', 'candra.rt03@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567803', 'Jl. Merdeka No. 3', '03', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt004', 'Pak Dedi RT 04', 'dedi.rt04@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567804', 'Jl. Merdeka No. 4', '04', '05', 'rt', 'verified', TRUE, '2023-12-01'),
('rt005', 'Pak Budi RT 05', 'budi.rt05@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567805', 'Jl. Merdeka No. 5', '05', '05', 'rt', 'verified', TRUE, '2023-12-01');

-- Warga (Sample data per RT)
INSERT IGNORE INTO users (id, name, email, password, phone, address, rt, rw, user_type, verification_status, is_active, joined_date) VALUES
('warga001', 'Toko Sepatu Jaya', 'sepatu@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234561001', 'Jl. Sudirman No. 10', '01', '05', 'warga', 'verified', FALSE, '2024-01-15'),
('warga002', 'Ibu Lisa', 'lisa@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234561002', 'Jl. Sudirman No. 12', '01', '05', 'warga', 'verified', TRUE, '2024-02-01'),
('warga004', 'Dimas Pratama', 'dimas@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234562001', 'Jl. Gatot Subroto No. 20', '02', '05', 'warga', 'verified', TRUE, '2024-02-15'),
('warga006', 'Sari Wulandari', 'sari@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234563001', 'Jl. Ahmad Yani No. 30', '03', '05', 'warga', 'verified', TRUE, '2024-03-15'),
('warga007', 'Pak Eko', 'eko@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234563002', 'Jl. Ahmad Yani No. 32', '03', '05', 'warga', 'pending', TRUE, '2024-03-20'),
('warga010', 'Ibu Siti Aminah', 'aminah@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234565001', 'Jl. Veteran No. 50', '05', '05', 'warga', 'verified', TRUE, '2024-01-10'),
('warga011', 'Toko Elektronik Maju', 'elektronik@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234565002', 'Jl. Veteran No. 52', '05', '05', 'warga', 'verified', TRUE, '2024-01-25'),
('warga012', 'Pak Herman', 'herman@jawara.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234565003', 'Jl. Veteran No. 54', '05', '05', 'warga', 'pending', TRUE, '2024-03-25');
