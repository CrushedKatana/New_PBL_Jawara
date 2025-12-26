import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool pesanan = true;
  bool pesanChat = true;
  bool komunitas = true;
  bool statistikProduk = false;
  bool promosi = false;
  bool suara = true;
  bool getar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('JENIS NOTIFIKASI', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _switch('Pesanan & Transaksi', 'Update status pesanan, pembayaran, dan pengiriman', pesanan, (v) => setState(() => pesanan = v)),
          _switch('Pesan & Chat', 'Notifikasi pesan baru dari pembeli atau penjual', pesanChat, (v) => setState(() => pesanChat = v)),
          _switch('Komunitas RT/RW', 'Update verifikasi dan pengumuman komunitas', komunitas, (v) => setState(() => komunitas = v)),
          _switch('Statistik Produk', 'Laporan views, favorit, dan performa produk', statistikProduk, (v) => setState(() => statistikProduk = v)),
          _switch('Promosi & Penawaran', 'Informasi promo, diskon, dan penawaran khusus', promosi, (v) => setState(() => promosi = v)),
          const SizedBox(height: 24),
          const Text('SUARA & GETAR', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _switch('Suara Notifikasi', 'Aktifkan suara saat notifikasi masuk', suara, (v) => setState(() => suara = v)),
          _switch('Getar', 'Aktifkan getaran untuk notifikasi', getar, (v) => setState(() => getar = v)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Notifikasi penting seperti keamanan akun akan tetap aktif untuk melindungi akun Anda',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
