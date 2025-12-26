import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});
  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selected = 'id';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Bahasa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Bahasa Aplikasi'),
              subtitle: const Text('Pilih bahasa yang Anda inginkan'),
            ),
          ),
          const SizedBox(height: 12),
          ...[
            _lang('id', 'Bahasa Indonesia', 'Indonesia', '🇮🇩'),
            _lang('en', 'English', 'English', '🇬🇧'),
            _lang('jw', 'Bahasa Jawa', 'Jawa', '🇮🇩'),
            _lang('su', 'Bahasa Sunda', 'Sunda', '🇮🇩'),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text('Perubahan bahasa akan diterapkan setelah aplikasi dimulai ulang',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lang(String code, String title, String subtitle, String flag) {
    final isSelected = selected == code;
    return Card(
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
        onTap: () => setState(() => selected = code),
      ),
    );
  }
}
