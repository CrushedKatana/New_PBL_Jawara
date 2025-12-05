import 'package:flutter/material.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _PaymentCard(
            title: 'GoPay',
            subtitle: '0812-****-7890',
            badge: 'Utama',
            leadingIcon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          const _PaymentCard(
            title: 'OVO',
            subtitle: '0812-****-7890',
            leadingIcon: Icons.wallet,
          ),
          const SizedBox(height: 12),
          const _PaymentCard(
            title: 'BCA',
            subtitle: '****-****-1234',
            leadingIcon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 16),
          const Text('TAMBAH METODE BARU', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const _AddMethodTile(title: 'Tambah E-Wallet', subtitle: 'GoPay, OVO, Dana, LinkAja', icon: Icons.account_balance_wallet_outlined),
          const _AddMethodTile(title: 'Tambah Bank', subtitle: 'Transfer bank lokal', icon: Icons.account_balance_outlined),
          const _AddMethodTile(title: 'Tambah Kartu', subtitle: 'Kartu kredit atau debit', icon: Icons.credit_card),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text('Semua transaksi dilindungi dengan enkripsi SSL dan sistem keamanan berlapis',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final IconData leadingIcon;
  const _PaymentCard({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.leadingIcon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(leadingIcon),
        title: Row(
          children: [
            Text(title),
            const SizedBox(width: 8),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(badge!, style: const TextStyle(color: Colors.blue)),
              ),
          ],
        ),
        subtitle: Text(subtitle),
        trailing: Wrap(spacing: 8, children: const [
          Icon(Icons.edit_outlined),
          Icon(Icons.delete_outline, color: Colors.red),
        ]),
      ),
    );
  }
}

class _AddMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _AddMethodTile({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {},
      ),
    );
  }
}
