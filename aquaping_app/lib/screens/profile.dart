// lib/screens/profile.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _contact = TextEditingController();
  bool _smsOpt = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // load from API or local prefs (not implemented)
  }

  void _save() async {
    setState(() => _loading = true);
    // Call API to update profile (not implemented here)
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  void _logout() async {
    // clear token + navigate to entry
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText:'Name')),
            TextField(controller: _address, decoration: const InputDecoration(labelText:'Address')),
            TextField(controller: _contact, decoration: const InputDecoration(labelText:'Contact')),
            SwitchListTile(value: _smsOpt, onChanged: (v) => setState(() => _smsOpt = v), title: const Text('SMS Alerts')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _logout, child: const Text('Logout'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
          ]),
        ),
      ),
      if (_loading) const Opacity(opacity: 0.7, child: ModalBarrier(dismissible: false, color: Colors.black)),
      if (_loading) const Center(child: CircularProgressIndicator()),
    ]);
  }
}
