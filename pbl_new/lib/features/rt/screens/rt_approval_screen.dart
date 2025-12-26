import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl_new/core/models/product_model.dart';
import 'package:pbl_new/core/services/notification_service.dart';
import 'package:pbl_new/core/services/product_service.dart';

class RtApprovalScreen extends StatefulWidget {
  const RtApprovalScreen({super.key});

  @override
  State<RtApprovalScreen> createState() => _RtApprovalScreenState();
}

class _RtApprovalScreenState extends State<RtApprovalScreen> {
  final ProductService _productService = ProductService();
  final NotificationService _notificationService = NotificationService();
  List<ProductModel> _pendingProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingProducts();
  }

  Future<void> _loadPendingProducts() async {
    setState(() => _loading = true);
    try {
      // Fetch all products
      final allProducts = await _productService.getProducts();
      
      if (mounted) {
        setState(() {
          _pendingProducts = allProducts;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Approval Produk',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    '${_pendingProducts.length} produk',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: _pendingProducts.isEmpty
                      ? const Center(
                          child: Text('Tidak ada produk'),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadPendingProducts,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _pendingProducts.length,
                            itemBuilder: (context, index) {
                              final product = _pendingProducts[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            product.imageUrl ?? 'https://via.placeholder.com/80',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.image),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currencyFormat.format(product.price),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2D3FE3),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                product.categoryName ?? 'Tidak ada kategori',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
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
                                                'Penjual',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                product.sellerName ?? product.sellerId,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
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
                                                'Lokasi',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                product.location ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _showApproveDialog(product);
                                            },
                                            icon: const Icon(Icons.check, size: 18),
                                            label: const Text('Setujui'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _showRejectDialog(product);
                                            },
                                            icon: const Icon(Icons.close, size: 18),
                                            label: const Text('Tolak'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  void _showApproveDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Produk'),
        content: Text('Apakah Anda yakin ingin menyetujui produk "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _approveProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Produk'),
        content: Text('Apakah Anda yakin ingin menolak produk "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _rejectProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveProduct(ProductModel product) async {
    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menyetujui "${product.title}"...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // TODO: Call actual approval endpoint from backend
      // For now, simulate with delay
      await Future.delayed(const Duration(seconds: 1));

      // Remove from list immediately
      if (mounted) {
        setState(() {
          _pendingProducts.removeWhere((p) => p.id == product.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk "${product.title}" telah disetujui'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Send notification to seller
        _sendApprovalNotification(product, approved: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectProduct(ProductModel product) async {
    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menolak "${product.title}"...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // TODO: Call actual rejection endpoint from backend
      // For now, simulate with delay
      await Future.delayed(const Duration(seconds: 1));

      // Remove from list immediately
      if (mounted) {
        setState(() {
          _pendingProducts.removeWhere((p) => p.id == product.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk "${product.title}" telah ditolak'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );

        // Send notification to seller
        _sendApprovalNotification(product, approved: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendApprovalNotification(ProductModel product, {required bool approved}) {
    // Send notification to seller
    final message = approved
        ? 'Produk Anda "${product.title}" telah disetujui oleh RT/RW!'
        : 'Produk Anda "${product.title}" telah ditolak oleh RT/RW. Silakan perbaiki dan coba lagi.';
    
    final title = approved ? 'Produk Disetujui' : 'Produk Ditolak';

    _notificationService.createNotification(
      userId: product.sellerId,
      title: title,
      message: message,
      type: approved ? 'product_approved' : 'product_rejected',
      relatedId: product.id,
      data: {
        'product_id': product.id,
        'product_title': product.title,
        'approved': approved,
      },
    ).then((_) {
      print('Notification sent to ${product.sellerId}');
    }).catchError((e) {
      print('Error sending notification: $e');
    });
  }
}
