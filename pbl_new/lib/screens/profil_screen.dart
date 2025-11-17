import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2D3FE3),
      body: SafeArea(
        child: currentUser == null
            ? const Center(child: Text('Silakan login', style: TextStyle(color: Colors.white)))
            : FutureBuilder<UserModel?>(
                future: _authService.getUserData(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final user = snapshot.data;
                  if (user == null) {
                    return const Center(child: Text('User tidak ditemukan', style: TextStyle(color: Colors.white)));
                  }

                  return SingleChildScrollView(
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
                              const SizedBox(height: 24),
                              // Profile Picture
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Text(
                                  user.name.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3FE3),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (user.isVerified) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.verified, color: Colors.white, size: 20),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.role == 'warga' ? 'Warga' : user.role,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Verification Status
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      user.isVerified ? Icons.check_circle : Icons.info_outline,
                                      color: user.isVerified ? Colors.green : Colors.orange,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Status Verifikasi',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: user.isVerified ? Colors.green[50] : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        user.isVerified ? 'Terverifikasi' : 'Belum Verifikasi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: user.isVerified ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Wilayah
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Wilayah',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.rtRw ?? '-',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stats
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildStatCard(
                                    icon: Icons.inventory_2,
                                    label: 'Terjual',
                                    value: user.productsSold.toString(),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    icon: Icons.favorite,
                                    label: 'Favorit',
                                    value: user.favoriteCount.toString(),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStatCard(
                                    icon: Icons.star,
                                    label: 'Rating',
                                    value: user.rating.toStringAsFixed(1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 8),

                              // Menu Items
                              _buildMenuItem(
                                icon: Icons.settings,
                                title: 'Pengaturan Akun',
                                onTap: () {},
                              ),
                              _buildMenuItem(
                                icon: Icons.brightness_4,
                                title: 'Mode Gelap',
                                trailing: Switch(
                                  value: false,
                                  onChanged: (value) {},
                                  activeColor: const Color(0xFF2D3FE3),
                                ),
                              ),
                              _buildMenuItem(
                                icon: Icons.help_outline,
                                title: 'Bantuan & Dukungan',
                                onTap: () {},
                              ),
                              const SizedBox(height: 16),
                              _buildMenuItem(
                                icon: Icons.logout,
                                title: 'Keluar',
                                textColor: Colors.red,
                                onTap: () async {
                                  await _authService.signOut();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Berhasil logout')),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Jawara Marketplace',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const Text(
                                'Versi 1.0.0',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2D3FE3), size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3FE3),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
