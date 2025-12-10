import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl_new/core/models/product_model.dart';
import 'package:pbl_new/core/services/auth_service.dart';
import 'package:pbl_new/core/services/product_service.dart';

import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class JualanScreen extends StatefulWidget {
  const JualanScreen({super.key});

  @override
  State<JualanScreen> createState() => _JualanScreenState();
}

class _JualanScreenState extends State<JualanScreen> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2D3FE3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jualan Saya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kelola produk yang Anda jual',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Cards
            if (currentUser != null)
              FutureBuilder<List<ProductModel>>(
                future: _productService.getProducts(sellerId: currentUser.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final products = snapshot.data!;
                  final aktif = products.where((p) => p.isActive).length;
                  final pending = products.where((p) => !p.isActive).length;
                  final terjual = 0; // Belum ada tracking penjualan

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildStatCard('Aktif', aktif.toString(), Colors.green),
                        const SizedBox(width: 12),
                        _buildStatCard('Pending', pending.toString(), Colors.orange),
                        const SizedBox(width: 12),
                        _buildStatCard('Terjual', terjual.toString(), Colors.blue),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // Add Product Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Produk Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D3FE3),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Products List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF2D3FE3),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF2D3FE3),
                      tabs: const [
                        Tab(text: 'Aktif'),
                        Tab(text: 'Pending'),
                        Tab(text: 'Terjual'),
                      ],
                    ),
                    Expanded(
                      child: currentUser == null
                          ? const Center(child: Text('Silakan login terlebih dahulu'))
                          : FutureBuilder<List<ProductModel>>(
                              future: _productService.getProducts(sellerId: currentUser.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text('Belum ada produk'),
                                  );
                                }

                                return TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildProductList(
                                      snapshot.data!.where((p) => p.isActive).toList(),
                                    ),
                                    _buildProductList(
                                      snapshot.data!.where((p) => !p.isActive).toList(),
                                    ),
                                    _buildProductList(
                                      [], // No sold products tracking yet
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text('Tidak ada produk'),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildThumb(product),
            ),
            title: Text(
              product.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(product.price),
                  style: const TextStyle(
                    color: Color(0xFF2D3FE3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.isActive ? 'Aktif' : 'Non-aktif',
                  style: TextStyle(
                    color: product.isActive ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(product.id);
                }
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _productService.deleteProduct(productId);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildThumb(ProductModel product) {
    final primaryImage = (product.imageUrls.isNotEmpty ? product.imageUrls.first : product.imageUrl) ?? '';
    final isRemote = primaryImage.startsWith('http');

    if (primaryImage.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: const Icon(Icons.image),
      );
    }

    return isRemote
        ? Image.network(
            primaryImage,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.image),
            ),
          )
        : Image.file(
            File(primaryImage),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.image),
            ),
          );
  }
}
