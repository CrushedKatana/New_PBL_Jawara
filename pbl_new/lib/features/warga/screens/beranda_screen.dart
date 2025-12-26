import 'package:flutter/material.dart';
import 'package:pbl_new/core/models/category_model.dart';
import 'package:pbl_new/core/models/product_model.dart';
import 'package:pbl_new/core/services/category_service.dart';
import 'package:pbl_new/core/services/notification_service.dart';
import 'package:pbl_new/core/services/product_service.dart';
import 'package:pbl_new/features/warga/widgets/product_card.dart';

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
                    child: categories.isEmpty
                        ? const Center(child: Text('Kategori belum tersedia'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = selectedCategory == category.id;
                              // Map category names to icons
                              final iconMap = {
                                'kemeja': '👔',
                                'sepatu': '👞', 
                                't-shirt': '👕',
                                'topi': '🧢',
                                'celana': '👖',
                                'dress': '👗',
                                'jaket': '🧥',
                                'sports baju': '🎽',
                                'checkrook t-shirt': '✅',
                                'sports sepatu': '👟',
                                'person': '👤',
                              };
                              // Resolve icon: prefer valid emoji or image URL; fallback to mapped emoji
                              String displayIcon = '👕'; // default
                              final rawIcon = category.icon;
                              final mappedFallback = iconMap[category.name.toLowerCase()] ?? '👕';

                              bool looksLikeUrl(String s) => s.startsWith('http://') || s.startsWith('https://');
                              bool isLikelyEmoji(String s) {
                                if (s.isEmpty) return false;
                                // Heuristic: emoji are usually non-alphanumeric and short
                                final hasLettersOrDigits = RegExp(r'[A-Za-z0-9]').hasMatch(s);
                                return !hasLettersOrDigits && s.runes.length <= 3; // allow modifiers
                              }

                              Widget iconWidget;
                              if (rawIcon != null && rawIcon.isNotEmpty) {
                                if (looksLikeUrl(rawIcon)) {
                                  iconWidget = ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      rawIcon,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => const Icon(Icons.category_outlined, size: 28, color: Colors.white),
                                    ),
                                  );
                                } else if (isLikelyEmoji(rawIcon)) {
                                  displayIcon = rawIcon;
                                  iconWidget = Text(displayIcon, style: const TextStyle(fontSize: 28, color: Colors.white));
                                } else {
                                  // Invalid string (e.g., 'person'), use mapped fallback
                                  displayIcon = mappedFallback;
                                  iconWidget = Text(displayIcon, style: const TextStyle(fontSize: 28, color: Colors.white));
                                }
                              } else {
                                displayIcon = mappedFallback;
                                iconWidget = Text(displayIcon, style: const TextStyle(fontSize: 28, color: Colors.white));
                              }
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
                                        child: Center(child: iconWidget),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text('Belum ada produk. Tambahkan produk baru untuk mulai jualan.'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      // Lebih tinggi supaya teks tidak overflow
                      childAspectRatio: 0.6,
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
            
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
