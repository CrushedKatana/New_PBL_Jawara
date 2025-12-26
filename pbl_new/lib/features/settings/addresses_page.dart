import 'package:flutter/material.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat Pengiriman')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AddressCard(
            title: 'Rumah',
            isPrimary: true,
            name: 'Budi Santoso',
            address: 'Jl. Merpati No. 123\nRT 05 / RW 02, Maju Jaya, Sentosa, Jakarta Selatan',
            phone: '+62 812-3456-7890',
          ),
          SizedBox(height: 12),
          _AddressCard(
            title: 'Kantor',
            isPrimary: false,
            name: 'Budi Santoso',
            address: 'Jl. Sudirman No. 456, Gedung Plaza A Lt. 5\nRT 03 / RW 01, Karet, Setiabudi, Jakarta Selatan',
            phone: '+62 812-3456-7890',
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String title;
  final bool isPrimary;
  final String name;
  final String address;
  final String phone;
  const _AddressCard({
    required this.title,
    required this.isPrimary,
    required this.name,
    required this.address,
    required this.phone,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home_outlined),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Text('Utama', style: TextStyle(color: Colors.blue)),
                  ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address),
                  const SizedBox(height: 8),
                  Text(phone),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: const Text('Jadikan Alamat Utama'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
