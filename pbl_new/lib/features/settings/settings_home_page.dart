import 'package:flutter/material.dart';

class SettingsHomePage extends StatelessWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingsItem(
        title: 'Keamanan',
        subtitle: 'Password & Autentikasi',
        icon: Icons.shield_outlined,
        route: '/settings/security',
      ),
      _SettingsItem(
        title: 'Notifikasi',
        subtitle: 'Jenis, suara & getar',
        icon: Icons.notifications_none,
        route: '/settings/notifications',
      ),
      _SettingsItem(
        title: 'Bahasa',
        subtitle: 'Pilih bahasa aplikasi',
        icon: Icons.language,
        route: '/settings/language',
      ),
      _SettingsItem(
        title: 'Privasi',
        subtitle: 'Visibilitas profil & status',
        icon: Icons.lock_outline,
        route: '/settings/privacy',
      ),
      _SettingsItem(
        title: 'Alamat Pengiriman',
        subtitle: 'Kelola alamat Anda',
        icon: Icons.location_on_outlined,
        route: '/settings/addresses',
      ),
      _SettingsItem(
        title: 'Metode Pembayaran',
        subtitle: 'E-wallet, bank & kartu',
        icon: Icons.account_balance_wallet_outlined,
        route: '/settings/payments',
      ),
      _SettingsItem(
        title: 'Bantuan & Dukungan',
        subtitle: 'Live chat, email, FAQ',
        icon: Icons.help_outline,
        route: '/settings/support',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, item.route),
          );
        },
      ),
    );
  }
}

class _SettingsItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
