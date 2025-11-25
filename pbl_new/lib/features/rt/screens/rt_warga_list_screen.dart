import 'package:flutter/material.dart';

class RtWargaListScreen extends StatefulWidget {
  const RtWargaListScreen({super.key});

  @override
  State<RtWargaListScreen> createState() => _RtWargaListScreenState();
}

class _RtWargaListScreenState extends State<RtWargaListScreen> {
  final _wargaList = [
    {
      'name': 'Ibu Siti Aminah',
      'address': 'Jl. Melati No. 12',
      'phone': '0812-3456-7890',
      'status': 'Terverifikasi',
      'products': 5,
      'avatar': 'I',
      'verified': true,
    },
    {
      'name': 'Pak Budi Santoso',
      'address': 'Jl. Melati No. 15',
      'phone': '0813-4567-8901',
      'status': 'Terverifikasi',
      'products': 3,
      'avatar': 'P',
      'verified': true,
    },
    {
      'name': 'Dimas Pratama',
      'address': 'Jl. Mawar No. 8',
      'phone': '0814-5678-9012',
      'status': 'Pending',
      'products': 2,
      'avatar': 'D',
      'verified': false,
    },
    {
      'name': 'Sari Wulandari',
      'address': 'Jl. Anggrek No. 20',
      'phone': '0815-6789-0123',
      'status': 'Terverifikasi',
      'products': 7,
      'avatar': 'S',
      'verified': true,
    },
    {
      'name': 'Ahmad Fauzi',
      'address': 'Jl. Dahlia No. 5',
      'phone': '0816-7890-1234',
      'status': 'Pending',
      'products': 1,
      'avatar': 'A',
      'verified': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftar Warga',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari warga...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWargaStat('142', 'Total'),
                _buildWargaStat('138', 'Verified'),
                _buildWargaStat('4', 'Pending'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Warga List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _wargaList.length,
              itemBuilder: (context, index) {
                final warga = _wargaList[index];
                return _buildWargaCard(warga);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWargaStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWargaCard(Map<String, dynamic> warga) {
    final isPending = warga['status'] == 'Pending';
    final isVerified = warga['verified'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFF2D3FE3),
                child: Text(
                  warga['avatar'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            warga['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 18,
                            color: Color(0xFF2D3FE3),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      warga['address'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      warga['phone'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPending
                            ? Colors.yellow.withValues(alpha: 0.2)
                            : Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        warga['status'],
                        style: TextStyle(
                          color: isPending ? Colors.orange : Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jualan',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${warga['products']} produk',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending)
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${warga['name']} telah diverifikasi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3FE3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Verifikasi'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
