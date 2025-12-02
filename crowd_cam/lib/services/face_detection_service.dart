import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FaceDetectionService extends ChangeNotifier {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  bool _isProcessing = false;
  List<Face> _detectedFaces = [];
  String? _errorMessage;

  bool get isProcessing => _isProcessing;
  List<Face> get detectedFaces => _detectedFaces;
  String? get errorMessage => _errorMessage;

  /// Processes an InputImage and detects faces.
  /// This method can be used for both camera and file inputs.
  Future<List<Face>> processImage(InputImage inputImage) async {
    try {
      _isProcessing = true;
      _errorMessage = null;
      notifyListeners();

      final faces = await _faceDetector.processImage(inputImage);

      _detectedFaces = faces;
      _isProcessing = false;
      notifyListeners();

      return faces;
    } catch (e) {
      _errorMessage = 'Face detection failed: $e';
      _isProcessing = false;
      notifyListeners();
      return [];
    }
  }

  /// Helper method to create an InputImage from an asset path.
  /// This can be called from outside the service.
  Future<InputImage> createInputImageFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return InputImage.fromFilePath(tempFile.path);
  }

  // 👇 ADD THE NEW METHOD HERE 👇

  /// Checks if a face is suitable for recognition based on quality and angle.
  bool isFaceSuitableForRecognition(Face face) {
    // A simple check for head angle. You can make this more robust.
    final double? eulerY = face.headEulerAngleY; // Y-axis rotation (left/right)
    final double? eulerZ = face.headEulerAngleZ; // Z-axis rotation (tilt)

    if (eulerY != null && eulerZ != null) {
      // Check if the head is facing relatively straight
      if (eulerY.abs() < 15 && eulerZ.abs() < 15) {
        return true;
      }
    }

    // You can also add checks for face size here.
    return false;
  }

  // 👆 END OF NEW METHOD 👆

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}