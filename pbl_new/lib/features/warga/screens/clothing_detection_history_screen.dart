import 'package:flutter/material.dart';

import '../../../core/services/clothing_detection_service.dart';

/// Screen untuk melihat riwayat deteksi pakaian
class ClothingDetectionHistoryScreen extends StatefulWidget {
  final int userId;

  const ClothingDetectionHistoryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ClothingDetectionHistoryScreen> createState() =>
      _ClothingDetectionHistoryScreenState();
}

class _ClothingDetectionHistoryScreenState
    extends State<ClothingDetectionHistoryScreen> {
  List<dynamic> _history = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final historyResult = await ClothingDetectionService.getDetectionHistory(
      widget.userId,
      limit: 50,
    );

    final statsResult = await ClothingDetectionService.getCategoryStats(
      widget.userId,
    );

    setState(() {
      if (historyResult['success'] == true) {
        _history = historyResult['data'] ?? [];
      }
      if (statsResult['success'] == true) {
        _stats = statsResult['stats'];
      }
      _isLoading = false;
    });
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();

    final totalDetections = _stats!['total_detections'] ?? 0;
    final categories = _stats!['by_category'] as List<dynamic>? ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Statistik Deteksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Total Deteksi: $totalDetections',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (categories.isNotEmpty) ...[
              const Text(
                'Per Kategori:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...categories.map((cat) {
                final category = cat['category'] ?? 'Unknown';
                final count = cat['count'] ?? 0;
                final percentage = totalDetections > 0
                    ? (count / totalDetections * 100).toStringAsFixed(1)
                    : '0.0';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(category),
                      ),
                      Text(
                        '$count ($percentage%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Belum ada riwayat deteksi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final predictedClass = item['predicted_class'] ?? 'Unknown';
        final confidence = (item['confidence'] ?? 0.0) * 100;
        final createdAt = item['created_at'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(
                Icons.checkroom,
                color: Colors.blue,
              ),
            ),
            title: Text(
              predictedClass,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Confidence: ${confidence.toStringAsFixed(1)}%'),
                Text(
                  createdAt,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              confidence > 80
                  ? Icons.check_circle
                  : confidence > 60
                      ? Icons.info
                      : Icons.warning,
              color: confidence > 80
                  ? Colors.green
                  : confidence > 60
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Deteksi Pakaian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStatsCard(),
                    _buildHistoryList(),
                  ],
                ),
              ),
            ),
    );
  }
}
