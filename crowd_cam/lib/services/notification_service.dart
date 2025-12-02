import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
      _isInitialized = false;
      _notificationsEnabled = false;
      return;
    }

    try {
      // Request permission
      final permission = await Permission.notification.request();
      if (!permission.isGranted) {
        _notificationsEnabled = false;
        notifyListeners();
        return;
      }

      // Initialize plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels
      await _createNotificationChannels();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing notifications: $e');
      _isInitialized = false;
      _notificationsEnabled = false;
      notifyListeners();
    }
  }

  Future<void> _createNotificationChannels() async {
    const matchChannel = AndroidNotificationChannel(
      'match_alerts',
      'Match Alerts',
      description: 'Notifications for possible missing person matches',
      importance: Importance.high,
    );

    const generalChannel = AndroidNotificationChannel(
      'general',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    const networkChannel = AndroidNotificationChannel(
      'network',
      'Network Updates',
      description: 'Camera network status and updates',
      importance: Importance.low,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(matchChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(networkChannel);
  }

  Future<void> showMatchAlert({
    required String personName,
    required double confidence,
    required String location,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isInitialized || !_notificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'match_alerts',
      'Match Alerts',
      channelDescription: 'Notifications for possible missing person matches',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2196F3),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = 'Possible Match Found!';
    final body = 'Potential match for $personName detected near $location '
                '(${(confidence * 100).toStringAsFixed(1)}% confidence)';

    await _notifications.show(
      1,
      title,
      body,
      details,
      payload: payload != null ? _encodePayload(payload) : null,
    );
  }

  Future<void> showNewMissingPersonAlert({
    required String personName,
    required int age,
    required String lastSeenLocation,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isInitialized || !_notificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2196F3),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = 'New Missing Person Alert';
    final body = '$personName, age $age, last seen in $lastSeenLocation. '
                'Help keep an eye out!';

    await _notifications.show(
      2,
      title,
      body,
      details,
      payload: payload != null ? _encodePayload(payload) : null,
    );
  }

  Future<void> showNetworkAlert({
    required String title,
    required String message,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isInitialized || !_notificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'network',
      'Network Updates',
      channelDescription: 'Camera network status and updates',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF2196F3),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      title,
      message,
      details,
      payload: payload != null ? _encodePayload(payload) : null,
    );
  }

  Future<void> showDetectionSuccessAlert({
    required int matchCount,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isInitialized || !_notificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = matchCount > 0 ? 'Match Detected!' : 'Photo Processed';
    final body = matchCount > 0 
        ? 'Found $matchCount potential match${matchCount > 1 ? 'es' : ''}. Thank you for helping!'
        : 'Photo processed successfully. No matches found, but thank you for helping!';

    await _notifications.show(
      4,
      title,
      body,
      details,
      payload: payload != null ? _encodePayload(payload) : null,
    );
  }

  String _encodePayload(Map<String, dynamic> payload) {
    try {
      return payload.toString(); // Simple encoding for now
    } catch (e) {
      return '';
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to relevant screen
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  Future<void> schedulePeriodicNetworkCheck() async {
    // This could be used to schedule periodic checks
    // Currently just a placeholder
  }
}