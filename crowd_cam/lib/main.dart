import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/camera_service.dart';
import 'services/api_service.dart';
import 'services/face_detection_service.dart';
import 'services/network_service.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cameras ONLY on Android/iOS
  if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      cameras = await availableCameras();
    } catch (e) {
      print('Error initializing cameras: $e');
      cameras = [];
    }
  } else {
    cameras = [];
  }

  // Initialize notifications ONLY on Android/iOS
  if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
    await NotificationService().initialize();
  }
  
  runApp(const CrowdCamApp());
}

class CrowdCamApp extends StatelessWidget {
  const CrowdCamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CameraService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => FaceDetectionService()),
        ChangeNotifierProvider(create: (_) => NetworkService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'CrowdCam',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}