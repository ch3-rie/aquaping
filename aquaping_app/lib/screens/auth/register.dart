// lib/screens/auth/register.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _address = TextEditingController();
  bool _smsOpt = true;
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.register(
        _email.text.trim(),
        _pass.text.trim(),
        _name.text.trim(),
        _contact.text.trim(),
        _address.text.trim(),
        _smsOpt
      );
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
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _contact, decoration: const InputDecoration(labelText: 'Contact number')),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              SwitchListTile(title: const Text('SMS alerts'), value: _smsOpt, onChanged: (v) => setState(() => _smsOpt = v)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loading ? null : _register, child: const Text('Register')),
            ]),
          ),
        ),
      ),
      if (_loading) const Opacity(opacity: 0.7, child: ModalBarrier(dismissible: false, color: Colors.black)),
      if (_loading) const Center(child: CircularProgressIndicator()),
    ]);
  }
}
