import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../models/missing_person.dart';
import '../models/detection_result.dart';

class ApiService extends ChangeNotifier {
  // ✅ Use correct base URL depending on environment
  // Real device
  static const String baseUrl = 'http://10.222.57.83:8001/api/v1';

// Android emulator
// static const String baseUrl = 'http://10.0.2.2:8000/api/v1';



  // For iOS Simulator:
  // static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // For real device (replace with your PC LAN IP):
  // static const String baseUrl = 'http://192.168.0.105:8000/api/v1';

  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ✅ Helper: Handle paginated or list responses
  List<dynamic> _extractResults(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
      return decoded['results'];
    } else if (decoded is List) {
      return decoded;
    } else {
      return [];
    }
  }

  // ---------------------------
  // Fetch Missing Persons
  // ---------------------------
  Future<List<MissingPerson>> fetchMissingPersons() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/missing-persons/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final results = _extractResults(decoded);

        final persons =
        results.map((json) => MissingPerson.fromJson(json)).toList();

        _isLoading = false;
        notifyListeners();
        return persons;
      } else {
        throw Exception(
            'Failed to fetch missing persons: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch missing persons: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // ---------------------------
  // Create Missing Person
  // ---------------------------
  Future<MissingPerson?> createMissingPerson({
    required String name,
    required int age,
    required String description,
    required File photoFile,
    required DateTime lastSeenDate,
    required String lastSeenLocation,
    required String contactInfo,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/missing-persons/'),
      );

      request.fields.addAll({
        'name': name,
        'age': age.toString(),
        'description': description,
        'last_seen_date': lastSeenDate.toIso8601String(),
        'last_seen_location': lastSeenLocation,
        'contact_info': contactInfo,
      });

      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final json = jsonDecode(responseData);
        final person = MissingPerson.fromJson(json);

        _isLoading = false;
        notifyListeners();
        return person;
      } else {
        throw Exception(
            'Failed to create missing person: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to create missing person: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ---------------------------
  // Submit Detection
  // ---------------------------
  Future<List<DetectionResult>> submitDetection({
    required File imageFile,
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/face-recognition/detect/'),
      );

      request.fields.addAll({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location': location,
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseData);
        final results = _extractResults(decoded);

        final detections =
        results.map((json) => DetectionResult.fromJson(json)).toList();

        _isLoading = false;
        notifyListeners();
        return detections;
      } else {
        throw Exception(
            'Failed to submit detection: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to submit detection: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // ---------------------------
  // Fetch Detection History
  // ---------------------------
  Future<List<DetectionResult>> fetchDetectionHistory() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/face-recognition/detections/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final results = _extractResults(decoded);

        final detections =
        results.map((json) => DetectionResult.fromJson(json)).toList();

        _isLoading = false;
        notifyListeners();
        return detections;
      } else {
        throw Exception(
            'Failed to fetch detection history: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch detection history: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
