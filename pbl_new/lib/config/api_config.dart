class ApiConfig {
  // Ganti dengan IP address komputer Anda jika testing di device fisik
  // Untuk emulator Android: gunakan 10.0.2.2
  // Untuk emulator iOS: gunakan localhost
  // Untuk device fisik: gunakan IP address komputer (misal: 192.168.1.100)
  
  static const String baseUrl = 'http://localhost/marketplace_api';
  
  // Endpoints
  static const String productsEndpoint = '$baseUrl/products.php';
  static const String authEndpoint = '$baseUrl/auth.php';
  static const String chatEndpoint = '$baseUrl/chat.php';
  static const String categoriesEndpoint = '$baseUrl/categories.php';
  static const String rtMetricsEndpoint = '$baseUrl/rt_metrics.php';
  static const String activitiesEndpoint = '$baseUrl/activities.php';
  
  // ML Detection API (Hugging Face Space)
  static const String mlDetectionEndpoint = 'https://crushedkatana-clothing-clasification.hf.space/detect';
  static const String mlDetectionHistoryEndpoint = '$baseUrl/ml_detections.php';
  
  // Timeout settings
  static const Duration timeout = Duration(seconds: 30);
}
