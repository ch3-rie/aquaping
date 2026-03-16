// lib/widgets/water_level_gauge.dart
import 'package:flutter/material.dart';
import '../utils/severity.dart';  // <--- use the shared Severity class

class WaterLevelGauge extends StatelessWidget {
  final int level;
  final String severity;

  const WaterLevelGauge({
    super.key,
    required this.level,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Severity.color(severity); // unified color

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Water Level', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$level%',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: level / 100.0,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
