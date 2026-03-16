import 'package:flutter/material.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/dashboard.dart';
import 'screens/map_screen.dart';
import 'screens/history.dart';
import 'screens/profile.dart';
import 'screens/notifications_screen.dart';

class AquaPingApp extends StatelessWidget {
  const AquaPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaPing',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/map': (_) => const MapScreen(),
        '/history': (_) => const HistoryScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/notifications': (_) => const NotificationsScreen(),
      },
    );
  }
}
