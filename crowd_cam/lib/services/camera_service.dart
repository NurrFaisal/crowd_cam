import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _errorMessage;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  String? get errorMessage => _errorMessage;

  Future<void> initializeCamera({int cameraIndex = 0}) async {
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      _errorMessage = 'Camera is not available on this platform';
      notifyListeners();
      return;
    }

    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        _errorMessage = 'Camera permission not granted';
        notifyListeners();
        return;
      }

      if (_controller != null) {
        await _controller!.dispose();
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorMessage = 'No cameras available';
        notifyListeners();
        return;
      }

      _controller = CameraController(
        cameras[cameraIndex < cameras.length ? cameraIndex : 0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize camera: $e';
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      return null;
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      _errorMessage = 'Failed to take picture: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> startRecording() async {
    if (!_isInitialized || _controller == null || _isRecording) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  Future<XFile?> stopRecording() async {
    if (!_isRecording || _controller == null) {
      return null;
    }

    try {
      final video = await _controller!.stopVideoRecording();
      _isRecording = false;
      notifyListeners();
      return video;
    } catch (e) {
      _errorMessage = 'Failed to stop recording: $e';
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> switchCamera() async {
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    if (_controller == null) return;

    final cameras = await availableCameras();
    if (cameras.length < 2) return;

    final currentDescription = _controller!.description;
    final newIndex = cameras.indexOf(currentDescription) == 0 ? 1 : 0;
    
    await initializeCamera(cameraIndex: newIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}