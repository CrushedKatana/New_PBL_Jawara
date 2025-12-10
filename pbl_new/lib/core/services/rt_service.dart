import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';

class RtMetricsModel {
  final String rt;
  final int month;
  final int year;
  final int totalWarga;
  final int totalProduk;
  final int totalTransaksi;
  final double totalPendapatan;
  final int pendingApproval;

  RtMetricsModel({
    required this.rt,
    required this.month,
    required this.year,
    required this.totalWarga,
    required this.totalProduk,
    required this.totalTransaksi,
    required this.totalPendapatan,
    required this.pendingApproval,
  });

  factory RtMetricsModel.fromJson(Map<String, dynamic> json) {
    return RtMetricsModel(
      rt: json['rt'],
      month: json['month'],
      year: json['year'],
      totalWarga: json['total_warga'] ?? 0,
      totalProduk: json['total_produk'] ?? 0,
      totalTransaksi: json['total_transaksi'] ?? 0,
      totalPendapatan: double.tryParse(json['total_pendapatan'].toString()) ?? 0.0,
      pendingApproval: json['pending_approval'] ?? 0,
    );
  }
}

class ActivityModel {
  final int activityId;
  final String userId;
  final String userName;
  final String rt;
  final String activityType;
  final String description;
  final String activityDate;

  ActivityModel({
    required this.activityId,
    required this.userId,
    required this.userName,
    required this.rt,
    required this.activityType,
    required this.description,
    required this.activityDate,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      activityId: json['activity_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? '',
      rt: json['rt'],
      activityType: json['activity_type'],
      description: json['description'],
      activityDate: json['activity_date'],
    );
  }
}

class RtService {
  // Get RT Metrics
  Future<RtMetricsModel?> getRtMetrics(String rt, {int? month, int? year}) async {
    try {
      final now = DateTime.now();
      final m = month ?? now.month;
      final y = year ?? now.year;
      
      final response = await http.get(
        Uri.parse('${ApiConfig.rtMetricsEndpoint}?rt=$rt&month=$m&year=$y'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return RtMetricsModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error getting RT metrics: $e');
      return null;
    }
  }

  // Get Activities by RT
  Future<List<ActivityModel>> getActivities({String? rt, int limit = 50}) async {
    try {
      String url = '${ApiConfig.activitiesEndpoint}?limit=$limit';
      if (rt != null) {
        url += '&rt=$rt';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['data'] as List)
            .map((json) => ActivityModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting activities: $e');
      return [];
    }
  }

  // Add Activity Log
  Future<bool> addActivity({
    required String userId,
    required String rt,
    required String activityType,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.activitiesEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'rt': rt,
          'activity_type': activityType,
          'description': description,
        }),
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      print('Error adding activity: $e');
      return false;
    }
  }
}
