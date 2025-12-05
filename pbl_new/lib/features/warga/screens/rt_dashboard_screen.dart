import 'package:flutter/material.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../core/services/notification_service.dart';
import 'notifikasi_screen.dart';

class RtDashboardScreen extends StatefulWidget {
  const RtDashboardScreen({super.key, this.rt});
  final String? rt; // misal '05'

  @override
  State<RtDashboardScreen> createState() => _RtDashboardScreenState();
}

class _RtDashboardScreenState extends State<RtDashboardScreen> {
  final DashboardService _service = DashboardService();
  final NotificationService _notificationService = NotificationService();
  DashboardMetrics? _metrics;
  List<ActivityItem> _activities = [];
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _loadUnreadCount();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final metrics = await _service.fetchMetrics(rt: widget.rt);
    final activities = await _service.fetchRecentActivities(rt: widget.rt);
    setState(() {
      _metrics = metrics;
      _activities = activities;
      _loading = false;
    });
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStats(),
                              const SizedBox(height: 32),
                              _buildQuickActions(context),
                              const SizedBox(height: 32),
                              _buildRecentActivities(),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D3ED8), Color(0xFF1435B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dashboard RT ${widget.rt ?? 'XX'}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotifikasiScreen(),
                        ),
                      );
                      _loadUnreadCount();
                    },
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _unreadCount > 9 ? '9+' : '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kelurahan Maju Jaya, RW 02',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final m = _metrics!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _statCard(Icons.group, 'Total Warga', m.totalWarga.toString(), m.wargaGrowth),
            _statCard(Icons.verified, 'Terverifikasi', m.wargaTerverifikasi.toString(), m.wargaGrowth),
            _statCard(Icons.inventory_2, 'Produk Aktif', m.produkAktif.toString(), m.produkGrowth),
            _statCard(Icons.show_chart, 'Transaksi Bulan Ini', m.transaksiBulanIni.toString(), m.transaksiGrowth),
          ],
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, String growth) {
    return Container(
      width: (MediaQuery.of(context).size.width - 20 * 2 - 16 * 3) / 2, // 2 kolom responsif
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3FE3).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF2D3FE3)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.groups,
                title: 'Kelola Warga',
                subtitle: 'Verifikasi & data',
                onTap: () {
                  // TODO: Navigasi ke daftar warga khusus RT
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _quickActionCard(
                icon: Icons.inventory,
                title: 'Approval',
                subtitle: 'Menunggu',
                badge: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
                onTap: () {
                  // TODO: Navigasi ke layar approval
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3FE3).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: const Color(0xFF2D3FE3)),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  badge,
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._activities.map(_activityTile).toList(),
      ],
    );
  }

  Widget _activityTile(ActivityItem item) {
    Color bg;
    IconData icon;
    Color iconColor;
    switch (item.type) {
      case 'warning':
        bg = Colors.yellow.withOpacity(0.15);
        icon = Icons.error_outline;
        iconColor = Colors.orange;
        break;
      case 'register':
        bg = const Color(0xFF2D3FE3).withOpacity(0.15);
        icon = Icons.person_add;
        iconColor = const Color(0xFF2D3FE3);
        break;
      default:
        bg = Colors.green.withOpacity(0.15);
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeAgo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
