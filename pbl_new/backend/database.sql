-- Database untuk Marketplace RT/RW
-- Gunakan di phpMyAdmin XAMPP

CREATE DATABASE IF NOT EXISTS marketplace_rtrw;
USE marketplace_rtrw;

-- Tabel Users
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
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Categories
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Products
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel Messages
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
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- Insert default categories
INSERT INTO categories (id, name, icon) VALUES
('cat1', 'Makanan', 'food'),
('cat2', 'Elektronik', 'electronics'),
('cat3', 'Fashion', 'fashion'),
('cat4', 'Perabotan', 'furniture'),
('cat5', 'Lainnya', 'other');

-- Insert sample users
INSERT INTO users (id, name, email, password, phone, address, rt, rw, user_type) VALUES
('user1', 'Budi Santoso', 'budi@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567890', 'Jl. Mawar No. 1', '001', '005', 'warga'),
('user2', 'Siti Aminah', 'siti@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567891', 'Jl. Melati No. 2', '002', '005', 'warga'),
('user3', 'Ahmad Hidayat', 'ahmad@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567892', 'Jl. Anggrek No. 3', '001', '005', 'rt');

-- Insert sample products
INSERT INTO products (id, title, description, price, category_id, seller_id, location, is_active) VALUES
('prod1', 'Nasi Goreng Spesial', 'Nasi goreng dengan telur dan ayam', 15000, 'cat1', 'user1', 'Jl. Mawar No. 1', TRUE),
('prod2', 'Laptop Bekas', 'Laptop second kondisi mulus', 3500000, 'cat2', 'user2', 'Jl. Melati No. 2', TRUE);
