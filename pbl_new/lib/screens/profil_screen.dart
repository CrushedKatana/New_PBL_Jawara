import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2D3FE3),
      body: SafeArea(
        child: currentUser == null
            ? const Center(child: Text('Silakan login', style: TextStyle(color: Colors.white)))
            : SingleChildScrollView(
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
                              currentUser.name.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3FE3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentUser.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
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

                          // Info Pribadi
                          _buildSection(
                            'Informasi Pribadi',
                            [
                              _buildInfoTile(Icons.person, 'Nama', currentUser.name),
                              _buildInfoTile(Icons.email, 'Email', currentUser.email),
                              _buildInfoTile(Icons.phone, 'Telepon', currentUser.phone ?? 'Belum diatur'),
                              _buildInfoTile(Icons.home, 'Alamat', currentUser.address ?? 'Belum diatur'),
                            ],
                          ),

                          // Settings
                          _buildSection(
                            'Pengaturan',
                            [
                              ListTile(
                                leading: const Icon(Icons.notifications, color: Color(0xFF2D3FE3)),
                                title: const Text('Notifikasi'),
                                trailing: Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF2D3FE3),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.language, color: Color(0xFF2D3FE3)),
                                title: const Text('Bahasa'),
                                subtitle: const Text('Indonesia'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                              ListTile(
                                leading: const Icon(Icons.security, color: Color(0xFF2D3FE3)),
                                title: const Text('Keamanan'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                            ],
                          ),

                          // Logout Button
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: ElevatedButton(
                              onPressed: () async {
                                await AuthService.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Keluar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2D3FE3)),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
