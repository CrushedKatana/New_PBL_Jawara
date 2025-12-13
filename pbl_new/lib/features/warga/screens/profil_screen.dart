import 'package:flutter/material.dart';
import 'package:pbl_new/core/services/auth_service.dart';
import 'package:pbl_new/core/services/profile_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _statsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    // Load profile and stats in parallel
    final results = await Future.wait([
      ProfileService.getUserProfile(int.parse(currentUser.id)),
      ProfileService.getUserStats(int.parse(currentUser.id)),
    ]);

    if (mounted) {
      setState(() {
        _profileData = results[0];
        _statsData = results[1];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF2D3FE3),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final userData = _profileData?['user'];
    final stats = _statsData?['stats'];

    return Scaffold(
      backgroundColor: const Color(0xFF2D3FE3),
      body: SafeArea(
        child: currentUser == null
            ? const Center(child: Text('Silakan login', style: TextStyle(color: Colors.white)))
            : RefreshIndicator(
                onRefresh: _loadProfileData,
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Profil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),

                          // Profile Card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundColor: const Color(0xFF2D3FE3),
                                      child: Text(
                                        currentUser.name.substring(0, 2).toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userData?['name'] ?? currentUser.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            userData?['role'] ?? 'Warga',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFF2D3FE3),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Status Verifikasi',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (userData?['is_verified'] == 1)
                                              ? Colors.green[100]
                                              : Colors.orange[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          (userData?['is_verified'] == 1)
                                              ? 'Terverifikasi'
                                              : 'Pending',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: (userData?['is_verified'] == 1)
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Wilayah',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userData?['address'] ?? currentUser.address ?? 'Alamat belum diatur',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (userData?['rt_number'] != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'RT ${userData['rt_number']} / RW ${userData['rw_number'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Stats
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  Icons.shopping_bag,
                                  '${stats?['total_sold'] ?? 0}',
                                  'Terjual',
                                ),
                                _buildStatItem(
                                  Icons.favorite,
                                  '${stats?['total_favorites'] ?? 0}',
                                  'Favorit',
                                ),
                                _buildStatItem(
                                  Icons.star,
                                  '${stats?['avg_rating'] ?? 0}',
                                  'Rating',
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          // Settings
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3FE3).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.settings, color: Color(0xFF2D3FE3)),
                            ),
                            title: const Text('Pengaturan Akun'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),

                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.dark_mode),
                            ),
                            title: const Text('Mode Gelap'),
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {},
                              activeThumbColor: const Color(0xFF2D3FE3),
                            ),
                          ),

                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.help_outline),
                            ),
                            title: const Text('Bantuan & Dukungan'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),

                          const SizedBox(height: 20),

                          // Logout Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: OutlinedButton.icon(
                              onPressed: _handleLogout,
                              icon: const Icon(Icons.logout, color: Colors.red),
                              label: const Text(
                                'Keluar',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Footer
                          const Text(
                            'Jawara Marketplace',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Versi 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2D3FE3), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
