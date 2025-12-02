import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/missing_person.dart';
import '../models/detection_result.dart';

class NetworkService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _deviceId;
  List<Map<String, dynamic>> _networkAlerts = [];
  int _activeNodes = 0;
  
  bool get isConnected => _isConnected;
  String? get deviceId => _deviceId;
  List<Map<String, dynamic>> get networkAlerts => _networkAlerts;
  int get activeNodes => _activeNodes;

  static const String serverUrl = 'http://10.222.57.83:8001';

  Future<void> initialize() async {
    await _generateDeviceId();
    await _connectToServer();
    await _registerDevice();
  }

  Future<void> _generateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    
    if (_deviceId == null) {
      _deviceId = 'crowd_cam_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', _deviceId!);
    }
  }

  Future<void> _connectToServer() async {
    try {
      _socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket!.on('connect', (_) {
        print('Connected to server');
        _isConnected = true;
        notifyListeners();
      });

      _socket!.on('disconnect', (_) {
        print('Disconnected from server');
        _isConnected = false;
        notifyListeners();
      });

      _socket!.on('new_missing_person', (data) {
        _handleNewMissingPerson(data);
      });

      _socket!.on('possible_match_alert', (data) {
        _handlePossibleMatch(data);
      });

      _socket!.on('network_alert', (data) {
        _handleNetworkAlert(data);
      });

      _socket!.on('active_nodes_count', (data) {
        _activeNodes = data['count'] ?? 0;
        notifyListeners();
      });

      _socket!.connect();
    } catch (e) {
      print('Error connecting to server: $e');
    }
  }

  Future<void> _registerDevice() async {
    if (_deviceId == null || !_isConnected) return;

    _socket!.emit('register_device', {
      'device_id': _deviceId,
      'device_name': 'Flutter CrowdCam App',
      'capabilities': ['face_detection', 'camera_capture'],
    });
  }

  void _handleNewMissingPerson(dynamic data) {
    try {
      final alert = {
        'type': 'new_missing_person',
        'title': 'New Missing Person Alert',
        'message': 'A new missing person has been reported: ${data['name']}',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _networkAlerts.insert(0, alert);
      if (_networkAlerts.length > 50) {
        _networkAlerts.removeLast();
      }
      
      notifyListeners();
      _showNotification('New Missing Person', alert['message'] as String);
    } catch (e) {
      print('Error handling new missing person alert: $e');
    }
  }

  void _handlePossibleMatch(dynamic data) {
    try {
      final alert = {
        'type': 'possible_match',
        'title': 'Possible Match Found',
        'message': 'A potential match has been detected nearby',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _networkAlerts.insert(0, alert);
      if (_networkAlerts.length > 50) {
        _networkAlerts.removeLast();
      }
      
      notifyListeners();
      _showNotification('Possible Match', alert['message'] as String);
    } catch (e) {
      print('Error handling possible match alert: $e');
    }
  }

  void _handleNetworkAlert(dynamic data) {
    try {
      final alert = {
        'type': data['type'] ?? 'general',
        'title': data['title'] ?? 'Network Alert',
        'message': data['message'] ?? 'Network notification',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _networkAlerts.insert(0, alert);
      if (_networkAlerts.length > 50) {
        _networkAlerts.removeLast();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error handling network alert: $e');
    }
  }

  void _showNotification(String title, String message) {
    
    print('Notification: $title - $message');
  }

  Future<void> broadcastDetection(DetectionResult detection) async {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('detection_broadcast', {
        'detection_id': detection.detectionId,
        'missing_person_id': detection.missingPersonId,
        'confidence_score': detection.confidenceScore,
        'location': detection.location,
        'latitude': detection.latitude,
        'longitude': detection.longitude,
        'detected_at': detection.detectedAt.toIso8601String(),
        'device_id': _deviceId,
      });
    } catch (e) {
      print('Error broadcasting detection: $e');
    }
  }

  Future<void> sendHeartbeat({
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('heartbeat', {
        'device_id': _deviceId,
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'status': 'active',
      });
    } catch (e) {
      print('Error sending heartbeat: $e');
    }
  }

  Future<void> requestMissingPersonsUpdate() async {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('request_missing_persons_update');
    } catch (e) {
      print('Error requesting missing persons update: $e');
    }
  }

  void markAlertAsRead(int index) {
    if (index >= 0 && index < _networkAlerts.length) {
      _networkAlerts[index]['read'] = true;
      notifyListeners();
    }
  }

  void clearAlerts() {
    _networkAlerts.clear();
    notifyListeners();
  }

  int get unreadAlertsCount {
    return _networkAlerts.where((alert) => alert['read'] != true).length;
  }

  Future<void> joinCameraNetwork() async {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('join_camera_network', {
        'device_id': _deviceId,
        'capabilities': ['face_detection', 'camera_capture'],
        'volunteer_mode': true,
      });
    } catch (e) {
      print('Error joining camera network: $e');
    }
  }

  Future<void> leaveCameraNetwork() async {
    if (!_isConnected || _socket == null) return;

    try {
      _socket!.emit('leave_camera_network', {
        'device_id': _deviceId,
      });
    } catch (e) {
      print('Error leaving camera network: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}