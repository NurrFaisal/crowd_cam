import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/detection_result.dart';

class DetectionHistoryScreen extends StatefulWidget {
  const DetectionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DetectionHistoryScreen> createState() => _DetectionHistoryScreenState();
}

class _DetectionHistoryScreenState extends State<DetectionHistoryScreen> {
  List<DetectionResult> _detections = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetectionHistory();
    });
  }

  Future<void> _loadDetectionHistory() async {
    final apiService = context.read<ApiService>();
    final detections = await apiService.fetchDetectionHistory();
    setState(() {
      _detections = detections;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiService>(
      builder: (context, apiService, child) {
        if (apiService.isLoading && _detections.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_detections.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No detection history',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start scanning to help find missing persons',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadDetectionHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _detections.length,
            itemBuilder: (context, index) {
              final detection = _detections[index];
              return _buildDetectionCard(detection);
            },
          ),
        );
      },
    );
  }

  Widget _buildDetectionCard(DetectionResult detection) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: detection.imageUrl.isNotEmpty
              ? NetworkImage(detection.imageUrl)
              : null,
          child: detection.imageUrl.isEmpty
              ? const Icon(Icons.camera_alt, size: 20)
              : null,
        ),
        title: Text(
          'Detection ${detection.detectionId.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confidence: ${(detection.confidenceScore * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 2),
            Text(
              'Detected: ${_formatDateTime(detection.detectedAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              detection.location,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getConfidenceColor(detection.confidenceScore),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getConfidenceLabel(detection.confidenceScore),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showDetectionDetails(detection),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showDetectionDetails(DetectionResult detection) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              if (detection.imageUrl.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(detection.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detection Details',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Detection ID', detection.detectionId),
                    _buildDetailRow('Missing Person ID', detection.missingPersonId),
                    _buildDetailRow('Confidence Score', '${(detection.confidenceScore * 100).toStringAsFixed(1)}%'),
                    _buildDetailRow('Detected At', _formatDateTime(detection.detectedAt)),
                    _buildDetailRow('Location', detection.location),
                    _buildDetailRow('Coordinates', '${detection.latitude.toStringAsFixed(4)}, ${detection.longitude.toStringAsFixed(4)}'),
                  ],
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}