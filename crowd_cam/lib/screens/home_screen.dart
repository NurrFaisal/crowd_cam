import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/notification_service.dart';
import '../services/network_service.dart';
import 'camera_screen.dart';
import 'missing_persons_screen.dart';
import 'detection_history_screen.dart';
import 'add_missing_person_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraService>().initializeCamera();
      context.read<NotificationService>().initialize();
      context.read<NetworkService>().initialize();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const CameraScreen(),
      const MissingPersonsScreen(),
      const DetectionHistoryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CrowdCam'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Missing Persons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMissingPersonScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

