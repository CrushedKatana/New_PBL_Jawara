import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/clothing_detection_service.dart';

/// Screen untuk klasifikasi PCVK (Pakaian Celana Sepatu) menggunakan ML HOG+SVM
class ClothingDetectionScreen extends StatefulWidget {
  final int userId;

  const ClothingDetectionScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ClothingDetectionScreen> createState() => _ClothingDetectionScreenState();
}

class _ClothingDetectionScreenState extends State<ClothingDetectionScreen> {
  File? _selectedImage;
  bool _isDetecting = false;
  Map<String, dynamic>? _detectionResult;
  final ImagePicker _picker = ImagePicker();

  /// Pilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectionResult = null;
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar: $e');
    }
  }

  /// Ambil foto dari kamera untuk klasifikasi PCVK
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectionResult = null;
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal mengambil foto: $e');
    }
  }

  /// Proses klasifikasi PCVK menggunakan model ML (HOG+SVM)
  Future<void> _detectClothing() async {
    if (_selectedImage == null) {
      _showErrorDialog('Silakan ambil foto PCVK terlebih dahulu');
      return;
    }

    setState(() {
      _isDetecting = true;
    });

    try {
      final result = await ClothingDetectionService.detectClothing(
        _selectedImage!.path,
        widget.userId,
      );

      setState(() {
        _detectionResult = result;
        _isDetecting = false;
      });

      // Simpan hasil deteksi jika berhasil
      if (result['success'] == true) {
        await ClothingDetectionService.saveDetection(
          userId: widget.userId,
          imagePath: _selectedImage!.path,
          predictedClass: result['predicted_class'],
          confidence: result['confidence'],
          top3Predictions: List<Map<String, dynamic>>.from(
            result['top3_predictions'] ?? []
          ),
        );

        _showSuccessDialog('Klasifikasi PCVK berhasil!');
      } else {
        _showErrorDialog(result['message'] ?? 'Deteksi gagal');
      }
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
      _showErrorDialog('Error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedImage != null)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionResult() {
    if (_detectionResult == null) return const SizedBox.shrink();

    if (_detectionResult!['success'] != true) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _detectionResult!['message'] ?? 'Deteksi gagal',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final predictedClass = _detectionResult!['predicted_class'] ?? 'Unknown';
    final confidence = (_detectionResult!['confidence'] ?? 0.0) * 100;
    final top3 = _detectionResult!['top3_predictions'] as List<dynamic>? ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasil Klasifikasi PCVK',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kategori PCVK:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          predictedClass,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Confidence: ${confidence.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (top3.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Top 3 Prediksi:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...top3.map((prediction) {
                final className = prediction['class'] ?? 'Unknown';
                final conf = (prediction['confidence'] ?? 0.0) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(className),
                      ),
                      Text(
                        '${conf.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Klasifikasi PCVK', style: TextStyle(fontSize: 18)),
            Text('HOG + SVM Model', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to history screen
              Navigator.pushNamed(
                context,
                '/clothing_detection_history',
                arguments: widget.userId,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImagePicker(),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isDetecting ? null : _detectClothing,
                    icon: _isDetecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isDetecting ? 'Mengklasifikasi...' : 'Klasifikasi PCVK',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            _buildDetectionResult(),
          ],
        ),
      ),
    );
  }
}
