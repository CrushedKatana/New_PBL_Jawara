import 'dart:convert';

import 'package:http/http.dart' as http;

/// Service untuk deteksi pakaian menggunakan ML model
class ClothingDetectionService {
  // Backend ML API endpoint
  static const String _baseUrl = 'http://localhost/pbl_jawara/backend';
  static const String _detectEndpoint = '$_baseUrl/ml_detection.php';
  static const String _historyEndpoint = '$_baseUrl/ml_detection_history.php';

  /// Deteksi kategori pakaian dari gambar
  /// 
  /// [imagePath] - Path file gambar yang akan dideteksi
  /// [userId] - ID user yang melakukan deteksi
  /// 
  /// Returns Map dengan struktur:
  /// {
  ///   'success': bool,
  ///   'predicted_class': String,
  ///   'confidence': double,
  ///   'top3_predictions': List<Map>,
  ///   'message': String
  /// }
  static Future<Map<String, dynamic>> detectClothing(
    String imagePath, 
    int userId
  ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_detectEndpoint));
      
      // Attach image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath)
      );
      
      // Add user ID
      request.fields['user_id'] = userId.toString();
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// Get riwayat deteksi pakaian user
  /// 
  /// [userId] - ID user
  /// [limit] - Jumlah data yang ditampilkan (default: 20)
  static Future<Map<String, dynamic>> getDetectionHistory(
    int userId, {
    int limit = 20
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_historyEndpoint),
        body: {
          'action': 'get_history',
          'user_id': userId.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to load history'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// Get statistik deteksi per kategori
  static Future<Map<String, dynamic>> getCategoryStats(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(_historyEndpoint),
        body: {
          'action': 'get_stats',
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to load statistics'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// Simpan hasil deteksi ke database
  static Future<Map<String, dynamic>> saveDetection({
    required int userId,
    required String imagePath,
    required String predictedClass,
    required double confidence,
    required List<Map<String, dynamic>> top3Predictions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_historyEndpoint),
        body: {
          'action': 'save',
          'user_id': userId.toString(),
          'image_path': imagePath,
          'predicted_class': predictedClass,
          'confidence': confidence.toString(),
          'top3_predictions': json.encode(top3Predictions),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to save detection'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }
}
