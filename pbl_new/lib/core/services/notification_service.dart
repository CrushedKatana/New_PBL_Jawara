import 'dart:async';
import '../models/notification_model.dart';

/// Service untuk mengelola notifikasi
class NotificationService {
  // Simple in-memory cache agar operasi tandai semua berpengaruh pada fetch berikutnya.
  static List<NotificationModel>? _cache;

  Future<List<NotificationModel>> _ensureCache() async {
    if (_cache == null) {
      await Future.delayed(const Duration(milliseconds: 150));
      _cache = _getDummyNotifications();
    }
    return _cache!;
  }

  /// Fetch semua notifikasi
  Future<List<NotificationModel>> fetchAllNotifications() async {
    // TODO: Ganti dengan HTTP GET actual.
    final list = await _ensureCache();
    // Return salinan agar UI tidak memodifikasi langsung.
    return List<NotificationModel>.from(list);
  }

  /// Fetch notifikasi berdasarkan filter (Semua, Pesanan, Pesan)
  Future<List<NotificationModel>> fetchNotificationsByFilter(String filter) async {
    final all = await fetchAllNotifications();
    switch (filter.toLowerCase()) {
      case 'pesanan':
        return all.where((n) => n.type == NotificationType.order || n.type == NotificationType.payment).toList();
      case 'pesan':
        return all.where((n) => n.type == NotificationType.message || n.type == NotificationType.unread).toList();
      default:
        return all;
    }
  }

  /// Tandai notifikasi sebagai sudah dibaca
  Future<bool> markAsRead(String notificationId) async {
    final list = await _ensureCache();
    _cache = list.map((n) {
      if (n.id == notificationId) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          timeAgo: n.timeAgo,
          isRead: true,
          orderId: n.orderId,
          senderId: n.senderId,
        );
      }
      return n;
    }).toList();
    // TODO: Kirim ke backend.
    return true;
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<bool> markAllAsRead() async {
    final list = await _ensureCache();
    _cache = list.map((n) => NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          timeAgo: n.timeAgo,
          isRead: true,
          orderId: n.orderId,
          senderId: n.senderId,
        ))
        .toList();
    // TODO: Kirim ke backend.
    return true;
  }

  /// Hitung jumlah notifikasi yang belum dibaca
  Future<int> getUnreadCount() async {
    final list = await fetchAllNotifications();
    return list.where((n) => !n.isRead).length;
  }

  /// Data dummy untuk development
  List<NotificationModel> _getDummyNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Pesanan Dikirim',
        message: 'Pesanan #ORD-12345 sedang dalam perjalanan ke alamat Anda',
        type: NotificationType.order,
        timeAgo: '5 menit lalu',
        isRead: false,
        orderId: 'ORD-12345',
      ),
      NotificationModel(
        id: '2',
        title: 'Pesan Baru dari Penjual',
        message: 'Budi Santoso: \'Barang sudah dikirim hari ini\'',
        type: NotificationType.message,
        timeAgo: '15 menit lalu',
        isRead: false,
        senderId: 'user123',
      ),
      NotificationModel(
        id: '3',
        title: 'Pembayaran Berhasil',
        message: 'Pembayaran untuk pesanan #ORD-12345 telah dikonfirmasi',
        type: NotificationType.payment,
        timeAgo: '1 jam lalu',
        isRead: true,
        orderId: 'ORD-12345',
      ),
      NotificationModel(
        id: '4',
        title: 'Verifikasi RT/RW Disetujui',
        message: 'Status verifikasi Anda telah disetujui oleh RT 05/RW 03',
        type: NotificationType.verification,
        timeAgo: '2 jam lalu',
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Update Aplikasi',
        message: 'Versi baru Jawara tersedia. Update sekarang untuk fitur terbaru',
        type: NotificationType.update,
        timeAgo: '3 jam lalu',
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'Produk Anda Dilihat 25x',
        message: 'Kaos Batik mendapat 25 views minggu ini!',
        type: NotificationType.views,
        timeAgo: '5 jam lalu',
        isRead: true,
      ),
      NotificationModel(
        id: '7',
        title: '3 Pesan Belum Dibaca',
        message: 'Anda memiliki pesan yang belum dibaca dari pembeli',
        type: NotificationType.unread,
        timeAgo: '1 hari lalu',
        isRead: true,
      ),
    ];
  }
}
