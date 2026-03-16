import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    try {
      final data = await ApiService.getNotifications();
      setState(() => _notifications = data);
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Color levelColor(String level) {
  switch (level.toLowerCase()) {
    case "green":
      return Colors.green;
    case "yellow":
      return Colors.yellow.shade700;
    case "orange":
      return Colors.orange;
    case "red":
      return Colors.red;
    default:
      return Colors.blueGrey;
  }
}


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text("No notifications yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, i) {
        final n = _notifications[i];
        return Card(
          color: levelColor(n["severity"]).withOpacity(0.15),
          child: ListTile(
            leading: Icon(Icons.notifications_active, color: levelColor(n["severity"])),
            title: Text(n["title"] ?? "Alert"),
            subtitle: Text(
              "${n["message"]}\n${n["timestamp"]}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
