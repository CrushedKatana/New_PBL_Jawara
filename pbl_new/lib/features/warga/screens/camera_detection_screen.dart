import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/clothing_detection_service.dart';

class CameraDetectionScreen extends StatefulWidget {
  const CameraDetectionScreen({super.key});

  @override
  State<CameraDetectionScreen> createState() => _CameraDetectionScreenState();
}

class _CameraDetectionScreenState extends State<CameraDetectionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isDetecting = false;
  String? _detectedCategory;
  double _confidence = 0.0;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  // PCVK Categories dari model ML
  final Map<String, String> _pcvkMapping = {
    'Hat': 'Topi',
    'Shirt': 'Kemeja',
    'T-Shirt': 'Kaos',
    'Shoes': 'Sepatu',
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final File file = File(imageFile.path);
      
      setState(() {
        _capturedImage = file;
      });

      await _detectCategory(file);
    } catch (e) {
      print('Error capturing image: $e');
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> _detectCategory(File imageFile) async {
    try {
      // Call PCVK ML model (HOG+SVM) via backend
      final result = await ClothingDetectionService.detectClothing(
        imageFile.path,
        1, // Temporary user ID
      );

      if (result['success'] == true) {
        final predictedClass = result['predicted_class'];
        final confidence = result['confidence'];

        // Map PCVK categories to Indonesian
        final mappedCategory = _pcvkMapping[predictedClass] ?? predictedClass;

        setState(() {
          _detectedCategory = mappedCategory;
          _confidence = confidence;
        });
      } else {
        throw Exception(result['message'] ?? 'Detection failed');
      }
    } catch (e) {
      print('Error detecting category: $e');
      // Fallback
      setState(() {
        _detectedCategory = 'Pakaian';
        _confidence = 0.5;
      });
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> _pickFromGalleryAndDetect() async {
    if (_isDetecting) return;
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final imageFile = File(file.path);
      setState(() {
        _capturedImage = imageFile;
        _isDetecting = true;
      });
      await _detectCategory(imageFile);
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  void _returnResult() {
    if (_detectedCategory != null && _capturedImage != null) {
      Navigator.pop(context, {
        'category': _detectedCategory,
        'image': _capturedImage,
        'confidence': _confidence,
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _detectedCategory = null;
      _confidence = 0.0;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview or Captured Image
            if (_capturedImage == null)
              Center(
                child: CameraPreview(_cameraController!),
              )
            else
              Center(
                child: Image.file(_capturedImage!, fit: BoxFit.contain),
              ),

            // Top Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Arahkan kamera ke pakaian',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PCVK akan mendeteksi kategori otomatis',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Detection Frame (similar to screenshot)
            if (_capturedImage == null)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFFC107),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

            // Detection Result
            if (_detectedCategory != null)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3FE3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Terdeteksi: $_detectedCategory',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${(_confidence * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _capturedImage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Cancel Button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Capture Button
                          GestureDetector(
                            onTap: _isDetecting ? null : _captureAndDetect,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFC107),
                                  width: 4,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _isDetecting
                                      ? const Padding(
                                          padding: EdgeInsets.all(20),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Color(0xFF2D3FE3),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),

                          // PCVK Active Button (pick from gallery)
                          ElevatedButton.icon(
                            onPressed: _isDetecting ? null : _pickFromGalleryAndDetect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D3FE3),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: const Icon(Icons.photo_library, color: Colors.white, size: 20),
                            label: const Text(
                              'PCVK Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Retake Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _retakePhoto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Foto Ulang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Use Photo Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _detectedCategory != null
                                  ? _returnResult
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D3FE3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: const Text(
                                'Gunakan Foto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
}
