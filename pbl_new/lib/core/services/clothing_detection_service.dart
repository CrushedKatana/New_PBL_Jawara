import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';

/// Service untuk deteksi pakaian menggunakan ML model
class ClothingDetectionService {
  // Backend ML API endpoint (using ApiConfig)
  static String get _detectEndpoint => ApiConfig.mlDetectionEndpoint;
  static String get _historyEndpoint => ApiConfig.mlDetectionHistoryEndpoint;

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
      print('🔍 [ML API] Sending to: $_detectEndpoint');
      print('📁 [ML API] Image path: $imagePath');
      
      // For now using multipart form (works with both mock PHP and future direct ML API)
      var request = http.MultipartRequest('POST', Uri.parse(_detectEndpoint));
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('data', imagePath)
      );
      
      print('📤 [ML API] Request sent...');
      
      // Send request with timeout (90s for Hugging Face cold start)
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw TimeoutException('Request timeout after 90 seconds');
        },
      );
      
      var response = await http.Response.fromStream(streamedResponse);
      
      print('📥 [ML API] Status: ${response.statusCode}');
      print('📥 [ML API] Raw Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
      
      if (response.statusCode == 200) {
        try {
          // Try to parse as JSON
          final fullResult = json.decode(response.body);
          print('✅ [ML API] Parsed JSON type: ${fullResult.runtimeType}');
          print('✅ [ML API] JSON keys: ${fullResult is Map ? fullResult.keys.toList() : "not a map"}');
          
          // FORMAT 1: Gradio wraps in {"data": ["json_string"]}
          if (fullResult is Map && fullResult.containsKey('data')) {
            print('🔄 [ML API] Format: Gradio wrapped');
            final dataField = fullResult['data'];
            
            if (dataField is List && dataField.isNotEmpty) {
              final firstElement = dataField[0];
              print('🔄 [ML API] First element type: ${firstElement.runtimeType}');
              
              // If first element is string, parse it as JSON
              if (firstElement is String) {
                try {
                  final mlResult = json.decode(firstElement) as Map<String, dynamic>;
                  print('✅ [ML API] Parsed ML Result: $mlResult');
                  mlResult['user_id'] = userId;
                  return mlResult;
                } catch (parseError) {
                  print('❌ [ML API] Failed to parse inner JSON: $parseError');
                  // Return as-is with error flag
                  return {
                    'success': false,
                    'message': 'Failed to parse ML response: $parseError',
                    'raw_data': firstElement,
                  };
                }
              }
              
              // If first element is already a Map
              if (firstElement is Map) {
                print('✅ [ML API] First element already Map');
                final mlResult = Map<String, dynamic>.from(firstElement);
                mlResult['user_id'] = userId;
                return mlResult;
              }
            }
          }
          
          // FORMAT 2: Direct ML result (no wrapping)
          if (fullResult is Map && fullResult.containsKey('predicted_class')) {
            print('✅ [ML API] Format: Direct ML result');
            fullResult['user_id'] = userId;
            return Map<String, dynamic>.from(fullResult);
          }
          
          // FORMAT 3: Unknown format - try to extract useful info
          print('⚠️ [ML API] Unknown format, returning with warning');
          return {
            'success': false,
            'message': 'Unexpected response format',
            'raw_response': fullResult,
          };
          
        } on FormatException catch (e) {
          print('❌ [ML API] JSON Parse Error: $e');
          return {
            'success': false,
            'message': 'Invalid JSON response: $e',
            'raw_body': response.body.substring(0, 200),
          };
        }
      } else {
        print('❌ [ML API] HTTP Error: ${response.statusCode}');
        print('❌ [ML API] Error Body: ${response.body}');
        return {
          'success': false,
          'message': 'API Error ${response.statusCode}: ${response.body}',
          'status_code': response.statusCode,
        };
      }
    } on TimeoutException catch (e) {
      print('⏱️ [ML API] Timeout: $e');
      return {
        'success': false,
        'message': 'Connection timeout. Please check your internet connection.',
      };
    } catch (e, stackTrace) {
      print('❌ [ML API] Exception: $e');
      print('❌ [ML API] StackTrace: ${stackTrace.toString().substring(0, 500)}');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
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
