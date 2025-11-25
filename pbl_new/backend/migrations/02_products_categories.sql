-- ============================================
-- MIGRATION: Products & Categories
-- Feature: Marketplace (Warga - Jualan, Beranda)
-- ============================================

USE marketplace_rtrw;

-- ============================================
-- Tabel Categories
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabel Products
-- ============================================
CREATE TABLE IF NOT EXISTS products (
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
    INDEX idx_approval (approval_status),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEED DATA: Categories
-- ============================================
INSERT IGNORE INTO categories (id, name, icon, color) VALUES
('cat1', 'Elektronik', 'devices', '#2196F3'),
('cat2', 'Fashion', 'checkroom', '#E91E63'),
('cat3', 'Makanan', 'restaurant', '#FF9800'),
('cat4', 'Furniture', 'weekend', '#795548'),
('cat5', 'Olahraga', 'sports_soccer', '#4CAF50'),
('cat6', 'Buku', 'menu_book', '#9C27B0'),
('cat7', 'Mainan', 'toys', '#00BCD4'),
('cat8', 'Lainnya', 'more_horiz', '#607D8B');

-- ============================================
-- SEED DATA: Products
-- ============================================
INSERT IGNORE INTO products (id, title, description, price, category_id, seller_id, location, is_active, approval_status, approved_by, view_count) VALUES
-- Approved Products
('prod001', 'Laptop Asus ROG', 'Laptop gaming kondisi mulus, RAM 16GB, SSD 512GB', 12500000, 'cat1', 'warga011', 'Jl. Veteran No. 52, RT 05', TRUE, 'approved', 'rt005', 245),
('prod002', 'Sepatu Nike Air Max', 'Sepatu olahraga original, size 42, warna hitam', 850000, 'cat2', 'warga001', 'Jl. Sudirman No. 10, RT 01', TRUE, 'approved', 'rt001', 189),
('prod003', 'Nasi Goreng Spesial', 'Nasi goreng dengan telur, ayam, dan sayuran segar', 15000, 'cat3', 'warga010', 'Jl. Veteran No. 50, RT 05', TRUE, 'approved', 'rt005', 432),
('prod004', 'Sofa Minimalis', 'Sofa 3 seater, bahan kulit sintetis, warna abu-abu', 2500000, 'cat4', 'warga004', 'Jl. Gatot Subroto No. 22, RT 02', TRUE, 'approved', 'rt002', 167),
('prod005', 'Raket Badminton Yonex', 'Raket badminton profesional dengan cover', 450000, 'cat5', 'warga002', 'Jl. Sudirman No. 12, RT 01', TRUE, 'approved', 'rt001', 203),
('prod006', 'Harry Potter Complete Set', 'Set lengkap 7 buku Harry Potter bahasa Indonesia', 650000, 'cat6', 'warga006', 'Jl. Ahmad Yani No. 30, RT 03', TRUE, 'approved', 'rt003', 156),
('prod007', 'Lego Star Wars', 'Lego set Star Wars Millennium Falcon, lengkap', 1200000, 'cat7', 'warga004', 'Jl. Gatot Subroto No. 20, RT 02', TRUE, 'approved', 'rt002', 98),
('prod008', 'Kulkas 2 Pintu Sharp', 'Kulkas bekas kondisi bagus, hemat listrik', 1800000, 'cat1', 'warga004', 'Jl. Gatot Subroto No. 20, RT 02', TRUE, 'approved', 'rt002', 134),

-- Pending Approval (for RT approval queue)
('prod009', 'iPhone 13 Pro', 'iPhone second mulus 128GB warna gold', 9500000, 'cat1', 'warga007', 'Jl. Ahmad Yani No. 32, RT 03', TRUE, 'pending', NULL, 0),
('prod010', 'Jaket Kulit Premium', 'Jaket kulit asli kambing, size L', 750000, 'cat2', 'warga012', 'Jl. Veteran No. 54, RT 05', TRUE, 'pending', NULL, 0),
('prod011', 'Meja Belajar Kayu Jati', 'Meja belajar solid jati dengan laci', 1500000, 'cat4', 'warga002', 'Jl. Sudirman No. 12, RT 01', TRUE, 'pending', NULL, 0);
