import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});
  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  String visibilitas = 'Semua Orang';
  bool terakhirDilihat = true;
  bool tandaBaca = true;
  bool statusOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('VISIBILITAS PROFIL', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Siapa yang bisa melihat profil saya?', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Atur siapa yang dapat melihat profil Anda', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    for (final opt in ['Semua Orang', 'RT/RW Saya Saja', 'Hanya Saya'])
                      ChoiceChip(
                        label: Text(opt),
                        selected: visibilitas == opt,
                        onSelected: (_) => setState(() => visibilitas = opt),
                      ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('INFORMASI KONTAK', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(child: ListTile(leading: const Icon(Icons.person_outline), title: const Text('Nomor Telepon'), subtitle: const Text('RT/RW Saya Saja'))),
          Card(child: ListTile(leading: const Icon(Icons.place_outlined), title: const Text('Alamat Lengkap'), subtitle: const Text('RT/RW Saya Saja'))),
          const SizedBox(height: 16),
          const Text('STATUS AKTIVITAS', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _switch('Terakhir Dilihat', 'Tampilkan kapan terakhir online', terakhirDilihat, (v) => setState(() => terakhirDilihat = v)),
          _switch('Tanda Baca Pesan', 'Tampilkan saat pesan sudah dibaca', tandaBaca, (v) => setState(() => tandaBaca = v)),
          _switch('Status Online', 'Tampilkan status sedang online', statusOnline, (v) => setState(() => statusOnline = v)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Pengaturan privasi membantu Anda mengontrol informasi yang dibagikan dengan pengguna lain',
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
