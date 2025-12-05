import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final Map<String, dynamic> _stats = {
    'totalWarga': 702,
    'totalProduk': 349,
    'totalTransaksi': 1400,
    'gmv': 52.4,
    'wargaGrowth': '+12',
    'produkGrowth': '+23',
    'transaksiGrowth': '+15%',
    'gmvGrowth': '+8%',
  };

  final List<Map<String, dynamic>> _rtPerformance = [
    {'rt': 'RT 01', 'warga': 156, 'produk': 89, 'transaksi': 342},
    {'rt': 'RT 02', 'warga': 134, 'produk': 67, 'transaksi': 278},
    {'rt': 'RT 03', 'warga': 142, 'produk': 72, 'transaksi': 301},
    {'rt': 'RT 04', 'warga': 128, 'produk': 54, 'transaksi': 245},
    {'rt': 'RT 05', 'warga': 142, 'produk': 67, 'transaksi': 234},
  ];

  final List<Map<String, dynamic>> _systemStatus = [
    {'name': 'PCVK Model', 'status': 'Active', 'color': Colors.green},
    {'name': 'Database', 'status': 'Healthy', 'color': Colors.green},
    {'name': 'API Server', 'status': 'Running', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
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
                          _buildStatCard(
                            icon: Icons.group,
                            title: 'Total Warga',
                            value: _stats['totalWarga'].toString(),
                            growth: _stats['wargaGrowth'].toString(),
                            color: const Color(0xFF2D3FE3),
                          ),
                          _buildStatCard(
                            icon: Icons.shopping_bag,
                            title: 'Total Produk',
                            value: _stats['totalProduk'].toString(),
                            growth: _stats['produkGrowth'].toString(),
                            color: const Color(0xFF2D3FE3),
                          ),
                          _buildStatCard(
                            icon: Icons.trending_up,
                            title: 'Transaksi',
                            value: _stats['totalTransaksi'].toString(),
                            growth: _stats['transaksiGrowth'].toString(),
                            color: const Color(0xFF2D3FE3),
                          ),
                          _buildStatCard(
                            icon: Icons.attach_money,
                            title: 'GMV Bulan Ini',
                            value: '${_stats['gmv']}M',
                            growth: _stats['gmvGrowth'].toString(),
                            color: const Color(0xFF2D3FE3),
                          ),
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
                            subtitle: '702 akun',
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
                            subtitle: '5 RT aktif',
                            badge: const SizedBox.shrink(),
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
                        child: Table(
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
  final _users = [
    {
      'name': 'Ibu Siti Aminah',
      'role': 'Warga',
      'rt': 'RT 05',
      'status': 'Active',
      'joined': 'Joined Jan 2024',
      'avatar': 'I',
    },
    {
      'name': 'Pak Budi RT 05',
      'role': 'RT Officer',
      'rt': 'RT 05',
      'status': 'Active',
      'joined': 'Joined Des 2023',
      'avatar': null,
    },
    {
      'name': 'Admin Kelurahan',
      'role': 'Admin',
      'rt': '',
      'status': 'Active',
      'joined': 'Joined Nov 2023',
      'avatar': null,
    },
    {
      'name': 'Dimas Pratama',
      'role': 'Warga',
      'rt': 'RT 02',
      'status': 'Active',
      'joined': 'Joined Feb 2024',
      'avatar': 'D',
    },
    {
      'name': 'Sari Wulandari',
      'role': 'Warga',
      'rt': 'RT 03',
      'status': 'Active',
      'joined': 'Joined Mar 2024',
      'avatar': 'S',
    },
    {
      'name': 'Pak Ahmad RT 01',
      'role': 'RT Officer',
      'rt': 'RT 01',
      'status': 'Active',
      'joined': 'Joined Des 2023',
      'avatar': null,
    },
    {
      'name': 'Toko Sepatu Jaya',
      'role': 'Warga',
      'rt': 'RT 01',
      'status': 'Suspended',
      'joined': 'Joined Jan 2024',
      'avatar': 'T',
    },
  ];

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

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserStat('702', 'Total'),
                _buildUserStat('685', 'Warga'),
                _buildUserStat('15', 'RT/RW'),
                _buildUserStat('2', 'Admin'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
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
    final isRTOfficer = user['role'] == 'RT Officer';
    final isAdmin = user['role'] == 'Admin';
    final isSuspended = user['status'] == 'Suspended';

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
                  user['name'],
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
                        user['role'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (user['rt'].toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        user['rt'],
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
                        user['status'],
                        style: TextStyle(
                          color: isSuspended ? Colors.red : Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user['joined'],
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show menu
            },
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
                  value: '92.4%',
                  label: 'Akurasi Global',
                ),
                _buildMetricCard(
                  icon: Icons.bolt,
                  color: const Color(0xFF2D3FE3),
                  value: '758',
                  label: 'Total Deteksi',
                ),
                _buildMetricCard(
                  icon: Icons.speed,
                  color: Colors.orange,
                  value: '0.3s',
                  label: 'Avg Response',
                ),
                _buildMetricCard(
                  icon: Icons.trending_up,
                  color: Colors.purple,
                  value: '+8.2%',
                  label: 'Improvement',
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
    final categories = [
      'T-Shirt',
      'Kemeja',
      'Topi',
      'Sepatu',
      'Jaket'
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: categories.map((category) {
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
                    const Text(
                      '~95%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.95,
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
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'T-Shirt 32%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3FE3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kemeja 23% • Sepatu 18% • Topi 12%',
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

  Widget _buildConfusionMatrix() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Confusion Matrix visualization\n(High accuracy across all categories)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
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
