// lib/screens/entry_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});
  @override
  State createState() => _EntryScreenState();
}
class _EntryScreenState extends State<EntryScreen> {
  bool _checking = true;
  @override
  void initState() {
    super.initState();
    _checkToken();
  }
  void _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() => _checking = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_checking) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Welcome to AquaPing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Login')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Register')),
        ]),
      ),
    );
  }
}
