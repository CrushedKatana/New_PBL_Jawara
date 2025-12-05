import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pbl_new/core/models/category_model.dart';
import 'package:pbl_new/core/models/product_model.dart';
import 'package:pbl_new/core/services/category_service.dart';
import 'package:pbl_new/core/services/notification_service.dart';
import 'package:pbl_new/core/services/product_service.dart';
import 'package:pbl_new/features/warga/widgets/product_card.dart';

import '../../../services/firebase_service.dart';
import 'notifikasi_screen.dart';
import 'product_detail_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final NotificationService _notificationService = NotificationService();
  String searchQuery = '';
  String? selectedCategory;
  List<CategoryModel> categories = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUnreadCount();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryService.getCategories();
    setState(() {
      categories = cats;
    });
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D3FE3),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Selamat Datang! 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotifikasiScreen(),
                                  ),
                                );
                                _loadUnreadCount(); // Refresh count setelah kembali
                              },
                            ),
                            if (_unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Marketplace Pakaian RT/RW',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari pakaian, sepatu, aksesoris...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ML Detection Feature Card
            // Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = isSelected ? null : category.id;
                            });
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF2D3FE3) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.icon ?? '📦',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Products
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Produk Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid (original backend) + Firestore latest overlay
            FutureBuilder<List<ProductModel>>(
              future: _productService.getProducts(
                categoryId: selectedCategory,
                search: searchQuery.isEmpty ? null : searchQuery,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                }
                final products = snapshot.data ?? [];
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
            // Firestore latest products demo list
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.instance.watchLatestProducts(limit: 6),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                }
                final docs = snap.data?.docs ?? [];
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text('Realtime Produk (Firestore Demo)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (docs.isEmpty)
                          const Text('Belum ada data Firestore, tekan tombol tambah di bawah.')
                        else
                          ...docs.map((d) {
                            final data = d.data() as Map<String, dynamic>;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(data['name'] ?? 'Tanpa Nama'),
                              subtitle: Text('Harga: ${data['price'] ?? '-'}'),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),

            // CTA Jual Pakaian
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD500),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jual Pakaian Bekas Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bergabunglah dengan komunitas\nmarketplace lokal kami',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate ke add product screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3FE3),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Mulai Jual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // Firestore Demo Section (Fashion Categories)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔥 Firestore Demo - Fashion Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseService.instance.addProduct({
                              'title': 'T-Shirt Polos Premium',
                              'price': 89000,
                              'category': 'T-Shirt',
                              'seller': 'Demo Store',
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('T-Shirt added to Firestore!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.checkroom, size: 18),
                          label: const Text('+ T-Shirt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseService.instance.addProduct({
                              'title': 'Topi Baseball NY',
                              'price': 125000,
                              'category': 'Topi',
                              'seller': 'Demo Store',
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Topi added to Firestore!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.sports_baseball, size: 18),
                          label: const Text('+ Topi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseService.instance.addProduct({
                              'title': 'Kemeja Flanel Premium',
                              'price': 145000,
                              'category': 'Kemeja',
                              'seller': 'Demo Store',
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kemeja added to Firestore!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.person, size: 18),
                          label: const Text('+ Kemeja'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseService.instance.addProduct({
                              'title': 'Sepatu Sneakers Original',
                              'price': 899000,
                              'category': 'Sepatu',
                              'seller': 'Demo Store',
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sepatu added to Firestore!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.sports_soccer, size: 18),
                          label: const Text('+ Sepatu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseService.instance.watchLatestProducts(limit: 10),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Tekan tombol di atas untuk menambah produk ke Firestore'),
                            ),
                          );
                        }
                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Belum ada produk. Tambahkan produk demo!'),
                            ),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📦 Live dari Firestore (${docs.length} items)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF2D3FE3).withOpacity(0.1),
                                    child: const Icon(Icons.shopping_bag, size: 20, color: Color(0xFF2D3FE3)),
                                  ),
                                  title: Text(
                                    data['title'] ?? 'No title',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${data['category'] ?? 'Unknown'} - Rp ${data['price'] ?? 0}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    onPressed: () async {
                                      await FirebaseService.instance.deleteProduct(doc.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Produk dihapus dari Firestore')),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
