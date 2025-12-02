import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../services/camera_service.dart';
import '../services/face_detection_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/network_service.dart';
import '../utils/location_helper.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isDetecting = false;
  List<Face> _detectedFaces = [];

  @override
  Widget build(BuildContext context) {
    return Consumer5<CameraService, FaceDetectionService, ApiService, NotificationService, NetworkService>(
      builder: (context, cameraService, faceService, apiService, notificationService, networkService, child) {
        if (!cameraService.isInitialized) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing camera...'),
              ],
            ),
          );
        }

        if (cameraService.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Camera Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    cameraService.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cameraService.initializeCamera(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(cameraService.controller!),
            ),

            // Face detection overlays
            if (_detectedFaces.isNotEmpty)
              ..._detectedFaces.map((face) => _buildFaceOverlay(face)),

            // Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Switch Camera
                    IconButton(
                      onPressed: () => cameraService.switchCamera(),
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    // Capture Photo from Asset
                    GestureDetector(
                      onTap: _isDetecting ? null : () => _detectFromAsset('assets/image/images.jpeg'),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isDetecting ? Colors.grey : Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: _isDetecting
                            ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        )
                            : const Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                    ),

                    // Settings
                    IconButton(
                      onPressed: () => _showSettingsDialog(),
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status indicator
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility,
                      color: _detectedFaces.isNotEmpty ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_detectedFaces.length} faces',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFaceOverlay(Face face) {
    return Positioned(
      left: face.boundingBox.left,
      top: face.boundingBox.top,
      child: Container(
        width: face.boundingBox.width,
        height: face.boundingBox.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          child: const Text(
            'Face',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _detectFromAsset(String assetPath) async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
      _detectedFaces = [];
    });

    try {
      final faceService = context.read<FaceDetectionService>();
      final apiService = context.read<ApiService>();

      // Step 1: Create the InputImage from the asset path.
      final inputImage = await faceService.createInputImageFromAsset(assetPath);

      // Step 2: Use the new method to process the image.
      final faces = await faceService.processImage(inputImage);

      // Update state with detected faces
      if (mounted) {
        setState(() {
          _detectedFaces = faces;
        });
      }

      // Proceed only if faces are detected
      if (faces.isNotEmpty) {
        final suitableFaces = faces
            .where((face) => faceService.isFaceSuitableForRecognition(face))
            .toList();

        if (suitableFaces.isNotEmpty) {
          // Your existing API call and location logic
          final locationData = await LocationHelper.getCurrentLocation();
          final tempFile = File(inputImage.filePath!); // Get the file from the InputImage

          final detections = await apiService.submitDetection(
            imageFile: tempFile,
            latitude: locationData['latitude'] ?? 0.0,
            longitude: locationData['longitude'] ?? 0.0,
            location: locationData['address'] ?? 'Unknown location',
          );

          if (detections.isNotEmpty) {
            _showDetectionResults(detections);
          } else {
            _showMessage('No matches found for recognized faces.');
          }
        } else {
          _showMessage('Face quality too low for recognition.');
        }
      } else {
        _showMessage('No faces detected in the image.');
      }
    } catch (e) {
      _showMessage('Error during detection: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }
  void _showDetectionResults(List<dynamic> detections) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Possible Match Found!'),
        content: Text('Found ${detections.length} potential match(es)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Face detection settings and preferences'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}