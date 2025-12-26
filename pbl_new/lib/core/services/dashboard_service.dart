import 'dart:async';

/// Model untuk metrik dashboard RT/RW
class DashboardMetrics {
  final int totalWarga;
  final int wargaTerverifikasi;
  final int produkAktif;
  final int transaksiBulanIni;
  final String wargaGrowth;
  final String produkGrowth;
  final String transaksiGrowth;

  DashboardMetrics({
    required this.totalWarga,
    required this.wargaTerverifikasi,
    required this.produkAktif,
    required this.transaksiBulanIni,
    required this.wargaGrowth,
    required this.produkGrowth,
    required this.transaksiGrowth,
  });
}

/// Model untuk aktivitas terbaru
class ActivityItem {
  final String type; // 'warning', 'register', 'success'
  final String message;
  final String timeAgo;

  ActivityItem({
    required this.type,
    required this.message,
    required this.timeAgo,
  });
}

/// Service stub: ganti implementasi dengan panggilan HTTP ke backend PHP
class DashboardService {
  Future<DashboardMetrics> fetchMetrics({String? rt}) async {
    // TODO: Implementasikan HTTP GET ke endpoint misal: GET /api/dashboard?rt=05
    // Sementara: data dummy
    await Future.delayed(const Duration(milliseconds: 400));
    return DashboardMetrics(
      totalWarga: 142,
      wargaTerverifikasi: 138,
      produkAktif: 67,
      transaksiBulanIni: 234,
      wargaGrowth: '+5',
      produkGrowth: '+12',
      transaksiGrowth: '+18%',
    );
  }

  Future<List<ActivityItem>> fetchRecentActivities({String? rt}) async {
    // TODO: Implementasikan HTTP GET ke endpoint misal: /api/activities?rt=05&limit=20
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ActivityItem(
        type: 'warning',
        message: 'Produk dari Ibu Siti menunggu approval',
        timeAgo: '10 menit lalu',
      ),
      ActivityItem(
        type: 'register',
        message: 'Warga baru mendaftar: Budi Santoso',
        timeAgo: '1 jam lalu',
      ),
      ActivityItem(
        type: 'success',
        message: 'Transaksi berhasil: Kaos Polos - Rp 45.000',
        timeAgo: '2 jam lalu',
      ),
    ];
  }
}
