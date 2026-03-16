// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/entry_screen.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/dashboard.dart';
import 'screens/map_screen.dart';
import 'screens/history.dart';
import 'screens/profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import '../utils/notifications.dart'; // make sure path is correct


Future<void> _bgHandler(RemoteMessage msg) async {
  debugPrint("BG MESSAGE: ${msg.data}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // optional, only for push
  await initNotifications(); // optional, only for push
  runApp(const AquaPingApp());
}

class AquaPingApp extends StatelessWidget {
  const AquaPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaPing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EntryScreen(),
      routes: {
        '/login': (c) => const LoginScreen(),
        '/register': (c) => const RegisterScreen(),
        '/dashboard': (c) => const DashboardScreen(),
        '/map': (c) => const MapScreen(),
        '/history': (c) => const HistoryScreen(),
        '/profile': (c) => const ProfileScreen(),
      },
    );
  }
}
