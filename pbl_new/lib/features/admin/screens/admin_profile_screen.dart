import 'package:flutter/material.dart';
import 'package:pbl_new/core/services/auth_service.dart';
import 'package:pbl_new/core/services/profile_service.dart';
import 'package:pbl_new/features/auth/screens/login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
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
        content: const Text('Apakah Anda yakin ingin keluar dari admin panel?'),
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
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
    
    return Scaffold(
      backgroundColor: const Color(0xFF2D3FE3),
      body: SafeArea(
        child: Column(
          children: [
            // Header with profile
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
                children: [
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2D3FE3), Color(0xFF1338BE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'BS',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name and role
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData?['name'] ?? currentUser?.name ?? 'Administrator',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userData?['role'] ?? 'Administrator',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Menu Items
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Pengaturan Akun',
                      onTap: () {
                        // Navigate to account settings
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.shield,
                      title: 'ML Analytics',
                      onTap: () {
                        // Navigate to ML Analytics
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.dark_mode,
                      title: 'Mode Gelap',
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {
                          // Toggle dark mode
                        },
                        activeThumbColor: const Color(0xFF2D3FE3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Bantuan & Dukungan',
                      onTap: () {
                        // Navigate to help
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: _handleLogout,
                    ),
                    const SizedBox(height: 32),
                    
                    // App Version
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Jawara Marketplace',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Versi 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
