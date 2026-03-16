import 'package:flutter/material.dart';

void showAlertBanner(BuildContext context, String message, String severity) {
  final color = _severityColor(severity);

  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    backgroundColor: color,
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(12),
  );

  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // hide previous
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Color _severityColor(String s) {
  switch (s.toLowerCase()) {
    case 'green': return const Color(0xFF66BB6A);
    case 'yellow': return const Color(0xFFFFD54F);
    case 'orange': return const Color(0xFFFF8A65);
    case 'red': return const Color(0xFFE53935);
    default: return Colors.blueGrey;
  }
}
