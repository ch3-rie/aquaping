// lib/screens/auth/login.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.login(_email.text.trim(), _pass.text.trim());
      if (res['success'] == true && res['token'] != null) {
        final token = res['token'];
        ApiService.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_token', token);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final msg = res['message'] ?? jsonEncode(res);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _login, child: const Text('Login'))
          ]),
        ),
      ),
      if (_loading) const Opacity(opacity: 0.7, child: ModalBarrier(dismissible: false, color: Colors.black)),
      if (_loading) const Center(child: CircularProgressIndicator()),
    ]);
  }
}
