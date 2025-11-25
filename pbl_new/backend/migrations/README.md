# Database Migrations

File-file migration SQL terpisah berdasarkan fitur untuk memudahkan deployment dan debugging.

## Urutan Migration

Jalankan file SQL ini secara berurutan di phpMyAdmin:

### 1. `01_auth_users.sql`
**Feature:** Authentication & User Management  
**Tables:** `users`  
**Related Screens:**
- `features/auth/screens/` (login, register, splash)
- `features/admin/screens/` (user management)
- `features/rt/screens/rt_warga_list_screen.dart`

**Data:** 17 users (1 admin, 5 RT, 12 warga)

---

### 2. `02_products_categories.sql`
**Feature:** Marketplace Products  
**Tables:** `categories`, `products`  
**Related Screens:**
- `features/warga/screens/beranda_screen.dart`
- `features/warga/screens/jualan_screen.dart`
- `features/warga/screens/add_product_screen.dart`
- `features/warga/screens/product_detail_screen.dart`
- `features/rt/screens/rt_approval_screen.dart`

**Data:** 8 categories, 11 products (8 approved, 3 pending)

---

### 3. `03_chat_messages.sql`
**Feature:** Chat/Messaging  
**Tables:** `messages`  
**Related Screens:**
- `features/warga/screens/chat_screen.dart`
- `features/warga/screens/chat_detail_screen.dart`

**Data:** 8 chat messages

---

### 4. `04_transactions.sql`
**Feature:** Transactions  
**Tables:** `transactions`  
**Related Screens:**
- `features/warga/` (purchase flow)
- `features/rt/screens/rt_dashboard_screen.dart`
- `features/admin/screens/admin_dashboard_screen.dart`

**Data:** 7 transactions

---

### 5. `05_ml_detections.sql`
**Feature:** ML Detection (PCVK Model)  
**Tables:** `ml_detections`  
**Related Screens:**
- `features/warga/screens/camera_detection_screen.dart`
- `features/admin/screens/admin_dashboard_screen.dart` (ML Analytics)

**Data:** 8 sample detections

---

### 6. `06_rt_metrics_activities.sql`
**Feature:** RT Metrics & Activity Logs  
**Tables:** `rt_metrics`, `activities`  
**Related Screens:**
- `features/rt/screens/rt_dashboard_screen.dart`
- `features/admin/screens/admin_dashboard_screen.dart`

**Data:** RT performance data, activity logs

---

## Cara Import

### Option 1: Import All (Full Database)
Gunakan `database.sql` untuk setup lengkap sekaligus.

### Option 2: Import Per Feature (Recommended untuk Development)
1. Buka phpMyAdmin
2. Create database: `CREATE DATABASE marketplace_rtrw;`
3. Import file migration satu per satu sesuai urutan di atas
4. Verifikasi setiap table setelah import

```sql
-- Cek tables yang sudah dibuat
SHOW TABLES;

-- Cek jumlah records
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM messages;
SELECT COUNT(*) FROM transactions;
SELECT COUNT(*) FROM ml_detections;
```

### Option 3: Command Line (Advanced)

```bash
# Import all migrations
mysql -u root -p marketplace_rtrw < 01_auth_users.sql
mysql -u root -p marketplace_rtrw < 02_products_categories.sql
mysql -u root -p marketplace_rtrw < 03_chat_messages.sql
mysql -u root -p marketplace_rtrw < 04_transactions.sql
mysql -u root -p marketplace_rtrw < 05_ml_detections.sql
mysql -u root -p marketplace_rtrw < 06_rt_metrics_activities.sql
```

## Rollback Strategy

Untuk rollback feature tertentu:

```sql
-- Rollback ML Detection
DROP TABLE ml_detections;

-- Rollback Chat
DROP TABLE messages;

-- Rollback Transactions
DROP TABLE transactions;

-- dll...
```

## Testing Per Feature

Setelah import migration, test dengan query:

```sql
-- Test Auth
SELECT * FROM users WHERE user_type = 'warga' LIMIT 5;

-- Test Products
SELECT p.*, c.name as category_name 
FROM products p 
LEFT JOIN categories c ON p.category_id = c.id 
WHERE approval_status = 'approved';

-- Test Chat
SELECT m.*, u1.name as sender, u2.name as receiver
FROM messages m
JOIN users u1 ON m.sender_id = u1.id
JOIN users u2 ON m.receiver_id = u2.id
ORDER BY created_at DESC;

-- Test RT Metrics
SELECT * FROM rt_metrics WHERE rt = '05';
```

## Dependencies

**Migration Order matters!** Foreign keys require parent tables:
- `02_products` depends on `01_auth` (seller_id, approved_by)
- `03_chat` depends on `01_auth` & `02_products`
- `04_transactions` depends on `01_auth` & `02_products`
- `05_ml_detections` depends on `02_products`
- `06_rt_metrics` depends on `01_auth`
