// lib/screens/dashboard.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../utils/severity.dart';
import '../utils/notifications.dart';
import '../utils/alert_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SocketService _socket = SocketService();
  String deviceId = 'device-001';
  int currentLevel = 0;
  String currentSeverity = '';
  String previousSeverity = '';
  Timer? _pollTimer;

  List<Map<String, dynamic>> severityChangeList = [];

  @override
  void initState() {
    super.initState();
    initNotifications();

    // Connect to Socket
    _socket.connect(onReading: (data) {
      print('Socket reading received: $data'); // debug
      _onReading(data);
    });

    // Subscribe to this device
    _socket.subscribeDevice(deviceId);

    // Load recent reading once at startup
    _loadRecent();

    // Optional polling fallback
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadRecent());
  }

  @override
  void dispose() {
    _socket.disconnect();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _onReading(Map<String, dynamic> d) {
    if (d['device_id'] != deviceId) return;

    final newLevel = (d['water_level'] ?? currentLevel).toInt();
    final newSeverity = d['severity'] ?? currentSeverity;

    setState(() {
      currentLevel = newLevel;
      currentSeverity = newSeverity;
    });

    // Notify and record only when severity changes
    if (newSeverity != previousSeverity) {
      severityChangeList.insert(0, { // insert at start for most recent first
        'water_level': newLevel,
        'severity': newSeverity,
        'timestamp': DateTime.now().toString(),
      });

      previousSeverity = newSeverity;

      if (newSeverity != 'none') {
        showNotification(
          'Water Alert: ${newSeverity.toUpperCase()}',
          d['message'] ?? 'Severity changed to $newSeverity',
        );

        showAlertBanner(
          context,
          d['message'] ?? 'Severity changed: $newSeverity',
          newSeverity,
        );
      }

      // Refresh recent readings
      _loadRecent();
    }
  }

  Future<void> _loadRecent() async {
    try {
      final list = await ApiService.recentReadings(deviceId);

      if (list.isNotEmpty) {
        final latest = list.first;

        setState(() {
          currentLevel = latest['water_level'];
          currentSeverity = latest['severity'];
        });

        if (currentSeverity != previousSeverity && currentSeverity != 'none') {
          severityChangeList.insert(0, { // insert at start
            'water_level': currentLevel,
            'severity': currentSeverity,
            'timestamp': latest['timestamp'] ?? DateTime.now().toString(),
          });

          previousSeverity = currentSeverity;

          showNotification(
            'Severity Change: ${currentSeverity.toUpperCase()}',
            'Water Level: $currentLevel%',
          );

          showAlertBanner(
            context,
            'New severity: $currentSeverity ($currentLevel%)',
            currentSeverity,
          );
        }
      }
    } catch (e) {
      print("Error loading recent readings: $e");
    }
  }

  static Color severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'green':
        return const Color(0xFF66BB6A); // Low
      case 'yellow':
        return const Color(0xFFFFD54F); // Medium
      case 'orange':
        return const Color(0xFFFF8A65); // High
      case 'red':
        return const Color(0xFFE53935); // Overflow
      case 'none':
        return Colors.blueGrey; // No water detected
      default:
        return Colors.blueGrey;
    }
  }

  String severityLabel(String s) {
    switch (s.toLowerCase()) {
      case 'green':
        return 'Low';
      case 'yellow':
        return 'Medium';
      case 'orange':
        return 'High';
      case 'red':
        return 'Overflow';
      case 'none':
        return 'No readings yet';
      default:
        return 'No readings yet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, '/map'),
              icon: const Icon(Icons.map)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Water Level',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            '$currentLevel%',
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Severity.label(currentSeverity),
                            style: TextStyle(
                                color: Severity.color(currentSeverity),
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.water_drop,
                        size: 56, color: Severity.color(currentSeverity)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // === Severity Change History Section (most recent first) ===
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Readings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.builder(
                  itemCount: severityChangeList.length,
                  itemBuilder: (context, i) {
                    final r = severityChangeList[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        "Level: ${r['water_level']}%   •   ${r['severity'].toUpperCase()}",
                        style: TextStyle(
                          color: Severity.color(r['severity']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(r['timestamp']),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
