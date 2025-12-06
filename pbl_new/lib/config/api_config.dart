import 'package:flutter/foundation.dart';

class ApiConfig {
  // ⚠️ PRODUCTION CONFIG - Update sesuai backend URL Anda
  // Gunakan --dart-define API_BASE_URL="http://<IP_PC>/jawara/backend" saat
  // menjalankan di device fisik. Default:
  //   - Web: mengikuti origin browser (http://localhost:xxxx/jawara/backend)
  //   - Emulator Android: http://10.0.2.2/jawara/backend
  //   - Device fisik: set manual via --dart-define ke IP PC/LAN

  static final String baseUrl = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const envBase = String.fromEnvironment('API_BASE_URL');
    if (envBase.isNotEmpty) return envBase;

    if (kIsWeb) {
      // Ambil origin browser, misal http://localhost:xxxx lalu tambahkan path backend.
      final origin = Uri.base.origin; // tanpa trailing slash
      return '$origin/jawara/backend';
    }

    // Default emulator Android
    return 'http://10.0.2.2/jawara/backend';
  }

  // Endpoints (lazy getters, karena baseUrl bukan const)
  static String get productsEndpoint => '$baseUrl/products.php';
  static String get authEndpoint => '$baseUrl/auth.php';
  static String get chatEndpoint => '$baseUrl/chat.php';
  static String get categoriesEndpoint => '$baseUrl/categories.php';
  static String get mlDetectionEndpoint => '$baseUrl/ml_detection.php';
  static String get mlDetectionHistoryEndpoint => '$baseUrl/ml_detection_history.php';
  
  // Timeout settings
  static const Duration timeout = Duration(seconds: 30);
}
