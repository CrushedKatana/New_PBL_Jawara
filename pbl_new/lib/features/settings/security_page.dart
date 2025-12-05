import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _sms2fa = false;
  bool _app2fa = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('UBAH PASSWORD', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _PasswordField(label: 'Password Saat Ini', controller: _currentController),
          const SizedBox(height: 12),
          _PasswordField(label: 'Password Baru', controller: _newController),
          const SizedBox(height: 8),
          const Text('Minimal 8 karakter, kombinasi huruf dan angka', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _PasswordField(label: 'Konfirmasi Password Baru', controller: _confirmController),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              // TODO: Integrate with backend change password API.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password diperbarui (dummy)')),
              );
            },
            child: const Text('Ubah Password'),
          ),
          const SizedBox(height: 24),
          const Text('AUTENTIKASI DUA FAKTOR', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _SwitchTile(
            title: 'SMS Authentication',
            subtitle: 'Verifikasi via SMS',
            value: _sms2fa,
            onChanged: (v) => setState(() => _sms2fa = v),
          ),
          _SwitchTile(
            title: 'Authenticator App',
            subtitle: 'Google Authenticator',
            value: _app2fa,
            onChanged: (v) => setState(() => _app2fa = v),
          ),
          const SizedBox(height: 24),
          const Text('AKTIVITAS LOGIN', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _LoginDeviceTile(
            title: 'Perangkat Saat Ini',
            subtitle: 'Chrome • Jakarta, Indonesia\n28 Nov 2025, 14:30',
            trailing: const Chip(label: Text('Aktif')),
          ),
          _LoginDeviceTile(
            title: 'Android Mobile',
            subtitle: 'Chrome • Jakarta, Indonesia\n27 Nov 2025, 09:15',
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout Semua Perangkat'),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  const _PasswordField({required this.label, required this.controller});
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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

class _LoginDeviceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const _LoginDeviceTile({required this.title, required this.subtitle, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.smartphone),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
