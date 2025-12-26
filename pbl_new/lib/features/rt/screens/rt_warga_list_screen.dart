import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';
import 'package:pbl_new/core/services/auth_service.dart';

class RtWargaListScreen extends StatefulWidget {
  const RtWargaListScreen({super.key});

  @override
  State<RtWargaListScreen> createState() => _RtWargaListScreenState();
}

class _RtWargaListScreenState extends State<RtWargaListScreen> {
  List<Map<String, dynamic>> _wargaList = [];
  bool _loading = true;
  String _searchQuery = '';
  int _totalWarga = 0;
  int _verifiedWarga = 0;
  int _pendingWarga = 0;
  int _registeredWarga = 0;

  @override
  void initState() {
    super.initState();
    _loadWargaData();
  }

  Future<void> _loadWargaData() async {
    setState(() => _loading = true);
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        setState(() => _loading = false);
        return;
      }

      // Fetch warga by RT
      final response = await http.get(
        Uri.parse('${ApiConfig.usersEndpoint}?role=warga&rt=${currentUser.rt}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final List<dynamic> users = data['data'];
          
          List<Map<String, dynamic>> wargaList = [];
          int verified = 0;
          int pending = 0;
          int registered = 0;

          for (var user in users) {
            final isVerified = (user['verification_status'] == 'verified') || (user['verified'] == 1) || (user['status'] == 'active');
            if (isVerified) verified++;
            if ((user['verification_status'] ?? user['status']) == 'pending') pending++;
            final isRegistered = (user['joined_date'] != null) || (user['is_active'] == 1) || (user['email'] ?? '').toString().isNotEmpty;
            if (isRegistered) registered++;

            wargaList.add({
              'id': user['id'] ?? '',
              'name': user['name'] ?? 'Unknown',
              'address': user['address'] ?? '-',
              'phone': user['phone'] ?? '-',
              'status': isVerified ? 'Terverifikasi' : 'Pending',
              'products': user['product_count'] ?? 0,
              'avatar': (user['name'] ?? 'U')[0].toUpperCase(),
              'verified': isVerified,
              'email': user['email'] ?? '',
              'rt': user['rt'] ?? '',
              'registered': isRegistered,
            });
          }

          if (mounted) {
            setState(() {
              _wargaList = wargaList;
              _totalWarga = wargaList.length;
              _verifiedWarga = verified;
              _pendingWarga = pending;
              _registeredWarga = registered;
              _loading = false;
            });
          }
        } else {
          setState(() => _loading = false);
        }
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error loading warga data: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data warga: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredWargaList {
    if (_searchQuery.isEmpty) return _wargaList;
    return _wargaList
        .where((warga) =>
            warga['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            warga['phone'].toString().contains(_searchQuery) ||
            warga['address'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
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
                      _buildWargaStat(_totalWarga.toString(), 'Total'),
                      _buildWargaStat(_verifiedWarga.toString(), 'Verified'),
                      _buildWargaStat(_pendingWarga.toString(), 'Pending'),
                      _buildWargaStat(_registeredWarga.toString(), 'Terdaftar'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Warga List
                Expanded(
                  child: _filteredWargaList.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Tidak ada warga'
                                : 'Warga tidak ditemukan',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadWargaData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredWargaList.length,
                            itemBuilder: (context, index) {
                              final warga = _filteredWargaList[index];
                              return _buildWargaCard(warga);
                            },
                          ),
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
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 12),
                        Text('Lihat Detail'),
                      ],
                    ),
                    onTap: () {
                      _showWargaDetailDialog(warga);
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit Data'),
                      ],
                    ),
                    onTap: () {
                      _showEditWargaDialog(warga);
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () {
                      _showDeleteConfirmation(warga);
                    },
                  ),
                  if (warga['verified'] == true) PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.undo, size: 20, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Batalkan Verifikasi', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                    onTap: () {
                      _unverifyWarga(warga);
                    },
                  ),
                ],
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
                    _verifyWarga(warga);
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

  void _showWargaDetailDialog(Map<String, dynamic> warga) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail ${warga['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Nama', warga['name']),
              _detailRow('Email', warga['email'] ?? '-'),
              _detailRow('No. Telepon', warga['phone']),
              _detailRow('Alamat', warga['address']),
              _detailRow('RT', warga['rt']),
              _detailRow('Status', warga['status']),
              _detailRow('Jumlah Produk', warga['products'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> warga) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Warga'),
        content: Text('Apakah Anda yakin ingin menghapus ${warga['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${warga['name']} telah dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
              _loadWargaData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyWarga(Map<String, dynamic> warga) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Backend expects user id in query string and field 'verification_status'
      final response = await http.put(
        Uri.parse('${ApiConfig.usersEndpoint}?id=${Uri.encodeComponent(warga['id'])}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'verification_status': 'verified',
          'is_active': 1,
        }),
      ).timeout(ApiConfig.timeout);

      if (mounted) {
        Navigator.pop(context);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${warga['name']} telah diverifikasi'),
              backgroundColor: Colors.green,
            ),
          );
          _loadWargaData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memverifikasi warga'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _unverifyWarga(Map<String, dynamic> warga) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await http.put(
        Uri.parse('${ApiConfig.usersEndpoint}?id=${Uri.encodeComponent(warga['id'])}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'verification_status': 'pending',
          'is_active': 0,
        }),
      ).timeout(ApiConfig.timeout);

      if (mounted) {
        Navigator.pop(context);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verifikasi ${warga['name']} dibatalkan'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadWargaData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membatalkan verifikasi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showEditWargaDialog(Map<String, dynamic> warga) {
    final nameController = TextEditingController(text: warga['name'] ?? '');
    final emailController = TextEditingController(text: warga['email'] ?? '');
    final phoneController = TextEditingController(text: warga['phone'] ?? '');
    final addressController = TextEditingController(text: warga['address'] ?? '');
    final rtController = TextEditingController(text: warga['rt'] ?? '');
    final rwController = TextEditingController(text: warga['rw'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${warga['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Nama', nameController),
              _buildTextField('Email', emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField('No. Telepon', phoneController, keyboardType: TextInputType.phone),
              _buildTextField('Alamat', addressController),
              Row(
                children: [
                  Expanded(child: _buildTextField('RT', rtController)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField('RW', rwController)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitEditWarga(
                warga['id'],
                nameController.text.trim(),
                emailController.text.trim(),
                phoneController.text.trim(),
                addressController.text.trim(),
                rtController.text.trim(),
                rwController.text.trim(),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _submitEditWarga(
    String id,
    String name,
    String email,
    String phone,
    String address,
    String rt,
    String rw,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final body = {
        if (name.isNotEmpty) 'name': name,
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone': phone,
        if (address.isNotEmpty) 'address': address,
        if (rt.isNotEmpty) 'rt': rt,
        if (rw.isNotEmpty) 'rw': rw,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.usersEndpoint}?id=${Uri.encodeComponent(id)}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(ApiConfig.timeout);

      if (mounted) {
        Navigator.pop(context);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data warga berhasil diperbarui'), backgroundColor: Colors.green),
          );
          _loadWargaData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui data warga'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
