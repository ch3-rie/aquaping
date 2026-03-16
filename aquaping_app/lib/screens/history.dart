import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _loading = true);
    try {
      final h = await ApiService.userHistory();
      setState(() => _history = h);
    } catch (e) {
      // ignore errors for now
    } finally {
      setState(() => _loading = false);
    }
  }

  Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('No history yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final record = _history[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.water_drop,
                            color: getSeverityColor(record['severity'])),
                        title: Text('Level: ${record['water_level']}%'),
                        subtitle:
                            Text('Severity: ${record['severity']} • ${record['timestamp']}'),
                      ),
                    );
                  },
                ),
    );
  }
}
