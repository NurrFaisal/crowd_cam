class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.222.57.83:8001/api/v1';
  static const String websocketUrl = 'ws://localhost:8000/ws';
  
  // App Information
  static const String appName = 'CrowdCam';
  static const String appVersion = '1.0.0';
  
  // Face Detection Settings
  static const double minFaceSize = 0.1;
  static const double faceDetectionConfidence = 0.7;
  static const double faceRecognitionTolerance = 0.6;
  
  // Network Settings
  static const int heartbeatInterval = 30; // seconds
  static const int connectionTimeout = 10; // seconds
  static const int maxRetryAttempts = 3;
  
  // Storage Keys
  static const String deviceIdKey = 'device_id';
  static const String userPrefsKey = 'user_preferences';
  static const String notificationSettingsKey = 'notification_settings';
  
  // Notification Channels
  static const String matchAlertsChannel = 'match_alerts';
  static const String generalNotificationsChannel = 'general';
  static const String networkAlertsChannel = 'network';
  
  // Image Settings
  static const int maxImageSize = 2048; // pixels
  static const int imageQuality = 85; // jpeg quality
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardRadius = 8.0;
  static const double buttonRadius = 8.0;
}