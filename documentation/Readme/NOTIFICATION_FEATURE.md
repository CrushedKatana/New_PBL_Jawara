# Fitur Notifikasi - Jawara Marketplace

## Overview
Fitur notifikasi yang lengkap untuk aplikasi Jawara Marketplace dengan berbagai jenis notifikasi seperti pesanan, pesan, pembayaran, verifikasi RT/RW, update aplikasi, views produk, dan pesan belum dibaca.

## File yang Ditambahkan

### 1. Model (`lib/core/models/notification_model.dart`)
- `NotificationModel`: Model data untuk notifikasi
- `NotificationType`: Enum untuk tipe-tipe notifikasi
  - `order`: Notifikasi pesanan
  - `message`: Pesan baru
  - `payment`: Pembayaran berhasil
  - `verification`: Verifikasi RT/RW
  - `update`: Update aplikasi
  - `views`: Produk dilihat
  - `unread`: Pesan belum dibaca

### 2. Service (`lib/core/services/notification_service.dart`)
Method yang tersedia:
- `fetchAllNotifications()`: Ambil semua notifikasi
- `fetchNotificationsByFilter(String filter)`: Filter berdasarkan "semua", "pesanan", atau "pesan"
- `markAsRead(String id)`: Tandai satu notifikasi sebagai dibaca
- `markAllAsRead()`: Tandai semua notifikasi sebagai dibaca
- `getUnreadCount()`: Hitung jumlah notifikasi yang belum dibaca

### 3. UI Screen (`lib/features/warga/screens/notifikasi_screen.dart`)
Fitur UI:
- **TabBar** dengan 3 tab: Semua, Pesanan, Pesan
- **Badge** untuk notifikasi belum dibaca (titik biru)
- **Counter** di header menampilkan jumlah notifikasi belum dibaca
- **Tombol "Tandai Semua"** untuk mark all as read
- **Pull to refresh** untuk reload data
- **Empty state** ketika tidak ada notifikasi
- **Icon dan warna** berbeda untuk setiap tipe notifikasi

### 4. Integrasi Navigation
Tombol notifikasi dengan badge counter ditambahkan di:
- `beranda_screen.dart` - Header Beranda
- `rt_dashboard_screen.dart` - Header RT Dashboard

## Design Pattern

### Warna dan Icon berdasarkan Tipe
| Tipe | Icon | Warna Background | Warna Icon |
|------|------|-----------------|-----------|
| Order | shopping_bag | Blue (12%) | Blue |
| Message | chat_bubble | Green (15%) | Green |
| Payment | check_circle | Green (15%) | Green |
| Verification | group | Yellow (20%) | Orange |
| Update | info_outline | Orange (15%) | Orange |
| Views | trending_up | Purple (15%) | Purple |

### State Management
- Menggunakan `StatefulWidget` dengan `TabController`
- Loading state untuk tampilkan progress indicator
- Refresh data otomatis setelah kembali dari detail

## Backend Integration (TODO)

### API Endpoints yang Dibutuhkan

#### 1. Get Notifications
```
GET /api/notifications.php?filter=semua|pesanan|pesan
Response:
{
  "success": true,
  "data": [
    {
      "id": "1",
      "title": "Pesanan Dikirim",
      "message": "Pesanan #ORD-12345...",
      "type": "order",
      "time_ago": "5 menit lalu",
      "is_read": 0,
      "order_id": "ORD-12345",
      "sender_id": null
    }
  ]
}
```

#### 2. Mark as Read
```
POST /api/notifications.php
Body: {
  "action": "mark_read",
  "notification_id": "1"
}
Response: { "success": true }
```

#### 3. Mark All as Read
```
POST /api/notifications.php
Body: { "action": "mark_all_read" }
Response: { "success": true }
```

### Database Schema
```sql
CREATE TABLE notifications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type ENUM('order','message','payment','verification','update','views','unread','other'),
  is_read TINYINT(1) DEFAULT 0,
  order_id INT NULL,
  sender_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (sender_id) REFERENCES users(id)
);
```

## Cara Penggunaan

### Navigasi ke Notifikasi Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NotifikasiScreen(),
  ),
);
```

### Menampilkan Badge Counter
Badge counter otomatis muncul di tombol notifikasi ketika ada notifikasi belum dibaca. Counter akan update otomatis setelah user membuka screen notifikasi.

### Custom Action per Tipe
Tambahkan navigation logic di method `_onNotificationTap()`:
```dart
Future<void> _onNotificationTap(NotificationModel notification) async {
  if (!notification.isRead) {
    await _service.markAsRead(notification.id);
    _loadNotifications();
  }
  
  // Navigate berdasarkan tipe
  if (notification.type == NotificationType.order) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => OrderDetailScreen(orderId: notification.orderId!),
    ));
  } else if (notification.type == NotificationType.message) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ChatScreen(userId: notification.senderId!),
    ));
  }
}
```

## Testing

Saat ini menggunakan dummy data dari `NotificationService._getDummyNotifications()`. Data dummy mencakup semua tipe notifikasi untuk testing UI.

## Screenshots Match
Desain UI sudah sesuai dengan screenshot yang diberikan:
- ✅ Header dengan title "Notifikasi" dan counter "2 belum dibaca"
- ✅ Tombol "Tandai Semua" di kanan atas
- ✅ 3 Tabs: Semua, Pesanan, Pesan
- ✅ Card notifikasi dengan icon berwarna di kiri
- ✅ Badge biru untuk notifikasi belum dibaca
- ✅ Time ago di bawah message
- ✅ Border berbeda untuk read/unread

## Future Enhancements
1. Push notifications menggunakan Firebase Cloud Messaging
2. Real-time updates dengan WebSocket
3. Filter lanjutan (by date, by type)
4. Search dalam notifikasi
5. Delete notifikasi
6. Settings untuk notifikasi preferences
