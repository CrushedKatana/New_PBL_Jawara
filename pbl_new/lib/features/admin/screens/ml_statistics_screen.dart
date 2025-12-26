import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbl_new/config/api_config.dart';

/// Screen untuk admin melihat statistik ML deteksi pakaian
class MLStatisticsScreen extends StatefulWidget {
  const MLStatisticsScreen({super.key});

  @override
  State<MLStatisticsScreen> createState() => _MLStatisticsScreenState();
}

class _MLStatisticsScreenState extends State<MLStatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _globalStats;
  List<dynamic> _recentDetections = [];
  Map<String, int> _categoryData = {};
  
  // Training Dataset Info (from latest model training)
  final Map<String, int> _trainingDataset = {
    'Topi': 171,
    'Kemeja': 378,
    'Sepatu': 431,
    'T-Shirt': 1011,
  };
  
  // Model Performance Info (Updated with GridSearchCV optimized model)
  final Map<String, dynamic> _modelPerformance = {
    'train_accuracy': 1.0,
    'val_accuracy': 0.8647,
    'test_accuracy': 0.8795,
    'model_type': 'RBF SVC (HOG+SVM)',
    'trained_date': '2025-12-11',
    'total_training_samples': 3982, // With augmentation
    'best_params': 'C=10, gamma=scale, class_weight=balanced',
  };

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch real data from backend
      final response = await http.post(
        Uri.parse('${ApiConfig.mlDetectionHistoryEndpoint}?action=get_global_stats'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final stats = data['stats'];
          
          setState(() {
            _globalStats = {
              'total_detections': stats['total_detections'] ?? 0,
              'total_users': stats['total_users'] ?? 0,
              'avg_confidence': stats['avg_confidence'] ?? 0.0,
              'most_detected_category': stats['most_detected_category'] ?? 'N/A',
            };

            // Convert category data
            _categoryData = {};
            for (var cat in (stats['by_category'] ?? [])) {
              _categoryData[cat['category']] = cat['count'];
            }

            _recentDetections = stats['recent_detections'] ?? [];
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load stats');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat statistik: $e')),
        );
      }
    }
  }

  Widget _buildOverviewCards() {
    if (_globalStats == null) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Deteksi',
          _globalStats!['total_detections'].toString(),
          Icons.assessment,
          Colors.blue,
        ),
        _buildStatCard(
          'Total User',
          _globalStats!['total_users'].toString(),
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          'Avg Confidence',
          '${(_globalStats!['avg_confidence'] * 100).toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildStatCard(
          'Kategori Terbanyak',
          _globalStats!['most_detected_category'],
          Icons.star,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    if (_categoryData.isEmpty) return const SizedBox.shrink();

    final sortedEntries = _categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deteksi per Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: sortedEntries.first.value.toDouble() * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${sortedEntries[group.x.toInt()].key}\n${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedEntries.length) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              sortedEntries[value.toInt()].key,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: sortedEntries.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelPerformance() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.model_training, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Model Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildPerformanceRow('Model Type', _modelPerformance['model_type']),
            _buildPerformanceRow('Training Accuracy', '${(_modelPerformance['train_accuracy'] * 100).toStringAsFixed(1)}%'),
            _buildPerformanceRow('Validation Accuracy', '${(_modelPerformance['val_accuracy'] * 100).toStringAsFixed(1)}%'),
            _buildPerformanceRow('Test Accuracy', '${(_modelPerformance['test_accuracy'] * 100).toStringAsFixed(1)}%'),
            _buildPerformanceRow('Training Samples', '${_modelPerformance['total_training_samples']} (augmented)'),
            _buildPerformanceRow('Best Params', _modelPerformance['best_params']),
            _buildPerformanceRow('Last Trained', _modelPerformance['trained_date']),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPerformanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainingDataset() {
    final sortedEntries = _trainingDataset.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalImages = _trainingDataset.values.reduce((a, b) => a + b);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dataset, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Training Dataset',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Total: $totalImages images',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...sortedEntries.map((entry) {
              final percentage = (entry.value / totalImages * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${entry.value} ($percentage%)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / totalImages,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Topi':
        return Colors.orange;
      case 'Kemeja':
        return Colors.blue;
      case 'Sepatu':
        return Colors.green;
      case 'T-Shirt':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecentDetections() {
    if (_recentDetections.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Deteksi Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentDetections.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final detection = _recentDetections[index];
                final userName = detection['user_name'] ?? 'Unknown';
                final predictedClass = detection['predicted_class'] ?? 'Unknown';
                final confidence = (detection['confidence'] ?? 0.0) * 100;
                final createdAt = detection['created_at'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(userName[0].toUpperCase()),
                  ),
                  title: Text(
                    '$userName - $predictedClass',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confidence: ${confidence.toStringAsFixed(1)}%'),
                      Text(
                        createdAt,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistik PCVK', style: TextStyle(fontSize: 18)),
            Text('HOG + SVM Model', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildOverviewCards(),
                    _buildModelPerformance(),
                    _buildTrainingDataset(),
                    _buildCategoryChart(),
                    _buildRecentDetections(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
