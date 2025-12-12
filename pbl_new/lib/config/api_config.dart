import 'package:flutter/foundation.dart';

class ApiConfig {
  // ⚠️ PRODUCTION CONFIG - Update sesuai backend URL Anda
  // Gunakan --dart-define API_BASE_URL="http://<IP_PC>/jawara/backend" saat
  // menjalankan di device fisik. Default:
  //   - Web: mengikuti origin browser (http://localhost:xxxx/jawara/backend)
  //   - Emulator Android: http://10.0.2.2/jawara/backend
  //   - Device fisik: set manual via --dart-define ke IP PC/LAN

  static final String baseUrl = _resolveBaseUrl();

  // Network IP PC untuk akses dari device lain (update sesuai IP PC)
  static const String networkIp = '192.168.1.7';
  
  static String _resolveBaseUrl() {
    const envBase = String.fromEnvironment('API_BASE_URL');
    if (envBase.isNotEmpty) return envBase;

    if (kIsWeb) {
      return 'http://$networkIp/jawara/backend';
    }

    // Mobile devices: use network IP untuk bisa diakses dari HP
    return 'http://$networkIp/jawara/backend';
  }

  // Endpoints (lazy getters, karena baseUrl bukan const)
  static String get productsEndpoint => '$baseUrl/products.php';
  static String get authEndpoint => '$baseUrl/auth.php';
  static String get chatEndpoint => '$baseUrl/chat.php';
  static String get categoriesEndpoint => '$baseUrl/categories.php';
  static String get mlDetectionEndpoint => '$baseUrl/ml_detection.php';
  static String get mlDetectionHistoryEndpoint => '$baseUrl/ml_detection_history.php';
  static String get rtMetricsEndpoint => '$baseUrl/rt_metrics.php';
  static String get activitiesEndpoint => '$baseUrl/activities.php';
  static String get transactionsEndpoint => '$baseUrl/transactions.php';
  static String get usersEndpoint => '$baseUrl/users.php';
  
  // Timeout settings - reduced for better mobile experience
  static const Duration timeout = Duration(seconds: 15); // Reduced from 30
  static const Duration shortTimeout = Duration(seconds: 8); // For quick operations
  
  // Firebase Cloud Messaging (update dengan Server Key dari Firebase Console)
  static const String fcmServerKey = 'YOUR_FCM_SERVER_KEY_HERE';
}
