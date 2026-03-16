import 'package:flutter/material.dart';

class Severity {
  static Color color(String s) {
    switch (s.toLowerCase()) {
      case 'green': return const Color(0xFF66BB6A);
      case 'yellow': return const Color(0xFFFFD54F);
      case 'orange': return const Color(0xFFFF8A65);
      case 'red': return const Color(0xFFE53935);
      case 'none': return Colors.blueGrey;
      default: return Colors.blueGrey;
    }
  }

  static String label(String s) {
    switch (s.toLowerCase()) {
      case 'green': return 'Low';
      case 'yellow': return 'Medium';
      case 'orange': return 'High';
      case 'red': return 'Overflow';
      case 'none': return 'No Water';
      default: return 'No readings yet';
    }
  }
}
