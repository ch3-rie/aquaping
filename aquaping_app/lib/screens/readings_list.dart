// lib/widgets/readings_list.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReadingsList extends StatefulWidget {
  final String deviceId;
  const ReadingsList({super.key, required this.deviceId});
  @override
  State createState() => _ReadingsListState();
}
class _ReadingsListState extends State<ReadingsList> {
  List<dynamic> _readings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.recentReadings(widget.deviceId, limit: 10);
      setState(() { _readings = r; });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_readings.isEmpty) return const Center(child: Text('No readings'));
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      children: _readings.map((e) {
        final ts = e['created_at'] ?? e['timestamp'] ?? '';
        final level = e['water_level'] ?? e['waterLevel'] ?? 0;
        final severity = e['severity'] ?? 'yellow';
        return Card(child: ListTile(
          title: Text('Level: $level%'),
          subtitle: Text('Severity: $severity • $ts'),
        ));
      }).toList(),
    );
  }
}
