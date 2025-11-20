# README - Backend API Marketplace RT/RW

REST API untuk aplikasi Marketplace RT/RW menggunakan PHP dan MySQL.

## 📋 Daftar Isi

- [Teknologi](#teknologi)
- [Struktur File](#struktur-file)
- [Endpoint API](#endpoint-api)
- [Setup](#setup)
- [Testing](#testing)

## 🛠 Teknologi

- **Backend:** PHP 7.4+
- **Database:** MySQL 5.7+
- **Server:** Apache (XAMPP)
- **Format Data:** JSON

## 📁 Struktur File

```
backend/
├── config.php          # Konfigurasi database dan helper functions
├── auth.php            # Authentication (login, register, profile)
├── products.php        # CRUD Produk
├── chat.php            # Messaging/Chat
├── categories.php      # Kategori produk
└── database.sql        # Database schema dan sample data
```

## 🌐 Endpoint API

Base URL: `http://localhost/marketplace_api`

### Authentication (`auth.php`)

#### Register
```http
POST /auth.php?action=register
Content-Type: application/json

{
  "name": "Nama Lengkap",
  "email": "email@example.com",
  "password": "password123",
  "phone": "081234567890",
  "address": "Alamat Lengkap",
  "rt": "001",
  "rw": "005"
}

Response 201:
{
  "success": true,
  "data": {
    "id": "user_...",
    "name": "Nama Lengkap",
    "email": "email@example.com",
    ...
  }
}
```

#### Login
```http
POST /auth.php
Content-Type: application/json

{
  "email": "email@example.com",
  "password": "password123"
}

Response 200:
{
  "success": true,
  "data": {
    "id": "user_...",
    "name": "Nama Lengkap",
    ...
  }
}
```

#### Get User Profile
```http
GET /auth.php?user_id=user_123

Response 200:
{
  "success": true,
  "data": {
    "id": "user_123",
    "name": "Nama",
    ...
  }
}
```

#### Update Profile
```http
PUT /auth.php
Content-Type: application/json

{
  "id": "user_123",
  "name": "Nama Baru",
  "phone": "081234567890",
  "address": "Alamat Baru",
  "rt": "001",
  "rw": "005",
  "photo_url": "http://..."
}

Response 200:
{
  "success": true
}
```

### Products (`products.php`)

#### Get All Products
```http
GET /products.php

# Filter by seller
GET /products.php?seller_id=user_123

# Filter by category
GET /products.php?category_id=cat1

# Search
GET /products.php?search=laptop

Response 200:
{
  "success": true,
  "data": [
    {
      "id": "prod_...",
      "title": "Nama Produk",
      "price": 150000,
      "seller_name": "Nama Penjual",
      ...
    }
  ]
}
```

#### Add Product
```http
POST /products.php
Content-Type: application/json

{
  "title": "Nama Produk",
  "description": "Deskripsi",
  "price": 150000,
  "category_id": "cat1",
  "seller_id": "user_123",
  "image_url": "http://...",
  "location": "Jl. Mawar No. 1"
}

Response 201:
{
  "success": true,
  "data": {
    "id": "prod_..."
  }
}
```

#### Update Product
```http
PUT /products.php
Content-Type: application/json

{
  "id": "prod_123",
  "title": "Nama Baru",
  "description": "Deskripsi Baru",
  "price": 200000,
  "category_id": "cat2",
  "image_url": "http://...",
  "location": "Lokasi Baru"
}

Response 200:
{
  "success": true
}
```

#### Delete Product
```http
DELETE /products.php
Content-Type: application/json

{
  "id": "prod_123"
}

Response 200:
{
  "success": true
}
```

### Chat (`chat.php`)

#### Get Conversation List
```http
GET /chat.php?user_id=user_123

Response 200:
{
  "success": true,
  "data": [
    {
      "id": "msg_...",
      "sender_id": "user_456",
      "sender_name": "Nama Pengirim",
      "message": "Halo...",
      "created_at": "2024-01-01 10:00:00",
      ...
    }
  ]
}
```

#### Get Messages with Specific User
```http
GET /chat.php?user_id=user_123&conversation_with=user_456

Response 200:
{
  "success": true,
  "data": [
    {
      "id": "msg_...",
      "sender_id": "user_123",
      "receiver_id": "user_456",
      "message": "Halo...",
      "is_read": false,
      "created_at": "2024-01-01 10:00:00"
    }
  ]
}
```

#### Send Message
```http
POST /chat.php
Content-Type: application/json

{
  "sender_id": "user_123",
  "receiver_id": "user_456",
  "message": "Halo, produknya masih ada?",
  "product_id": "prod_789"  // optional
}

Response 201:
{
  "success": true,
  "data": {
    "id": "msg_..."
  }
}
```

#### Mark as Read
```http
PUT /chat.php
Content-Type: application/json

{
  "user_id": "user_123",
  "conversation_with": "user_456"
}

Response 200:
{
  "success": true
}
```

### Categories (`categories.php`)

#### Get All Categories
```http
GET /categories.php

Response 200:
{
  "success": true,
  "data": [
    {
      "id": "cat1",
      "name": "Makanan",
      "icon": "food",
      "created_at": "2024-01-01 10:00:00"
    }
  ]
}
```

## 🚀 Setup

Lihat file [SETUP_XAMPP.md](../SETUP_XAMPP.md) untuk panduan lengkap.

Ringkasan:
1. Install XAMPP
2. Import `database.sql` di phpMyAdmin
3. Copy file PHP ke `C:\xampp\htdocs\marketplace_api\`
4. Konfigurasi `config.php`
5. Test API di browser

## 🧪 Testing

### Menggunakan Browser
Buka browser dan akses:
```
http://localhost/marketplace_api/products.php
http://localhost/marketplace_api/categories.php
```

### Menggunakan Postman
1. Import collection dari file (jika ada)
2. Set base URL: `http://localhost/marketplace_api`
3. Test masing-masing endpoint

### Menggunakan CURL
```bash
# Get products
curl http://localhost/marketplace_api/products.php

# Login
curl -X POST http://localhost/marketplace_api/auth.php \
  -H "Content-Type: application/json" \
  -d '{"email":"budi@email.com","password":"password"}'

# Add product
curl -X POST http://localhost/marketplace_api/products.php \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Product","price":50000,"seller_id":"user1","category_id":"cat1"}'
```

## 📊 Database Schema

### users
| Field | Type | Description |
|-------|------|-------------|
| id | VARCHAR(50) | Primary key |
| name | VARCHAR(100) | Nama lengkap |
| email | VARCHAR(100) | Email (unique) |
| password | VARCHAR(255) | Hashed password |
| phone | VARCHAR(20) | Nomor telepon |
| address | TEXT | Alamat lengkap |
| rt | VARCHAR(10) | RT |
| rw | VARCHAR(10) | RW |
| user_type | ENUM | warga/admin/rt |
| photo_url | TEXT | URL foto profil |

### products
| Field | Type | Description |
|-------|------|-------------|
| id | VARCHAR(50) | Primary key |
| title | VARCHAR(200) | Nama produk |
| description | TEXT | Deskripsi |
| price | DECIMAL(15,2) | Harga |
| category_id | VARCHAR(50) | Foreign key |
| seller_id | VARCHAR(50) | Foreign key |
| image_url | TEXT | URL gambar |
| location | VARCHAR(200) | Lokasi |
| is_active | BOOLEAN | Status aktif |

### messages
| Field | Type | Description |
|-------|------|-------------|
| id | VARCHAR(50) | Primary key |
| sender_id | VARCHAR(50) | Foreign key |
| receiver_id | VARCHAR(50) | Foreign key |
| product_id | VARCHAR(50) | Foreign key (nullable) |
| message | TEXT | Isi pesan |
| is_read | BOOLEAN | Status baca |

### categories
| Field | Type | Description |
|-------|------|-------------|
| id | VARCHAR(50) | Primary key |
| name | VARCHAR(100) | Nama kategori |
| icon | VARCHAR(50) | Icon kategori |

## 🔒 Keamanan

✅ **Sudah diimplementasi:**
- Password hashing menggunakan `password_hash()`
- Real escape string untuk prevent SQL injection
- CORS headers untuk Flutter
- JSON response format

⚠️ **Untuk Production:**
- Implementasi JWT authentication
- Rate limiting
- Input validation lebih ketat
- HTTPS
- Environment variables untuk kredensial

## 📝 Error Handling

API mengembalikan format error standar:
```json
{
  "success": false,
  "error": "Error message here"
}
```

Status codes:
- `200` - Success (GET, PUT, DELETE)
- `201` - Created (POST)
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `500` - Internal Server Error

## 📞 Support

Jika ada masalah:
1. Cek Apache/MySQL status di XAMPP
2. Cek error log: `C:\xampp\apache\logs\error.log`
3. Pastikan database sudah ter-import
4. Test endpoint dengan Postman/browser dulu

---

**Dibuat untuk Marketplace RT/RW - Flutter App**
