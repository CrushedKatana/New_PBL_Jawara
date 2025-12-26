import 'package:flutter/material.dart';

import '../../../core/services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loadingStats = true;
  String? _statsError;

  final List<Map<String, dynamic>> _rtPerformance = [];
  bool _loadingRt = true;
  String? _rtError;

  final List<Map<String, dynamic>> _systemStatus = [
    {'name': 'PCVK Model', 'status': 'Active', 'color': Colors.green},
    {'name': 'Database', 'status': 'Healthy', 'color': Colors.green},
    {'name': 'API Server', 'status': 'Running', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadRtPerformance();
    _loadSystemStatus();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loadingStats = true;
      _statsError = null;
    });
    try {
      final data = await AdminService.getGlobalStats();
      if (!mounted) return;
      setState(() {
        _stats = {
          'totalWarga': data['totalWarga'] ?? 0,
          'totalProduk': data['totalProduk'] ?? 0,
          'totalTransaksi': data['totalTransaksi'] ?? 0,
          'gmv': data['gmv'] ?? 0.0,
          // Growth placeholders until backend provides deltas
          'wargaGrowth': '+',
          'produkGrowth': '+',
          'transaksiGrowth': '+',
          'gmvGrowth': '+',
        };
        _loadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statsError = 'Gagal memuat statistik';
        _loadingStats = false;
      });
    }
  }

  Future<void> _loadRtPerformance() async {
    setState(() {
      _loadingRt = true;
      _rtError = null;
    });
    final data = await AdminService.getRtPerformance();
    if (!mounted) return;
    setState(() {
      _rtPerformance.clear();
      _rtPerformance.addAll(data);
      _loadingRt = false;
      if (_rtPerformance.isEmpty) {
        _rtError = 'Tidak ada data RT';
      }
    });
  }

  Future<void> _loadSystemStatus() async {
    final data = await AdminService.getSystemStatus();
    if (!mounted) return;
    setState(() {
      _systemStatus.clear();
      for (final s in data) {
        final status = s['status']?.toString() ?? 'Unknown';
        Color color;
        switch (status.toLowerCase()) {
          case 'active':
          case 'healthy':
          case 'running':
            color = Colors.green;
            break;
          case 'degraded':
            color = Colors.orange;
            break;
          case 'down':
          default:
            color = Colors.red;
        }
        _systemStatus.add({
          'name': s['name'] ?? 'Service',
          'status': status,
          'color': color,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasStats = !_loadingStats && _statsError == null && _stats != null;

    return Scaffold(
      backgroundColor: const Color(0xFF2D3FE3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1338BE), Color(0xFF2D3FE3)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelurahan Maju Jaya',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistik Global',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          if (_loadingStats)
                            ...List.generate(4, (i) => _buildStatCard(
                                  icon: Icons.hourglass_empty,
                                  title: 'Memuat...',
                                  value: '-',
                                  growth: '-',
                                  color: const Color(0xFF2D3FE3),
                                ))
                          else if (_statsError != null || _stats == null)
                            ...[
                              _buildStatCard(
                                icon: Icons.error,
                                title: 'Error',
                                value: '—',
                                growth: '—',
                                color: Colors.red,
                              ),
                            ]
                          else ...[
                            _buildStatCard(
                              icon: Icons.group,
                              title: 'Total Warga',
                              value: (_stats!['totalWarga']).toString(),
                              growth: _stats!['wargaGrowth'].toString(),
                              color: const Color(0xFF2D3FE3),
                            ),
                            _buildStatCard(
                              icon: Icons.shopping_bag,
                              title: 'Total Produk',
                              value: (_stats!['totalProduk']).toString(),
                              growth: _stats!['produkGrowth'].toString(),
                              color: const Color(0xFF2D3FE3),
                            ),
                            _buildStatCard(
                              icon: Icons.trending_up,
                              title: 'Transaksi',
                              value: (_stats!['totalTransaksi']).toString(),
                              growth: _stats!['transaksiGrowth'].toString(),
                              color: const Color(0xFF2D3FE3),
                            ),
                            _buildStatCard(
                              icon: Icons.attach_money,
                              title: 'GMV Bulan Ini',
                              value: '${_stats!['gmv']}M',
                              growth: _stats!['gmvGrowth'].toString(),
                              color: const Color(0xFF2D3FE3),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Management Section
                      const Text(
                        'Manajemen',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildManagementCard(
                            icon: Icons.group,
                            title: 'Kelola User',
                            subtitle: hasStats
                                ? '${_stats!['totalWarga']} akun'
                                : 'Memuat...',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserManagementScreen(),
                                ),
                              );
                            },
                          ),
                          _buildManagementCard(
                            icon: Icons.assessment,
                            title: 'RT/RW',
                            subtitle: _rtPerformance.isNotEmpty
                                ? '${_rtPerformance.length} RT aktif'
                                : 'Memuat...',
                            badge: _rtPerformance.isNotEmpty
                                ? const SizedBox.shrink()
                                : null,
                          ),
                          _buildManagementCard(
                            icon: Icons.show_chart,
                            title: 'ML Analytics',
                            subtitle: 'PCVK model',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MLAnalyticsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildManagementCard(
                            icon: Icons.warning,
                            title: 'Laporan',
                            subtitle: '2 pending',
                            badge: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // RT Performance
                      const Text(
                        'Performa RT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _loadingRt
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildTableHeader('Memuat...'),
                                    const SizedBox(height: 8),
                                    ...List.generate(3, (i) => Row(
                                          children: [
                                            Expanded(child: Container(height: 24, color: Colors.grey[200])),
                                            const SizedBox(width: 8),
                                            Expanded(child: Container(height: 24, color: Colors.grey[200])),
                                            const SizedBox(width: 8),
                                            Expanded(child: Container(height: 24, color: Colors.grey[200])),
                                            const SizedBox(width: 8),
                                            Expanded(child: Container(height: 24, color: Colors.grey[200])),
                                          ],
                                        )),
                                  ],
                                ),
                              )
                            : _rtError != null
                                ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(_rtError!),
                                  )
                                : Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(1.5),
                                      2: FlexColumnWidth(1.5),
                                      3: FlexColumnWidth(1.5),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        children: [
                                          _buildTableHeader('RT'),
                                          _buildTableHeader('Warga'),
                                          _buildTableHeader('Produk'),
                                          _buildTableHeader('Transaksi'),
                                        ],
                                      ),
                                      ..._rtPerformance.map((rt) => TableRow(
                                            children: [
                                              _buildTableCell(rt['rt'].toString()),
                                              _buildTableCell(rt['warga'].toString()),
                                              _buildTableCell(rt['produk'].toString()),
                                              _buildTableCell(rt['transaksi'].toString()),
                                            ],
                                          )),
                                    ],
                                  ),
                      ),

                      const SizedBox(height: 32),

                      // System Status
                      const Text(
                        'Status Sistem',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ..._systemStatus.map((status) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  status['name'].toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (status['color'] as Color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status['status'].toString(),
                                    style: TextStyle(
                                      color: status['color'] as Color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 32),

                      // ML Statistics Quick Access
                      const Text(
                        'Klasifikasi PCVK (ML)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/ml_statistics');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D3FE3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart,
                                    size: 32,
                                    color: Color(0xFF2D3FE3),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Statistik Klasifikasi PCVK',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Model HOG+SVM - Hat, Shirt, Shoes, T-Shirt',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String growth,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2D3FE3), size: 24),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  badge,
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// User Management Screen
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loadingUsers = true;
  String? _usersError;
  String _roleFilter = 'all'; // all|warga|rt|rw|admin

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loadingUsers = true;
      _usersError = null;
    });
    final roleParam = _roleFilter == 'all' ? null : _roleFilter;
    final result = await AdminService.getUsers(role: roleParam);
    if (!mounted) return;
    setState(() {
      _users = result;
      _loadingUsers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari user...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),

          // Role Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Warga', 'warga'),
                const SizedBox(width: 8),
                _buildFilterChip('RT/RW', 'rt'),
                const SizedBox(width: 8),
                _buildFilterChip('Admin', 'admin'),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserStat(_users.length.toString(), 'Total'),
                _buildUserStat(
                  _users.where((u) => (u['role']?.toString().toLowerCase() ?? '') == 'warga').length.toString(),
                  'Warga',
                ),
                _buildUserStat(
                  _users.where((u) {
                    final r = (u['role']?.toString().toLowerCase() ?? '');
                    return r == 'rt' || r == 'rw' || r.contains('rt officer');
                  }).length.toString(),
                  'RT/RW',
                ),
                _buildUserStat(
                  _users.where((u) => (u['role']?.toString().toLowerCase() ?? '') == 'admin').length.toString(),
                  'Admin',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _loadingUsers ? 6 : _users.length,
              itemBuilder: (context, index) {
                if (_loadingUsers) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 16, color: Colors.grey[200]),
                              const SizedBox(height: 8),
                              Container(height: 14, color: Colors.grey[200]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final user = _users[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _roleFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _roleFilter = value;
        });
        _loadUsers();
      },
    );
  }

  Widget _buildUserStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final roleRaw = (user['role'] ?? user['user_role'] ?? '').toString();
    final role = roleRaw.isEmpty ? 'warga' : roleRaw;
    final isRTOfficer = role.toLowerCase().contains('rt');
    final isAdmin = role.toLowerCase() == 'admin';
    final statusRaw = (user['status'] ?? user['is_active'] ?? 'Active').toString();
    final isSuspended = statusRaw.toLowerCase() == 'suspended' || statusRaw == '0';
    final name = (user['name'] ?? user['full_name'] ?? user['username'] ?? 'Tanpa Nama').toString();
    final rt = (user['rt'] ?? user['rt_id'] ?? '').toString();
    final joined = (user['joined'] ?? user['created_at'] ?? '').toString();
    final avatar = user['avatar']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isAdmin
                  ? Colors.purple.withOpacity(0.1)
                  : isRTOfficer
                      ? const Color(0xFF2D3FE3).withOpacity(0.1)
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: user['avatar'] != null
                  ? Text(
                      user['avatar'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(
                      isAdmin ? Icons.shield : Icons.person,
                      color: isAdmin
                          ? Colors.purple
                          : isRTOfficer
                              ? const Color(0xFF2D3FE3)
                              : Colors.grey[600],
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isRTOfficer)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3FE3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'RT Officer',
                          style: TextStyle(
                            color: Color(0xFF2D3FE3),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (rt.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        rt,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSuspended
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSuspended ? 'Suspended' : 'Active',
                        style: TextStyle(
                          color: isSuspended ? Colors.red : Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      joined.isEmpty ? '-' : joined,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              // Placeholder for actions: view, suspend, promote, etc.
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('Lihat Detail')),
              PopupMenuItem(
                value: isSuspended ? 'activate' : 'suspend',
                child: Text(isSuspended ? 'Aktifkan' : 'Suspend'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ML Analytics Screen
class MLAnalyticsScreen extends StatelessWidget {
  const MLAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ML Analytics - PCVK',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Model Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Performance Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildMetricCard(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  value: '81.4%',
                  label: 'Validation Acc',
                ),
                _buildMetricCard(
                  icon: Icons.bolt,
                  color: const Color(0xFF2D3FE3),
                  value: '1991',
                  label: 'Training Images',
                ),
                _buildMetricCard(
                  icon: Icons.category,
                  color: Colors.orange,
                  value: '4',
                  label: 'Kategori',
                ),
                _buildMetricCard(
                  icon: Icons.model_training,
                  color: Colors.purple,
                  value: '100%',
                  label: 'Train Accuracy',
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Akurasi per Kategori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildCategoryAccuracy(),

            const SizedBox(height: 32),

            const Text(
              'Distribusi Deteksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildDistributionChart(),

            const SizedBox(height: 32),

            const Text(
              'Confusion Matrix (Preview)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildConfusionMatrix(),

            const SizedBox(height: 32),

            const Text(
              'Deteksi Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildRecentDetections(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAccuracy() {
    // Data dari training dataset yang sebenarnya
    final Map<String, Map<String, dynamic>> categories = {
      'T-Shirt': {'samples': 1011, 'percentage': 50.8},
      'Sepatu': {'samples': 431, 'percentage': 21.6},
      'Kemeja': {'samples': 378, 'percentage': 19.0},
      'Topi': {'samples': 171, 'percentage': 8.6},
    };
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: categories.entries.map((entry) {
          final category = entry.key;
          final data = entry.value;
          final samples = data['samples'] as int;
          final percentage = data['percentage'] as double;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$samples gambar (${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2D3FE3),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDistributionChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Training Dataset Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'T-Shirt: 50.8% (1011 images)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3FE3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sepatu: 21.6% (431) • Kemeja: 19.0% (378) • Topi: 8.6% (171)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Total: 1991 training images',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfusionMatrix() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Model: LinearSVC (HOG + SVM)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildModelInfoRow('Training Accuracy', '100.0%', Colors.green),
          _buildModelInfoRow('Validation Accuracy', '81.4%', Colors.blue),
          _buildModelInfoRow('Training Samples', '1393', Colors.orange),
          _buildModelInfoRow('Validation Samples', '199', Colors.purple),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Last trained: December 11, 2025',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDetections() {
    final detections = [
      {'name': 'T-Shirt', 'time': '2 menit lalu', 'confidence': '96.5%'},
      {'name': 'Kemeja', 'time': '5 menit lalu', 'confidence': '94.2%'},
      {'name': 'Sepatu', 'time': '10 menit lalu', 'confidence': '98.1%'},
      {'name': 'Jaket', 'time': '15 menit lalu', 'confidence': '92.7%'},
    ];

    return Column(
      children: detections.map((detection) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detection['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detection['time']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                detection['confidence']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
