import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan & Dukungan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari pertanyaan atau topik...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          const Text('HUBUNGI KAMI', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _contactCard('Live Chat', 'Respon dalam 5 menit', trailing: TextButton(onPressed: () {}, child: const Text('Mulai Chat'))),
          _contactCard('Email Support', 'support@jawara.id', trailing: TextButton(onPressed: () {}, child: const Text('Kirim Email'))),
          _contactCard('Telepon', '+62 21 1234 5678', trailing: TextButton(onPressed: () {}, child: const Text('Hubungi Kami'))),
          const SizedBox(height: 16),
          const Text('Akun & Profil', style: TextStyle(fontWeight: FontWeight.w600)),
          _faqItem('Bagaimana cara mengubah profil saya?'),
          _faqItem('Lupa password, apa yang harus dilakukan?'),
          _faqItem('Bagaimana cara verifikasi RT/RW?'),
          _faqItem('Cara mengganti nomor telepon'),
          const SizedBox(height: 16),
          const Text('Transaksi & Pembayaran', style: TextStyle(fontWeight: FontWeight.w600)),
          _faqItem('Metode pembayaran apa saja yang tersedia?'),
          _faqItem('Bagaimana cara membatalkan pesanan?'),
          _faqItem('Berapa lama proses refund?'),
          _faqItem('Tidak menerima konfirmasi pembayaran'),
          const SizedBox(height: 16),
          const Text('Jual & Beli', style: TextStyle(fontWeight: FontWeight.w600)),
          _faqItem('Bagaimana cara menjual produk?'),
          _faqItem('Apa itu PCVK image identification?'),
          _faqItem('Bagaimana cara mengatur harga?'),
          _faqItem('Tips agar produk cepat terjual'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Jam Operasional', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Senin - Jumat      09:00 - 18:00 WIB'),
                  Text('Sabtu - Minggu     09:00 - 15:00 WIB'),
                  SizedBox(height: 4),
                  Text('Live Chat          24/7 Online', style: TextStyle(color: Colors.green)),
                  SizedBox(height: 8),
                  Text('Jawara Marketplace v1.0.0'),
                  Text('© 2025 Komunitas RT/RW Indonesia'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(String title, String subtitle, {Widget? trailing}) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.support_agent),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }

  Widget _faqItem(String title) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
