import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class AdminService {
  static Future<Map<String, dynamic>> getGlobalStats() async {
    try {
      // Count users by role
      final wargaResp = await http
          .get(Uri.parse('${ApiConfig.usersEndpoint}?role=warga'))
          .timeout(ApiConfig.timeout);
      final rtResp = await http
          .get(Uri.parse('${ApiConfig.usersEndpoint}?role=rt'))
          .timeout(ApiConfig.timeout);
      final adminResp = await http
          .get(Uri.parse('${ApiConfig.usersEndpoint}?role=admin'))
          .timeout(ApiConfig.timeout);

      int wargaCount = _safeCount(wargaResp);
      int rtCount = _safeCount(rtResp);
      int adminCount = _safeCount(adminResp);

      // Products count
      final productsResp = await http
          .get(Uri.parse(ApiConfig.productsEndpoint))
          .timeout(ApiConfig.timeout);
      int productsCount = _safeCount(productsResp);

      // Transactions count
      final transactionsResp = await http
          .get(Uri.parse(ApiConfig.transactionsEndpoint))
          .timeout(ApiConfig.timeout);
      int transactionsCount = _safeCount(transactionsResp);

      return {
        'totalWarga': wargaCount,
        'totalProduk': productsCount,
        'totalTransaksi': transactionsCount,
        // Placeholder GMV derived from transactions if available
        'gmv': _estimateGmv(transactionsResp),
        'wargaByRole': {
          'warga': wargaCount,
          'rt': rtCount,
          'admin': adminCount,
        },
      };
    } catch (e) {
      if (kDebugMode) {
        print('AdminService.getGlobalStats error: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
    final uri = role == null
        ? Uri.parse(ApiConfig.usersEndpoint)
        : Uri.parse('${ApiConfig.usersEndpoint}?role=$role');
    try {
      final resp = await http.get(uri).timeout(ApiConfig.timeout);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('AdminService.getUsers error: $e');
      }
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getRtPerformance() async {
    try {
      final resp = await http
          .get(Uri.parse(ApiConfig.rtMetricsEndpoint))
          .timeout(ApiConfig.timeout);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          // Expect objects like { rt: 'RT 01', warga: 123, produk: 45, transaksi: 67 }
          return data.map<Map<String, dynamic>>((e) => {
                'rt': e['rt'] ?? e['name'] ?? 'RT',
                'warga': e['warga'] ?? e['users'] ?? 0,
                'produk': e['produk'] ?? e['products'] ?? 0,
                'transaksi': e['transaksi'] ?? e['transactions'] ?? 0,
              }).toList();
        }
        if (data is Map && data['data'] is List) {
          final list = (data['data'] as List);
          return list.map<Map<String, dynamic>>((e) => {
                'rt': e['rt'] ?? e['name'] ?? 'RT',
                'warga': e['warga'] ?? e['users'] ?? 0,
                'produk': e['produk'] ?? e['products'] ?? 0,
                'transaksi': e['transaksi'] ?? e['transactions'] ?? 0,
              }).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('AdminService.getRtPerformance error: $e');
      }
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getSystemStatus() async {
    // Basic health checks using simple GETs; map to statuses
    final checks = <Map<String, dynamic>>[];
    Future<String> _health(String name, Uri uri) async {
      try {
        final resp = await http.get(uri).timeout(ApiConfig.shortTimeout);
        if (resp.statusCode == 200) return 'Active';
        return 'Degraded';
      } catch (_) {
        return 'Down';
      }
    }

    final apiStatus = await _health('API Server', Uri.parse(ApiConfig.authEndpoint));
    final productsStatus = await _health('Products', Uri.parse(ApiConfig.productsEndpoint));

    checks.add({'name': 'API Server', 'status': apiStatus});
    checks.add({'name': 'Database', 'status': productsStatus == 'Active' ? 'Healthy' : 'Degraded'});
    checks.add({'name': 'PCVK Model', 'status': 'Active'}); // Placeholder until real ML health endpoint exists

    return checks;
  }

  static int _safeCount(http.Response resp) {
    if (resp.statusCode != 200) return 0;
    try {
      final data = jsonDecode(resp.body);
      if (data is List) return data.length;
      if (data is Map && data['data'] is List) return (data['data'] as List).length;
      if (data is Map && data['count'] is int) return data['count'] as int;
    } catch (_) {}
    return 0;
  }

  static double _estimateGmv(http.Response resp) {
    try {
      final data = jsonDecode(resp.body);
      if (data is List) {
        // If transactions include amount fields, sum them
        double sum = 0;
        for (final t in data) {
          final amt = t['amount'] ?? t['total'] ?? t['price'];
          if (amt is num) sum += amt.toDouble();
        }
        // Return in millions for display
        return double.parse((sum / 1000000).toStringAsFixed(1));
      }
    } catch (_) {}
    return 0.0;
  }
}
