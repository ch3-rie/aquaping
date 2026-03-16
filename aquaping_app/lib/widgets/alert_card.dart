import 'package:flutter/material.dart';
import '../utils/severity.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String severity;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: severity == 'red' ? Colors.red[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Severity.color(severity),
          child: const Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(message),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Acknowledge'),
        ),
      ),
    );
  }
}
