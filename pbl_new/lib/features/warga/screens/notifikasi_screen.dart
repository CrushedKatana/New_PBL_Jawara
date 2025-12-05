import 'package:flutter/material.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/notification_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> with SingleTickerProviderStateMixin {
  final NotificationService _service = NotificationService();
  late TabController _tabController;
  
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    
    String filter = 'semua';
    if (_tabController.index == 1) {
      filter = 'pesanan';
    } else if (_tabController.index == 2) {
      filter = 'pesan';
    }
    
    final notifications = await _service.fetchNotificationsByFilter(filter);
    final unread = await _service.getUnreadCount();
    
    setState(() {
      _notifications = notifications;
      _unreadCount = unread;
      _loading = false;
    });
  }

  Future<void> _markAllAsRead() async {
    await _service.markAllAsRead();
    _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca')),
      );
    }
  }

  Future<void> _onNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await _service.markAsRead(notification.id);
      _loadNotifications();
    }
    
    // TODO: Navigate berdasarkan tipe notifikasi
    // if (notification.type == NotificationType.order) {
    //   Navigator.push(context, MaterialPageRoute(
    //     builder: (context) => OrderDetailScreen(orderId: notification.orderId!),
    //   ));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount belum dibaca',
                style: const TextStyle(
                  color: Color(0xFFFF9800),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Tandai Semua',
              style: TextStyle(
                color: Color(0xFF2D3FE3),
                fontSize: 14,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2D3FE3),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2D3FE3),
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.notifications),
              text: 'Semua',
            ),
            Tab(
              icon: Icon(Icons.shopping_bag),
              text: 'Pesanan',
            ),
            Tab(
              icon: Icon(Icons.chat_bubble),
              text: 'Pesan',
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(_notifications[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final config = _getNotificationConfig(notification.type);
    
    return InkWell(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.grey[200]! : const Color(0xFF2D3FE3).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: config['bgColor'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                config['icon'],
                color: config['iconColor'],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D3FE3),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return {
          'icon': Icons.shopping_bag,
          'bgColor': const Color(0xFF2D3FE3).withOpacity(0.12),
          'iconColor': const Color(0xFF2D3FE3),
        };
      case NotificationType.message:
      case NotificationType.unread:
        return {
          'icon': Icons.chat_bubble,
          'bgColor': Colors.green.withOpacity(0.15),
          'iconColor': Colors.green,
        };
      case NotificationType.payment:
        return {
          'icon': Icons.check_circle,
          'bgColor': Colors.green.withOpacity(0.15),
          'iconColor': Colors.green,
        };
      case NotificationType.verification:
        return {
          'icon': Icons.group,
          'bgColor': Colors.yellow.withOpacity(0.2),
          'iconColor': Colors.orange,
        };
      case NotificationType.update:
        return {
          'icon': Icons.info_outline,
          'bgColor': Colors.orange.withOpacity(0.15),
          'iconColor': Colors.orange,
        };
      case NotificationType.views:
        return {
          'icon': Icons.trending_up,
          'bgColor': Colors.purple.withOpacity(0.15),
          'iconColor': Colors.purple,
        };
      default:
        return {
          'icon': Icons.notifications,
          'bgColor': Colors.grey.withOpacity(0.15),
          'iconColor': Colors.grey,
        };
    }
  }
}
