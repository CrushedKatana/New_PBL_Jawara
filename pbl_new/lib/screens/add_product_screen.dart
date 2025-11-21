import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import 'camera_detection_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _conditionController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  List<File> _images = [];
  List<CategoryModel> categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryService.getCategories();
    setState(() {
      categories = cats;
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _openCameraDetection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraDetectionScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // Add captured image
        if (result['image'] != null) {
          _images.add(result['image'] as File);
        }

        // Set detected category
        if (result['category'] != null) {
          final detectedCategoryName = result['category'] as String;
          
          // Find matching category ID
          final matchingCategory = categories.firstWhere(
            (cat) => cat.name.toLowerCase() == detectedCategoryName.toLowerCase(),
            orElse: () => categories.first,
          );
          
          _selectedCategory = matchingCategory.id;
        }
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori terdeteksi: ${result['category']}'),
            backgroundColor: const Color(0xFF2D3FE3),
          ),
        );
      }
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan, silakan login terlebih dahulu');
      }

      final product = ProductModel(
        id: '',
        title: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        categoryId: _selectedCategory,
        sellerId: currentUser.id,
        sellerName: currentUser.name,
        location: currentUser.address,
        // imageUrl will be set later when implementing image upload
        imageUrl: '',
      );

      final result = await _productService.addProduct(product);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan')),
          );
          Navigator.pop(context);
        } else {
          throw Exception(result['error'] ?? 'Gagal menambahkan produk');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _conditionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Jual Pakaian'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto Produk
                    const Text(
                      'Foto Produk',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildImagePicker(
                          icon: Icons.auto_awesome,
                          label: 'AI Deteksi',
                          onTap: _openCameraDetection,
                          isPrimary: true,
                        ),
                        const SizedBox(width: 12),
                        _buildImagePicker(
                          icon: Icons.camera_alt,
                          label: 'Kamera',
                          onTap: _takePicture,
                        ),
                        const SizedBox(width: 12),
                        _buildImagePicker(
                          icon: Icons.image,
                          label: 'Galeri',
                          onTap: _pickImages,
                        ),
                      ],
                    ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_images[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Nama Produk
                    const Text('Nama Produk', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Kaos Polos Premium',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Nama produk wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    // Kategori
                    const Text('Kategori', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Pilih kategori'),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) => value == null ? 'Kategori wajib dipilih' : null,
                    ),

                    const SizedBox(height: 16),

                    // Harga dan Ukuran
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Harga', style: TextStyle(fontSize: 14)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '50000',
                                  border: OutlineInputBorder(),
                                  prefixText: 'Rp ',
                                ),
                                validator: (value) => value?.isEmpty ?? true ? 'Harga wajib diisi' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ukuran', style: TextStyle(fontSize: 14)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _sizeController,
                                decoration: const InputDecoration(
                                  hintText: 'L (Large)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Kondisi
                    const Text('Kondisi', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _conditionController,
                      decoration: const InputDecoration(
                        hintText: 'Baru / Bekas',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Kondisi wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    // Deskripsi
                    const Text('Deskripsi', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Jelaskan detail produk Anda...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Deskripsi wajib diisi' : null,
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3FE3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Posting Produk',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF2D3FE3) : Colors.white,
            border: Border.all(
              color: isPrimary ? const Color(0xFF2D3FE3) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: isPrimary ? Colors.white : const Color(0xFF2D3FE3),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isPrimary ? Colors.white : Colors.black87,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
