class ApiConfig {
  // ⚠️ PRODUCTION CONFIG - Update sesuai backend URL Anda
  // 
  // Untuk development lokal XAMPP:
  //   static const String baseUrl = 'http://localhost/jawara/backend';
  // 
  // Untuk emulator Android:
  //   static const String baseUrl = 'http://10.0.2.2/jawara/backend';
  // 
  // Untuk device fisik (ganti IP sesuai komputer Anda):
  //   static const String baseUrl = 'http://192.168.1.100/jawara/backend';
  
  static const String baseUrl = 'http://localhost/jawara/backend';
  
  // Endpoints
  static const String productsEndpoint = '$baseUrl/products.php';
  static const String authEndpoint = '$baseUrl/auth.php';
  static const String chatEndpoint = '$baseUrl/chat.php';
  static const String categoriesEndpoint = '$baseUrl/categories.php';
  static const String mlDetectionEndpoint = '$baseUrl/ml_detection.php';
  static const String mlDetectionHistoryEndpoint = '$baseUrl/ml_detection_history.php';
  
  // Timeout settings
  static const Duration timeout = Duration(seconds: 30);
}
